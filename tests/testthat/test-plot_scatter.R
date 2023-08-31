path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)
ras <- terra::rast(path)
sample <- 1000
axis <- "y"

test_that("Check plot_scatter function works as expected", {

  skip_on_cran()

  result <- plot_scatter(ras, sample, axis)

  expect_is(result, "data.frame")
  expect_equal(colnames(result)[1], "y")
  expect_equal(is.numeric(result$value), TRUE)
  expect_equal(nrow(result), 1000)

})


