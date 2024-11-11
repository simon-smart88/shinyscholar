path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)

#this works
test_that("{shinytest2} recording: e2e_empty_save", {

  rerun_test("empty_save_test", list(save_path = save_path))
  common <- readRDS(save_path)
  expect_true(is.null(common$raster))

})

#this works
test_that("{shinytest2} recording: e2e_save_scat", {

  rerun_test("save_scat_test", list(path = path, save_path = save_path))
  common <- readRDS(save_path)
  common$raster <- terra::unwrap(common$raster)
  expect_is(common$raster, "SpatRaster")
  expect_is(common$scatterplot, "data.frame")

})


#this may be temperamental
test_that("{shinytest2} recording: e2e_save_hist", {

  rerun_test("save_hist_test", list(path = path, save_path = save_path))
  common <- readRDS(save_path)
  common$raster <- terra::unwrap(common$raster)
  expect_is(common$raster, "SpatRaster")
  expect_is(common$histogram, "histogram")

})

test_that("{shinytest2} recording: e2e_load", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_load")
  app$set_inputs(introTabs = "Load Prior Session")
  app$upload_file("core_load-load_session" = save_path)
  app$click("core_load-goLoad_session")
  common <- app$get_value(export = "common")
  expect_is(common$raster, "SpatRaster")
  app$stop()
})

