path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)

test_that("Check select_user function works as expected", {
  result <- select_user(path)
  expect_is(result, "SpatRaster")
})

test_that("{shinytest2} recording: e2e_select_user", {
  rerun_test("select_user_test", list(path = path, save_path = save_path))
  common <- readRDS(save_path)
  common$raster <- terra::unwrap(common$raster)
  expect_is(common$raster, "SpatRaster")
})
