test_that("Check select_query function works as expected", {

  if (!is.null(check_live)){
    result <- select_query(poly = poly_matrix,
                           date = "2023-06-20",
                           token = token,
                           logger = NULL)

    missing_values <- length(terra::values(result)[terra::values(result) > 1])
    non_missing_values <- length(terra::values(result)[terra::values(result) < 1])

    expect_is(result, 'SpatRaster')
    expect_gt(missing_values, 2000)
    expect_gt(non_missing_values, 100)
  } else {
    expect_error(select_query(poly = poly_matrix,
                             date = "2023-06-20",
                             token = token,
                             logger = NULL), "The FCover API is currently offline")
  }

})

test_that("Check select_query returns an error if the polygon is too large", {

  expect_error(select_query(poly = poly_matrix_large,
                            date = "2023-06-20",
                            token = token,
                            logger = NULL),
               paste0("Your selected area is too large \\(24592760 km2\\)",
                    " when the maximum is 1m km2\\. Please select a smaller area"))
})


test_that("Check select_query returns missing values when over the sea", {
  if (!is.null(check_live)){
    expect_error(select_query(poly = poly_matrix_sea,
                              date = "2023-06-20",
                              token = token,
                              logger = NULL),  paste0("No data was found for your selected area\\. ",
                                                      "This could be due to cloud coverage or because the area is not over land\\."))
  }
})

test_that("{shinytest2} recording: e2e_select_query", {
  if (!is.null(check_live)){
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_query", timeout = 60000)
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_query")
    app$click("select_query-run")
    app$set_inputs(main = "Save")
    app$get_download("core_save-save_session", filename = save_path)
    common <- readRDS(save_path)
    common$ras <- terra::unwrap(common$ras)
    expect_equal(is.null(common$poly), FALSE)
    expect_is(common$ras, 'SpatRaster')
    expect_equal(common$meta$select_query$name, "FAPAR")
    app$stop()
  }
})

