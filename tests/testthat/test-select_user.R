if (suggests){
  test_that("Check select_user function works as expected", {
    result <- select_user(raster_path)
    expect_is(result, "SpatRaster")

    not_raster <- list.files(system.file("extdata", package = "shinyscholar"),
                             pattern = ".R$", full.names = TRUE)
    expect_error(select_user("a.tif"), "The specified raster does not exist")
    expect_error(select_user(not_raster), "The raster must be a \\.tif")
  })

  test_that("{shinytest2} recording: e2e_select_user", {
    rerun_test("select_user_test", list(raster_path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
  })
}
