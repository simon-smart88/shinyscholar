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
#   app$set_inputs(`select_user-name` = "tes")
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
  app <- AppDriver$new(name = "e2e_select_query", height = 909, width = 1379)
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
  app$set_inputs(map_draw_all_features = c("FeatureCollection", c("Feature", 624,
      "rectangle", "Polygon", c(c(-1.859381, 52.033868), c(-1.859381, 52.093812),
          c(-1.381654, 52.093812), c(-1.381654, 52.033868), c(-1.859381, 52.033868)))),
      allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_draw_stop = "rectangle", allow_no_input_binding_ = TRUE)
  # app$click("select_query-run")
  # app$set_inputs(map_groups = c("editableFeatureGroup", "FCover"), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_bounds = c(52.2113935120449, -1.31904602050781, 51.9158970021463,
  #     -1.922607421875), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_center = c(-1.62051749999999, 52.0638500569615), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_zoom = 11, allow_no_input_binding_ = TRUE)
  app$expect_values()
})
