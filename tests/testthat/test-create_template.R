test_that("Check init function works as expected", {

  directory <- tempdir()

  modules <- data.frame(
    "component" = c("select", "select", "plot", "plot"),
    "long_component" = c("Select data", "Select data", "Plot data", "Plot data"),
    "module" = c("user", "query", "histogram", "scatter"),
    "long_module" = c("Upload your own data", "Query a database to obtain data",
                      "Plot the data as a histogram", "Plot the data as a scatterplot"),
    "map" = c(TRUE, TRUE, FALSE, FALSE),
    "result" = c(FALSE, FALSE, TRUE, TRUE),
    "rmd" = c(TRUE, TRUE, TRUE, TRUE),
    "save" = c(TRUE, TRUE, TRUE, TRUE))

  common_objects = c("raster", "histogram", "scatter")

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
  test_that("{shinytest2} recording: testing_init", {
    app <- shinytest2::AppDriver$new(app_dir = paste0(directory,"/shinyscholar/inst/shiny/"), name = "init_test")
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "data_user")
    common <- app$get_value(export = "common")
    expect_true(is.null(common$raster))
  })
})

