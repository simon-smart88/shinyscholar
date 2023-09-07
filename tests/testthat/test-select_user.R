path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

test_that("Check select_user function works as expected", {

  skip_on_cran()

  result <- select_user(path)

  expect_is(result, 'SpatRaster')

})

test_that("{shinytest2} recording: e2e_select_user", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_select_user")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "test")
  app$click("select_user-run")
  common <- app$get_value(export = "common")
  expect_is(common$ras, 'SpatRaster')
})
