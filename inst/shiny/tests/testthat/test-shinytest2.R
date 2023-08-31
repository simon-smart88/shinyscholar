library(shinytest2)

# test_that("{shinytest2} recording: shiny_testatae", {
#   app <- AppDriver$new(name = "shiny_testatae", height = 909, width = 1379, shiny_args = list(test.mode = TRUE))
#   app$set_inputs(tabs = "select")
#   app$set_inputs(map_bounds = c(76.6797849031069, 154.6875, -76.6797849031069, -154.3359375),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.0568477758455, -111.402125612519, 0.589589042417624),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(42.7994313198784, -111.402125612519, 0.887008168665543),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(64.5484401442252, 21.62109375, -35.3173663292379,
#       -132.890625), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-55.6131721812593, 23.0721513101029), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 3, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.8285828030142, -109.842278147895, 0.767167174069205),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.8285828030142, -109.842278147895, 0.359131871038512),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(55.5286305225719, -44.12109375, 5.5285105256928,
#       -121.376953125), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-82.7385218864476, 34.0856493027355), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 4, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(41.0431096147577, -107.129187023432, 0.995535538208319),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(41.0431096147577, -107.129187023432, 0.922609363266076),
#       allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(48.8068634610852, -75.6298828125, 24.5271348225978,
#       -114.2578125), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-94.939105230466, 37.6474030135214), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 5, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_draw_start = "rectangle", allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.5788986029537, -103.663545233639, 0.092032196648113),
#       allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_draw_new_feature = c("Feature", 301, "rectangle", "Polygon",
#   #     c(c(-103.663545, 43.259706), c(-103.663545, 43.578899), c(-103.268185, 43.578899),
#   #         c(-103.268185, 43.259706), c(-103.663545, 43.259706))), allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_draw_all_features = c("FeatureCollection", c("Feature", 301,
#   #     "rectangle", "Polygon", c(c(-103.663545, 43.259706), c(-103.663545, 43.578899),
#   #         c(-103.268185, 43.578899), c(-103.268185, 43.259706), c(-103.663545, 43.259706)))),
#   #     allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_draw_stop = "rectangle", allow_no_input_binding_ = TRUE)
#   # app$set_inputs(selectSel = "select_query")
#   # app$click("select_query-run")
#   # app$set_inputs(map_bounds = c(43.5938194651742, -103.164367675781, 43.2447025479352,
#   #     -103.767929077148), allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_center = c(-103.465865, 43.4195128396413), allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_zoom = 11, allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_groups = c("editableFeatureGroup", "FCover"), allow_no_input_binding_ = TRUE)
#   app$expect_values()
# })
#
#
# test_that("{shinytest2} recording: shiny_testatae2", {
#   app <- AppDriver$new(name = "shiny_testatae2", height = 909, width = 1379, shiny_args = list(test.mode = TRUE))
#   app$set_inputs(tabs = "select")
#   app$set_inputs(map_bounds = c(76.6797849031069, 154.6875, -76.6797849031069, -154.3359375),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.0568477758455, -111.402125612519, 0.589589042417624),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(42.7994313198784, -111.402125612519, 0.887008168665543),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(64.5484401442252, 21.62109375, -35.3173663292379,
#                                 -132.890625), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-55.6131721812593, 23.0721513101029), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 3, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.8285828030142, -109.842278147895, 0.767167174069205),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.8285828030142, -109.842278147895, 0.359131871038512),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(55.5286305225719, -44.12109375, 5.5285105256928,
#                                 -121.376953125), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-82.7385218864476, 34.0856493027355), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 4, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(41.0431096147577, -107.129187023432, 0.995535538208319),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(41.0431096147577, -107.129187023432, 0.922609363266076),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_bounds = c(48.8068634610852, -75.6298828125, 24.5271348225978,
#                                 -114.2578125), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_center = c(-94.939105230466, 37.6474030135214), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_zoom = 5, allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_draw_start = "rectangle", allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_click = c(43.5788986029537, -103.663545233639, 0.092032196648113),
#                  allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_draw_new_feature = c("Feature", 301, "rectangle", "Polygon",
#       c(c(-103.663545, 43.259706), c(-103.663545, 43.578899), c(-103.268185, 43.578899),
#           c(-103.268185, 43.259706), c(-103.663545, 43.259706))), allow_no_input_binding_ = TRUE)
#   app$set_inputs(map_draw_all_features = c("FeatureCollection", c("Feature", 301,
#       "rectangle", "Polygon", c(c(-103.663545, 43.259706), c(-103.663545, 43.578899),
#           c(-103.268185, 43.578899), c(-103.268185, 43.259706), c(-103.663545, 43.259706)))),
#       allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_draw_stop = "rectangle", allow_no_input_binding_ = TRUE)
#   # app$set_inputs(selectSel = "select_query")
#   # app$click("select_query-run")
#   # app$set_inputs(map_bounds = c(43.5938194651742, -103.164367675781, 43.2447025479352,
#   #     -103.767929077148), allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_center = c(-103.465865, 43.4195128396413), allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_zoom = 11, allow_no_input_binding_ = TRUE)
#   # app$set_inputs(map_groups = c("editableFeatureGroup", "FCover"), allow_no_input_binding_ = TRUE)
#   app$expect_values()
# })


