poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 5, 5, 0, 52, 55, 55, 52, 52), ncol=2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')

poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix_sea) <- c('longitude', 'latitude')

check_live <- suppressWarnings(check_url("https://viewer.globalland.vgt.vito.be"))

test_that("Check select_query function works as expected", {

  if (!is.null(check_live)){
    result <- select_query(poly = poly_matrix,
                           date = "2023-06-20",
                           logger = NULL)

    missing_values <- length(terra::values(result)[terra::values(result) == 254])
    non_missing_values <- length(terra::values(result)[terra::values(result) <= 250])

    expect_is(result, 'SpatRaster')
    expect_gt(missing_values, 2000)
    expect_gt(non_missing_values, 10000)
  } else {
    expect_error(select_query(poly = poly_matrix,
                             date = "2023-06-20",
                             logger = NULL), "The FCover API is currently offline")
  }

})

test_that("Check select_query returns an error if the polygon is too large", {

  expect_error(select_query(poly = poly_matrix_large,
                            date = "2023-06-20",
                            logger = NULL),
               paste0("Your selected area is too large \\(110703 km2\\)",
                    " when the maximum is 10000 km2\\. Please select a smaller area"))
})


test_that("Check select_query returns missing values when over the sea", {
  if (!is.null(check_live)){
    expect_error(select_query(poly = poly_matrix_sea,
                              date = "2023-06-20",
                              logger = NULL),  paste0("No data was found for your selected area\\. ",
                                                      "This could be due to cloud coverage or because the area is not over land\\."))
  }
})

test_that("{shinytest2} recording: e2e_select_query", {
  if (!is.null(check_live)){
    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_query", timeout = 20000)
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_query")
    app$click("select_query-run")
    app$wait_for_idle(duration = 10000)
    app$set_inputs(main = "Save")
    save_file <- app$get_download("core_save-save_session", filename = save_path)
    common <- readRDS(save_file)
    common$ras <- terra::unwrap(common$ras)
    expect_equal(is.null(common$poly), FALSE)
    expect_is(common$ras, 'SpatRaster')
    expect_equal(common$meta$select_query$name, "FCover")
  }
})

