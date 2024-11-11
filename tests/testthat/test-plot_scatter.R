path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)
raster <- terra::rast(path)
sample <- 1000
axis <- "y"

test_that("Check plot_scatter function works as expected", {

  result <- plot_scatter(raster, sample, axis)

  expect_is(result, "data.frame")
  expect_equal(colnames(result)[1], "y")
  expect_equal(is.numeric(result$value), TRUE)
  expect_equal(nrow(result), 1000)

})

test_that("{shinytest2} recording: e2e_plot_scatter", {

  rerun_test("plot_scatter_test", list(path = path, save_path = save_path))
  common <- readRDS(save_path)
  expect_is(common$scatterplot, "data.frame")

})