test_that("{shinytest2} recording: e2e_select_query2", {
  app <- AppDriver$new(name = "e2e_select_query2", height = 909, width = 1379)
  app$set_inputs(tabs = "select")
  app$set_inputs(map_bounds = c(76.6797849031069, 154.6875, -76.6797849031069, -154.3359375),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(0, 0), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 2, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_groups = "editableFeatureGroup", allow_no_input_binding_ = TRUE)
  app$set_inputs(selectSel = "select_query")
  app$set_inputs(map_click = c(46.305201055812, -108.59067510876, 0.808382837993892),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(46.305201055812, -108.59067510876, 0.598179148020135),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(65.5857200232947, 23.02734375, -33.2846199688877,
      -131.484375), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-54.2074469293802, 25.3167183719281), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 3, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7077100078673, -104.043136735773, 0.755414556105473),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7077100078673, -104.043136735773, 0.34182239312416),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(55.0280221129925, -40.517578125, 4.65307991827405,
      -117.7734375), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-79.1358261803865, 33.3546204184363), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 4, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7108329903084, -104.052818367887, 0.946305798661616),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7108329903084, -104.052818367887, 0.830318265273227),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(48.3708477023837, -72.2900390625, 23.9260130330212,
      -110.91796875), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-91.5991630901933, 37.1236438434236), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 5, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7789815947476, -105.858744662913, 0.358652292339837),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.7789815947476, -105.858744662913, 0.97997921216429),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(44.6998976584032, -89.0771484375, 32.7503226078097,
      -108.39111328125), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-98.7313742845817, 38.9756917794674), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 6, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.3792438050184, -105.290425354131, 0.249311997958909),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.3792438050184, -105.290425354131, 0.411509117267599),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(42.5773548395579, -97.18505859375, 36.6596062264797,
      -106.842041015625), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-102.012278106753, 39.6814296768719), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 7, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.3796361049073, -105.291697052065, 0.8484731389906),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.3796361049073, -105.291697052065, 0.966891441456559),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_bounds = c(41.4880060718543, -101.239013671875, 38.5438691758762,
      -106.067504882813), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_center = c(-103.652623428376, 40.031623454638), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_zoom = 8, allow_no_input_binding_ = TRUE)
  app$set_inputs(map_draw_start = "rectangle", allow_no_input_binding_ = TRUE)
  app$set_inputs(map_click = c(40.3672775610909, -105.38568184354, 0.598308529517593),
      allow_no_input_binding_ = TRUE)
  app$set_inputs(map_draw_new_feature = c("Feature", 477, "rectangle", "Polygon",
      c(c(-105.385682, 40.203854), c(-105.385682, 40.367278), c(-105.171528, 40.367278),
          c(-105.171528, 40.203854), c(-105.385682, 40.203854))), allow_no_input_binding_ = TRUE)
  app$set_inputs(map_draw_all_features = c("FeatureCollection", c("Feature", 477,
      "rectangle", "Polygon", c(c(-105.385682, 40.203854), c(-105.385682, 40.367278),
          c(-105.171528, 40.367278), c(-105.171528, 40.203854), c(-105.385682, 40.203854)))),
      allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_draw_stop = "rectangle", allow_no_input_binding_ = TRUE)
  # app$click("select_query-run")
  # app$set_inputs(map_groups = c("editableFeatureGroup", "FCover"), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_bounds = c(40.3771515003645, -105.127830505371, 40.1938233511068,
  #     -105.429611206055), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_center = c(-105.278605, 40.2856153884291), allow_no_input_binding_ = TRUE)
  # app$set_inputs(map_zoom = 12, allow_no_input_binding_ = TRUE)
  app$expect_values()
})
