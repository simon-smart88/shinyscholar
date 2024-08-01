path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)
ras <- terra::rast(path)
bins <- 20

test_that("Check plot_hist function works as expected", {

  result <- plot_hist(ras, bins)

  expect_is(result, "histogram")
  expect_equal(length(result$mids), 20)
  expect_equal(sum(result$density), 100)

})

test_that("{shinytest2} recording: e2e_plot_hist", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-ras" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$set_inputs("plot_hist-pal" = "YlOrRd")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  save_file <- app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_file)
  expect_is(common$hist, "histogram")
  app$stop()
})
