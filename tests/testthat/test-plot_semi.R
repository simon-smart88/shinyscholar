if (suggests){

  test_that("{shinytest2} recording: e2e_plot_semi", {

    skip_if(is_fedora())

    rerun_test("plot_semi_test", list(raster_path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    expect_is(common$histogram_semi, "histogram")
    expect_equal(common$meta$plot_semi$bins, 100)
  })
}
