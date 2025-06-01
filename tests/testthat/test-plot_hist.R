if (suggests){
  bins <- 20
  palette <- "Greens"
  name <- "Example"

  test_that("Check plot_hist function works as expected", {
    result <- plot_hist(raster, bins, palette, name)
    expect_is(result, "function")

    expect_error(plot_hist("raster", 10, palette, name), "The raster must be a SpatRaster")
    expect_error(plot_hist(raster, "ten", palette, name), "bins must be numeric")
    expect_error(plot_hist(raster, 10, 10, name), "palette must be a character")
    expect_error(plot_hist(raster, 10, "x", name), "palette must be either")
    expect_error(plot_hist(raster, 10, palette, 10), "name must be a character")
  })

  test_that("{shinytest2} recording: e2e_plot_hist", {

    skip_if(is_fedora())
    skip_on_cran()

    rerun_test("plot_hist_test", list(raster_path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    expect_is(common$histogram, "function")
  })
}
