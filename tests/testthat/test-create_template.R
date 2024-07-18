modules <- data.frame(
  "component" = c("select", "select", "plot", "plot"),
  "long_component" = c("Select data", "Select data", "Plot data", "Plot data"),
  "module" = c("user", "query", "hist", "scatter"),
  "long_module" = c("Upload your own data", "Query a database to obtain data",
                    "Plot the data as a histogram", "Plot the data as a scatterplot"),
  "map" = c(TRUE, FALSE, FALSE, FALSE),
  "result" = c(TRUE, FALSE, FALSE, FALSE),
  "rmd" = c(TRUE, TRUE, TRUE, TRUE),
  "save" = c(TRUE, TRUE, TRUE, TRUE),
  "async" = c(TRUE, FALSE, FALSE, FALSE))

common_objects = c("raster", "histogram", "scatter")

test_that("Check create template returns expected errors", {

  directory <- tempfile()
  dir.create(directory, recursive = TRUE)

  expect_error(create_template(path = "~", name = "shiny_scholar",
              include_map = TRUE, include_table = TRUE, include_code = TRUE,
              common_objects = common_objects, modules = modules,
              author = "Simon E. H. Smart", install = FALSE, logger = NULL),
              "Package names can only contain letters and numbers")

  expect_error(create_template(path = "~", name = "1shinyscholar",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "Package names cannot start with numbers")

  expect_error(create_template(path = "~", name = "shiny",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "A package on CRAN already uses that name")

  expect_warning(create_template(path = directory, name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = within(modules, rm("async")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "As of v0.2.0 the modules dataframe should also contain an async column")

  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = within(modules, rm("long_module")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
                 "The modules dataframe must contain the column\\(s\\): long_module")

  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = within(modules, rm("long_module", "map")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
                 "The modules dataframe must contain the column\\(s\\): long_module,map")

  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects,
               modules = cbind(modules, data.frame("banana" = rep(FALSE, 4))),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The modules dataframe contains banana which is/are not valid column names")

  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects,
               modules = cbind(modules, data.frame("banana" = rep(FALSE, 4), "apple" = rep(1,4))),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The modules dataframe contains banana,apple which is/are not valid column names")

  modules$map <- c(FALSE, FALSE, FALSE, FALSE)
  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "You have included a map but none of your modules use it")

  modules$map <- c(TRUE, TRUE, FALSE, FALSE)
  modules$result <- c(FALSE, FALSE, FALSE, FALSE)
  expect_error(create_template(path = "~", name = "shinydemo",
               include_map = TRUE, include_table = TRUE, include_code = TRUE,
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "At least one module must return results")

  modules$result <- c(FALSE, FALSE, TRUE, TRUE)
  expect_error(create_template(path = "~", name = "shinydemo",
                               include_map = TRUE, include_table = TRUE, include_code = TRUE,
                               common_objects = c("logger", common_objects), modules = modules,
                               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               paste0("common_objects contains logger which are included\nin common by default\\. ",
                      "Please choose a different name\\."))
})

test_that("Check create template function works as expected", {

  modules$map <- c(TRUE, TRUE, FALSE, FALSE)

  directory <- tempfile()
  dir.create(directory, recursive = TRUE)
  #the name must be shinyscholar so that the calls to package files work
  create_template(path = directory, name = "shinyscholar",
       include_map = TRUE, include_table = TRUE, include_code = TRUE,
       common_objects = common_objects, modules = modules,
       author = "Simon E. H. Smart", install = FALSE)

  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/server.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/ui.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/global.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/select_user.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/run_shinyscholar.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/run_module.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.Rmd")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.yml")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.md")))

  #there is not much to test when running the app, but this confirms that it runs
  test_that("{shinytest2} recording: testing_create_template", {
    app <- shinytest2::AppDriver$new(app_dir = paste0(directory,"/shinyscholar/inst/shiny/"), name = "create_test")
    common <- app$get_value(export = "common")
    expect_true(is.null(common$raster))
  })

})

test_that("Check create template function works with false settings", {

  modules$map <- c(FALSE, FALSE, FALSE, FALSE)
  modules$result <- c(TRUE, FALSE, FALSE, FALSE)
  modules$rmd = c(FALSE, FALSE, FALSE, FALSE)
  modules$save = c(FALSE, FALSE, FALSE, FALSE)
  modules$async = c(FALSE, FALSE, FALSE, FALSE)

  directory <- tempfile()
  dir.create(directory, recursive = TRUE)
  #the name must be shinyscholar so that the calls to package files work
  create_template(path = directory, name = "shinyscholar",
                  include_map = FALSE, include_table = FALSE, include_code = FALSE,
                  common_objects = common_objects, modules = modules,
                  author = "Simon E. H. Smart", install = FALSE)


  global <- readLines(file.path(directory,"shinyscholar/inst/shiny/global.R"))
  core_target <- grep("core_modules <-", global)
  global[core_target] <- glue::glue('core_modules <- file.path("modules", list.files(paste0("{directory}","/shinyscholar/inst/shiny/modules/"), pattern="core_*"))')
  writeLines(global, file.path(directory,"shinyscholar/inst/shiny/global.R"))

  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/server.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/ui.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/global.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/select_user.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/run_shinyscholar.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/R/run_module.R")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.R")))
  expect_false(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.Rmd")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.yml")))
  expect_true(file.exists(paste0(directory,"/shinyscholar/inst/shiny/modules/select_user.md")))

  #there is not much to test when running the app, but this confirms that it runs
  test_that("{shinytest2} recording: testing_create_template", {
    app <- shinytest2::AppDriver$new(app_dir = paste0(directory,"/shinyscholar/inst/shiny/"), name = "create_test")
    common <- app$get_value(export = "common")
    expect_true(is.null(common$raster))
  })
})

