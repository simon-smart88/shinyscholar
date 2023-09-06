library(shinytest2)


path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

# test_that("{shinytest2} recording: e2e_select_user", {
#   app <- AppDriver$new(name = "e2e_select_user", height = 909, width = 1379)
#   app$set_inputs(tabs = "select")
#   app$set_inputs(map_bounds = c(76.6797849031069, 154.6875, -76.6797849031069, -154.3359375),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
#   app$set_inputs(selectSel = "select_user")
#   app$upload_file(`select_user-ras` = path)
#   app$set_inputs(`select_user-name` = "test")
#   app$click("select_user-run")
#   app$set_inputs(map_groups = c("editableFeatureGroup", "test"), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(-3.11857621678199, 66.3134765625, -32.0639555946604,
#       27.685546875), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(47, -18.1830505923617), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 5, allow_no_input_binding_ = TRUE)
#   app$expect_values()
# })


test_that("{shinytest2} recording: e2e_select_query", {
  app <- shinytest2::AppDriver$new(name = "e2e_select_query", height = 909, width = 1379)
  app$set_inputs(tabs = "select")
  app$set_inputs(map_bounds = c(76.6797849031069, 154.6875, -76.6797849031069, -154.3359375),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
  app$set_inputs(selectSel = "select_query")
  app$set_inputs(map_draw_new_feature = c("Feature", 624, "rectangle", "Polygon",
      c(c(-1.859381, 52.033868), c(-1.859381, 52.093812), c(-1.381654, 52.093812),
          c(-1.381654, 52.033868), c(-1.859381, 52.033868))), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_draw_stop = "rectangle", allow_no_input_binding_ = TRUE)
  app$click("select_query-run")
  #Sys.sleep(20)
  ras <- app$get_value(export = "common")
  print(ras)
  expect_equal(is.null(ras), FALSE)
})




# test_that("{shinytest2} recording: click_all", {
#   app <- AppDriver$new(name = "click_all", height = 714, width = 899)
#   app$set_inputs(tabs = "select")
#   app$set_inputs(map_bounds = c(76.6797849031069, 98.4375, -76.6797849031069, -98.0859375),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
#   app$set_inputs(selectSel = "select_query")
#   app$set_inputs(selectSel = "select_user")
#   app$set_inputs(tabs = "plot")
#   app$set_inputs(plotSel = "plot_hist")
#   app$set_inputs(plotSel = "plot_scatter")
#   app$set_inputs(tabs = "rep")
#   app$set_inputs(repSel = "rep_markdown")
#   app$set_inputs(repSel = "rep_refPackages")
#   app$set_inputs(tabs = "select")
#   app$set_inputs(main = "Table")
#   app$set_inputs(main = "Results")
#   app$set_inputs(main = "Component Guidance")
#   app$set_inputs(main = "Module Guidance")
#   app$set_inputs(main = "Code")
#   app$set_inputs(main = "Save")
#   app$expect_values()
# })
#
# test_that("{shinytest2} recording: e2e_plot_hist", {
#   app <- AppDriver$new(name = "e2e_plot_hist", height = 714, width = 899)
#   app$set_inputs(tabs = "select")
#   app$set_inputs(map_bounds = c(76.6797849031069, 98.4375, -76.6797849031069, -98.0859375),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
#   app$set_inputs(selectSel = "select_user")
#   app$upload_file(`select_user-ras` = path)
#   app$set_inputs(`select_user-name` = "bio")
#   app$click("select_user-run")
#   app$set_inputs(map_groups = c("editableFeatureGroup", "bio"), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(11.092165893502, -56.953125, -19.2281767377662, -81.5185546875),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(tabs = "plot")
#   app$set_inputs(plotSel = "plot_hist")
#   app$set_inputs(`plot_hist-pal` = "YlOrRd")
#   app$click("plot_hist-run")
#   app$expect_values()
# })
