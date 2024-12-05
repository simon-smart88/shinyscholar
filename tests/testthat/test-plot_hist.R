if (!no_suggests){
  bins <- 20

  test_that("Check plot_hist function works as expected", {
    result <- plot_hist(raster, bins)
    expect_is(result, "histogram")
    expect_equal(length(result$mids), 20)
    expect_equal(sum(result$density), 100)
  })

  test_that("{shinytest2} recording: e2e_plot_hist", {
    rerun_test("plot_hist_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    expect_is(common$histogram, "histogram")
  })
}
