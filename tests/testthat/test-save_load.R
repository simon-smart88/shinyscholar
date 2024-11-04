path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)

#this works
test_that("{shinytest2} recording: e2e_empty_save", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_empty_save")
  app$set_inputs(tabs = "select")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_path)
  expect_true(is.null(common$raster))
  app$stop()
})

#this works
test_that("{shinytest2} recording: e2e_save_scat", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_save_scat")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_path)
  common$raster <- terra::unwrap(common$raster)
  expect_is(common$raster, "SpatRaster")
  expect_is(common$scatterplot, "data.frame")
  app$stop()
})

#this may be temperamental
test_that("{shinytest2} recording: e2e_save_hist", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_save_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_path)
  common$raster <- terra::unwrap(common$raster)
  expect_is(common$raster, "SpatRaster")
  expect_is(common$histogram, "histogram")
  app$stop()
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

