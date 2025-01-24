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
  dir.create(file.path(directory, "existing"))

  expect_error(create_template(path = 123, name = "shinyscholara",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "path must be a character string")

  expect_error(create_template(path = "~/a_faulty_path", name = "shinyscholara",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The specified path does not exist")

  expect_error(create_template(path = "~", name = 123,
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "name must be a character string")

  expect_error(create_template(path = "~", name = "shiny_scholar",
              common_objects = common_objects, modules = modules,
              author = "Simon E. H. Smart", install = FALSE, logger = NULL),
              "Package names can only contain letters and numbers")

  expect_error(create_template(path = "~", name = "1shinyscholar",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "Package names cannot start with numbers")

  expect_error(create_template(path = "~", name = "shiny",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "A package on CRAN already uses that name")

  expect_error(create_template(path = directory, name = "existing",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The specified app directory already exists")

  expect_error(create_template(path = directory, name = "shinydemo",
                 common_objects = common_objects, modules = "not_df",
                 author = "Simon E. H. Smart", install = FALSE, logger = NULL),
                 "modules must be a dataframe")

  expect_warning(create_template(path = directory, name = "shinydemo",
               common_objects = common_objects, modules = within(modules, rm("async")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "As of v0.2.0 the modules dataframe should also contain an async column")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = within(modules, rm("long_module")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
                 "The modules dataframe must contain the column\\(s\\): long_module")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = within(modules, rm("long_module", "map")),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
                 "The modules dataframe must contain the column\\(s\\): long_module,map")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects,
               modules = cbind(modules, data.frame("banana" = rep(FALSE, 4))),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The modules dataframe contains banana which is/are not valid column names")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects,
               modules = cbind(modules, data.frame("banana" = rep(FALSE, 4), "apple" = rep(1,4))),
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "The modules dataframe contains banana,apple which is/are not valid column names")

  modules$map <- c(FALSE, FALSE, FALSE, FALSE)
  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "You have included a map but none of your modules use it")

  modules$map <- c(TRUE, TRUE, FALSE, FALSE)
  modules$result <- c(FALSE, FALSE, FALSE, FALSE)
  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "At least one module must return results")

  modules$result <- c(FALSE, FALSE, TRUE, TRUE)
  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = modules, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "common_objects must be a vector of character strings")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = c(123, 123), modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               "common_objects must be a vector of character strings")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = c("logger", common_objects), modules = modules,
               author = "Simon E. H. Smart", install = FALSE, logger = NULL),
               paste0("common_objects contains logger which are included\nin common by default\\. ",
                      "Please choose a different name\\."))

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = modules,
               author = 123, install = FALSE, include_map = "no", logger = NULL),
               "author must be a character string")

  expect_error(create_template(path = "~", name = "shinydemo",
               common_objects = common_objects, modules = modules,
               author = "Simon E. H. Smart", install = FALSE, include_map = "no", logger = NULL),
               "include_map, include_table")

})

test_that("Check create template function works as expected", {
  withr::with_temp_libpaths({
    modules$map <- c(TRUE, TRUE, FALSE, FALSE)

    directory <- tempfile()
    dir.create(directory, recursive = TRUE)

    name <- "shinyscholara"

    create_template(path = directory, name = name,
         common_objects = common_objects, modules = modules,
         author = "Simon E. H. Smart", install = FALSE)

    devtools::install(file.path(directory, name), force = TRUE, quick = TRUE, dependencies = FALSE)

    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "server.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "ui.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "global.R")))
    expect_true(file.exists(file.path(directory, name, "R", "select_user_f.R")))
    expect_true(file.exists(file.path(directory, name, "R", paste0("run_", name, ".R"))))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.Rmd")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.yml")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.md")))

    if (suggests){
      app <- shinytest2::AppDriver$new(app_dir = file.path(directory, name, "inst", "shiny"), name = "create_test")
      common <- app$get_value(export = "common")
      expect_true(is.null(common$raster))
      app$stop()
    }
  })
})

