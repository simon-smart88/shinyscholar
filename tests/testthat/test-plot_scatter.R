if (suggests){
  sample <- 1000
  axis <- "Longitude"
  name <- "Example"

  test_that("Check plot_scatter function works as expected", {
    result <- plot_scatter(raster, sample, axis, name)
    expect_is(result, "function")

    expect_error(plot_scatter("raster", 10, axis, name), "The raster must be a SpatRaster")
    expect_error(plot_scatter(raster, "ten", axis, name), "sample must be numeric")
    expect_error(plot_scatter(raster, 10, "z", name), "axis must be either Latitude or Longitude")
    expect_error(plot_scatter(raster, 10, axis, 10), "name must be a character")
  })

  test_that("{shinytest2} recording: e2e_plot_scatter", {

    skip_if(is_fedora())
    skip_on_cran()

    rerun_test("plot_scatter_test", list(raster_path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    expect_is(common$scatterplot, "function")
  })
}

