test_that("Check select_async function works as expected", {
  if (!is.null(check_live)){
    result <- select_async(poly = poly_matrix,
                           date = "2023-06-20",
                           token = token)

    missing_values <- length(terra::values(result$raster)[terra::values(result$raster) > 1])
    non_missing_values <- length(terra::values(result$raster)[terra::values(result$raster) < 1])

    expect_is(result$raster, 'SpatRaster')

    expect_gt(missing_values, 2000)
    expect_gt(non_missing_values, 100)
  } else {
    expect_error(select_query(poly = poly_matrix,
                              date = "2023-06-20",
                              token = token), "The FAPAR API is currently offline")
  }
})

test_that("Check select_async returns an error if the polygon is too large", {

  expect_error(select_async(poly = poly_matrix_large,
                            date = "2023-06-20",
                            token = token),
               paste0("Your selected area is too large \\(24592760 km2\\)",
                      " when the maximum is 1m km2\\. Please select a smaller area"))
})


test_that("Check select_async returns missing values when over the sea", {
  if (!is.null(check_live)){
  expect_error(select_async(poly = poly_matrix_sea,
                            date = "2023-06-20",
                            token = token),
               paste0("No data was found for your selected area\\. ",
                   "This could be due to cloud coverage or because the area is not over land\\."))
  }
})

test_that("{shinytest2} recording: e2e_select_query", {
  if (!is.null(check_live)){
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_async", timeout = 60000)
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_async")
    app$click(selector = "#select_async-run")
    app$wait_for_value(input = "select_async-complete")
    app$set_inputs(main = "Save")
    app$get_download("core_save-save_session", filename = save_path)
    common <- readRDS(save_path)
    common$ras <- terra::unwrap(common$ras)
    expect_equal(is.null(common$poly), FALSE)
    expect_is(common$ras, 'SpatRaster')
    expect_equal(common$meta$select_async$name, "FAPAR")
    app$stop()
  }
})
