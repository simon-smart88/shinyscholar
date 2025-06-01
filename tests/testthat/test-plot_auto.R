if (suggests){
  bins <- 20

  test_that("{shinytest2} recording: e2e_plot_auto", {

    skip_if(is_fedora())
    skip_on_cran()

    rerun_test("plot_auto_test", list(raster_path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    expect_is(common$histogram_auto, "function")
  })
}
