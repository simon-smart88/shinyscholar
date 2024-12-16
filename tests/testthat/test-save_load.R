if (suggests){
  test_that("{shinytest2} recording: e2e_empty_save", {
    rerun_test("empty_save_test", list(save_path = save_path))
    common <- readRDS(save_path)
    expect_true(is.null(common$raster))
  })

  test_that("{shinytest2} recording: e2e_save_scat", {
    rerun_test("save_scat_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
    expect_is(common$scatterplot, "data.frame")

  })

  test_that("{shinytest2} recording: e2e_save_hist", {
    rerun_test("save_hist_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
    expect_is(common$histogram, "histogram")
  })

  test_that("{shinytest2} recording: e2e_load", {
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_load")
    app$set_inputs(introTabs = "Load Prior Session")
    app$upload_file("core_load-load_session" = save_path)
    app$click("core_load-goLoad_session")
    common <- app$get_value(export = "common")
    expect_is(common$raster, "SpatRaster")
    app$stop()
  })
}
