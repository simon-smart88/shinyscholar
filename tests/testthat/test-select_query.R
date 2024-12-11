if (!no_suggests){
  test_that("Check select_query function works as expected", {
    skip_on_ci()
    skip_on_cran()
    if (!is.null(check_live)){
      result <- select_query(poly = poly_matrix,
                             date = "2023-06-20",
                             token = token,
                             logger = NULL)

      missing_values <- length(terra::values(result)[terra::values(result) > 1])
      non_missing_values <- length(terra::values(result)[terra::values(result) < 1])

      expect_is(result, "SpatRaster")
      expect_gt(missing_values, 2000)
      expect_gt(non_missing_values, 100)

      expect_error(select_query("poly", date = "2023-06-20", token = token), "poly must be a matrix")
      expect_error(select_query(poly_matrix, date = "2023-16-20", token = token), "date must be a string with the format YYYY")
      expect_error(select_query(poly_matrix, date = 2023, token = token), "date must be a string with the format YYYY")
      expect_error(select_query(poly_matrix, date = "2023-06-20", token = NULL), "This function requires a NASA token")
      expect_error(select_query(poly_matrix, date = "2023-06-20", token = "not_a_token"), "This function requires a NASA token")

    } else {
      expect_error(select_query(poly = poly_matrix,
                               date = "2023-06-20",
                               token = token,
                               logger = NULL), "The FAPAR API is currently offline")
    }

  })

  test_that("Check select_query returns an error if the polygon is too large", {
    skip_on_ci()
    skip_on_cran()
    expect_error(select_query(poly = poly_matrix_large,
                              date = "2023-06-20",
                              token = token,
                              logger = NULL),
                 paste0("Your selected area is too large \\(24592760 km2\\)",
                      " when the maximum is 1m km2\\. Please select a smaller area"))
  })


  test_that("Check select_query returns missing values when over the sea", {
    skip_on_ci()
    skip_on_cran()
    if (!is.null(check_live)){
      expect_error(select_query(poly = poly_matrix_sea,
                                date = "2023-06-20",
                                token = token,
                                logger = NULL),  paste0("No data was found for your selected area\\. ",
                                                        "This could be due to cloud coverage or because the area is not over land\\."))
    }
  })

  test_that("{shinytest2} recording: e2e_select_query", {
    skip_on_ci()
    skip_on_cran()
    if (!is.null(check_live)){
      rerun_test("select_query_test", list(save_path = save_path))
      common <- readRDS(save_path)
      common$raster <- terra::unwrap(common$raster)
      expect_equal(is.null(common$poly), FALSE)
      expect_is(common$raster, "SpatRaster")
      expect_equal(common$meta$select_query$name, "FAPAR")
    }
  })
}
