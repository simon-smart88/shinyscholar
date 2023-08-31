library(testthat)

context("Query data")

poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 5, 5, 0, 52, 55, 55, 52, 52), ncol=2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')

test_that("Check select_query function works as expected", {

  skip_on_cran()

  result <- select_query(poly = poly_matrix,
                         date = "2023-06-20",
                         logger = NULL)

  expect_is(result, 'SpatRaster')

})


test_that("Check select_query returns an error if the polygon is too large", {

  skip_on_cran()

  expect_error(select_query(poly = poly_matrix_large,
                            date = "2023-06-20",
                            logger = NULL), NULL)
               #"Your selected area is too large (110703 km2) when the maximum is 3000 km2. Please select a smaller area")
})

