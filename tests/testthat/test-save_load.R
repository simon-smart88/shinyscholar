path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

save_path <- list.files(system.file("extdata", package = "SMART"),
                   pattern = ".rds$", full.names = TRUE)

#this works
test_that("{shinytest2} recording: e2e_empty_save", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_empty_save")
  app$set_inputs(tabs = "select")
  app$set_inputs(main = "Save")
  save_file <- app$get_download("save_session")
  common <- readRDS(save_file)
  expect_true(is.null(common$ras))
})

#this works
test_that("{shinytest2} recording: e2e_save_scat", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_save_scat")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  save_file <- app$get_download("save_session")
  common <- readRDS(save_file)
  common$ras <- terra::unwrap(common$ras)
  expect_is(common$ras, 'SpatRaster')
  expect_is(common$scat, 'data.frame')
})

#this may be temperamental
test_that("{shinytest2} recording: e2e_save_hist", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_save_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  save_file <- app$get_download("save_session")
  common <- readRDS(save_file)
  common$ras <- terra::unwrap(common$ras)
  expect_is(common$ras, 'SpatRaster')
  expect_is(common$hist, 'histogram')
})

test_that("{shinytest2} recording: e2e_load", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_load")
  app$set_inputs(introTabs = "Load Prior Session")
  app$upload_file(load_session = save_path)
  app$click("goLoad_session")
  common <- app$get_value(export = "common")
  expect_is(common$ras, 'SpatRaster')
})


