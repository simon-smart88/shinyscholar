library(shinytest2)


path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

test_that("{shinytest2} recording: e2e_select_user", {
  app <- shinytest2::AppDriver$new(name = "e2e_select_user")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "test")
  app$click("select_user-run")
  common <- app$get_value(export = "common")
  expect_is(common$ras, 'SpatRaster')
})

test_that("{shinytest2} recording: e2e_select_query", {
  app <- shinytest2::AppDriver$new(name = "e2e_select_query")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_query")
  app$click("select_query-run")
  common <- app$get_value(export = "common")
  expect_equal(is.null(common$poly), FALSE)
  expect_is(common$ras, 'SpatRaster')
  expect_equal(common$meta$ras$name, "FCover")
})


test_that("{shinytest2} recording: e2e_plot_hist", {
  app <- shinytest2::AppDriver$new(name = "e2e_plot_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$set_inputs(`plot_hist-pal` = "YlOrRd")
  app$click("plot_hist-run")
  common <- app$get_value(export = "common")
  expect_is(common$hist, 'histogram')
})

test_that("{shinytest2} recording: e2e_plot_scatter", {
  app <- shinytest2::AppDriver$new(name = "e2e_plot_scatter")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  common <- app$get_value(export = "common")
  expect_is(common$scat, 'data.frame')
})
