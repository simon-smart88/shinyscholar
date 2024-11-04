path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)

test_that("Check select_user function works as expected", {

  result <- select_user(path)
  expect_is(result, "SpatRaster")

})

retry_test(function() {
  test_that("{shinytest2} recording: e2e_select_user", {
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_user")
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_user")
    app$upload_file("select_user-raster" = path)
    app$set_inputs("select_user-name" = "test")
    app$click("select_user-run")
    app$set_inputs(main = "Save")
    app$get_download("core_save-save_session", filename = save_path)
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
    app$stop()
  })
})
