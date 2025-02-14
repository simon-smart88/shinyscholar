if (suggests){
  test_that("{shinytest2} recording: e2e_empty_save", {

    skip_if(is_fedora())

    rerun_test("empty_save_test", list(save_path = save_path))
    common <- readRDS(save_path)
    expect_true(is.null(common$raster))
  })

  test_that("{shinytest2} recording: e2e_save_scat", {

    skip_if(is_fedora())

    rerun_test("save_scat_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
    expect_is(common$scatterplot, "data.frame")

  })

  test_that("{shinytest2} recording: e2e_save_hist", {

    skip_if(is_fedora())

    rerun_test("save_hist_test", list(path = raster_path, save_path = save_path))
    common <- readRDS(save_path)
    common$raster <- terra::unwrap(common$raster)
    expect_is(common$raster, "SpatRaster")
    expect_is(common$histogram, "histogram")
  })

  test_that("{shinytest2} recording: e2e_load", {

    skip_if(is_fedora())

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_load")
    app$set_inputs(introTabs = "Load Prior Session")
    app$upload_file("core_load-load_session" = save_path)
    app$click("core_load-goLoad_session")
    common <- app$get_value(export = "common")
    expect_is(common$raster, "SpatRaster")
    app$stop()
  })

  test_that("load can handle old common objects", {

    skip_if(is_fedora())

    common_class <- R6::R6Class(
      classname = "common",
      public = list(
        old_data = "old_data",
        raster = terra::wrap(raster),
        state = NULL
      )
    )

    common <- common_class$new()
    common$state$main$version <- as.character(packageVersion("shinyscholar"))
    common$state$main$app <- "shinyscholar"
    saveRDS(common, save_path)

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_load")
    app$set_inputs(introTabs = "Load Prior Session")
    app$upload_file("core_load-load_session" = save_path)
    app$click("core_load-goLoad_session")
    common <- app$get_value(export = "common")
    expect_is(common$raster, "SpatRaster")
    app$stop()
  })

}
