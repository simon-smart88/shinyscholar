poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 5, 5, 0, 52, 55, 55, 52, 52), ncol=2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')

poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix_sea) <- c('longitude', 'latitude')

check_live <- suppressWarnings(check_url("https://viewer.globalland.vgt.vito.be"))

test_that("Check select_async function works as expected", {
  if (!is.null(check_live)){
    result <- select_async(poly = poly_matrix,
                           date = "2023-06-20")

    missing_values <- length(terra::values(result$raster)[terra::values(result$raster) == 254])
    non_missing_values <- length(terra::values(result$raster)[terra::values(result$raster) <= 250])

    expect_is(result$raster, 'SpatRaster')
    expect_gt(missing_values, 2000)
    expect_gt(non_missing_values, 10000)
  } else {
    expect_error(select_query(poly = poly_matrix,
                              date = "2023-06-20",
                              logger = NULL), "The FCover API is currently offline")
  }
})

test_that("Check select_async returns an error if the polygon is too large", {

  expect_error(select_async(poly = poly_matrix_large,
                            date = "2023-06-20"),
               paste0("Your selected area is too large \\(110703 km2\\)",
                      " when the maximum is 10000 km2\\. Please select a smaller area"))
})


test_that("Check select_async returns missing values when over the sea", {
  if (!is.null(check_live)){
  expect_error(select_async(poly = poly_matrix_sea,
                            date = "2023-06-20"),
               paste0("No data was found for your selected area\\. ",
                   "This could be due to cloud coverage or because the area is not over land\\."))
  }
})

test_that("{shinytest2} recording: e2e_select_query", {
  if (!is.null(check_live)){
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_async", timeout = 20000)
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_async")
    app$click(selector = "#select_async-run")
    app$wait_for_value(input = "select_async-complete")
    app$set_inputs(main = "Save")
    save_file <- app$get_download("core_save-save_session", filename = save_path)
    common <- readRDS(save_file)
    common$ras <- terra::unwrap(common$ras)
    expect_equal(is.null(common$poly), FALSE)
    expect_is(common$ras, 'SpatRaster')
    expect_equal(common$meta$select_async$name, "FCover")
    app$stop()
  }
})
