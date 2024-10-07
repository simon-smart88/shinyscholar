path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)
ras <- terra::rast(path)
sample <- 1000
axis <- "y"

test_that("Check plot_scatter function works as expected", {

  result <- plot_scatter(ras, sample, axis)

  expect_is(result, "data.frame")
  expect_equal(colnames(result)[1], "y")
  expect_equal(is.numeric(result$value), TRUE)
  expect_equal(nrow(result), 1000)

})

test_that("{shinytest2} recording: e2e_plot_scatter", {

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_scatter")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-ras" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_path)
  expect_is(common$scat, "data.frame")
  app$stop()
})
