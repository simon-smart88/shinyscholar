path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)
ras <- terra::rast(path)
bins <- 20

test_that("Check plot_hist function works as expected", {

  skip_on_cran()

  result <- plot_hist(ras, bins)

  expect_is(result, "histogram")
  expect_equal(length(result$mids), 20)
  expect_equal(sum(result$density), 100)

})