test_that("Check create template function works with false settings", {
  withr::with_temp_libpaths({
    modules$map <- c(FALSE, FALSE, FALSE, FALSE)
    modules$result <- c(TRUE, FALSE, FALSE, FALSE)
    modules$rmd = c(FALSE, FALSE, FALSE, FALSE)
    modules$save = c(FALSE, FALSE, FALSE, FALSE)
    modules$async = c(FALSE, FALSE, FALSE, FALSE)

    directory <- tempfile()
    dir.create(directory, recursive = TRUE)
    name <- "shinyscholarb"

    create_template(path = directory, name = name,
                    common_objects = common_objects, modules = modules,
                    author = "Simon E. H. Smart", include_map = FALSE,
                    include_table = FALSE, include_code = FALSE, install = FALSE)

    devtools::install(file.path(directory, name), force = TRUE, quick = TRUE, dependencies = FALSE)

    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "server.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "ui.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "global.R")))
    expect_true(file.exists(file.path(directory, name, "R", "select_user_f.R")))
    expect_true(file.exists(file.path(directory, name, "R", paste0("run_", name, ".R"))))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.R")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.yml")))
    expect_true(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.md")))
    expect_false(file.exists(file.path(directory, name, "inst", "shiny", "modules", "select_user.Rmd")))
    expect_false(file.exists(file.path(directory, name, "inst", "shiny", "modules", "core_mapping.R")))
    expect_false(file.exists(file.path(directory, name, "inst", "shiny", "modules", "core_code.R")))

    if (suggests){
      app <- shinytest2::AppDriver$new(app_dir = file.path(directory, name, "inst", "shiny"), name = "create_test")
      common <- app$get_value(export = "common")
      expect_true(is.null(common$raster))
      app$stop()
    }
  })
})

test_that("Check async, no map runs correctly", {
  if (suggests){
    withr::with_temp_libpaths({
      modules$map <- c(FALSE, FALSE, FALSE, FALSE)
      modules$result <- c(TRUE, FALSE, FALSE, FALSE)
      modules$rmd = c(FALSE, FALSE, FALSE, FALSE)
      modules$save = c(FALSE, FALSE, FALSE, FALSE)
      modules$async = c(TRUE, FALSE, FALSE, FALSE)

      directory <- tempfile()
      dir.create(directory, recursive = TRUE)
      name <- "shinyscholarc"

      create_template(path = directory, name = name,
                  common_objects = common_objects, modules = modules,
                  author = "Simon E. H. Smart", include_map = FALSE,
                  include_table = FALSE, include_code = FALSE, install = FALSE)

      devtools::install(file.path(directory, name), force = TRUE, quick = TRUE, dependencies = FALSE)

      app <- shinytest2::AppDriver$new(app_dir = file.path(directory, name, "inst", "shiny"), name = "create_test")
      common <- app$get_value(export = "common")
      expect_true(is.null(common$raster))
      app$stop()
    })
  }
})

test_that("Check async, with map runs correctly", {
  if (suggests){
    modules$map <- c(TRUE, FALSE, FALSE, FALSE)
    modules$result <- c(TRUE, FALSE, FALSE, FALSE)
    modules$rmd = c(FALSE, FALSE, FALSE, FALSE)
    modules$save = c(FALSE, FALSE, FALSE, FALSE)
    modules$async = c(TRUE, FALSE, FALSE, FALSE)

    directory <- tempfile()
    dir.create(directory, recursive = TRUE)
    name <- "shinyscholard"

    create_template(path = directory, name = name,
                    common_objects = common_objects, modules = modules,
                    author = "Simon E. H. Smart", include_map = TRUE,
                    include_table = FALSE, include_code = TRUE, install = FALSE)

    devtools::install(file.path(directory, name), force = TRUE, quick = TRUE, dependencies = FALSE)

    app <- shinytest2::AppDriver$new(app_dir = file.path(directory, name, "inst", "shiny"), name = "create_test")
    common <- app$get_value(export = "common")
    expect_true(is.null(common$raster))
    app$stop()
  }
})
