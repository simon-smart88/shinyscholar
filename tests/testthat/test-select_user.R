path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

test_that("Check select_user function works as expected", {

  skip_on_cran()

  result <- select_user(path)

  expect_is(result, 'SpatRaster')

})


