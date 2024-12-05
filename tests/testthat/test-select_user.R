if (!no_suggests){
  test_that("Check select_user function works as expected", {
    result <- select_user(raster_path)
    expect_is(result, "SpatRaster")
  })

  test_that("{shinytest2} recording: e2e_select_user", {
    rerun_test("select_user_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
  })
}
