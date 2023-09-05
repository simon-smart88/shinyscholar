poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 5, 5, 0, 52, 55, 55, 52, 52), ncol=2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')

poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix_sea) <- c('longitude', 'latitude')

test_that("Check select_query function works as expected", {

  skip_on_cran()

  result <- select_query(poly = poly_matrix,
                         date = "2023-06-20",
                         logger = NULL)

  missing_values <- length(values(result)[values(result) == 254])
  non_missing_values <- length(values(result)[values(result) <= 250])

  expect_is(result, 'SpatRaster')
  expect_equal(missing_values, 4058)
  expect_equal(non_missing_values, 17034)
})

test_that("Check select_query returns an error if the polygon is too large", {

  skip_on_cran()

  expect_error(select_query(poly = poly_matrix_large,
                            date = "2023-06-20",
                            logger = NULL),
               paste0("Your selected area is too large \\(110703 km2\\)",
                    " when the maximum is 3000 km2\\. Please select a smaller area"))
})


test_that("Check select_query returns missing values when over the sea", {

  skip_on_cran()

  expect_error(select_query(poly = poly_matrix_sea,
                            date = "2023-06-20",
                            logger = NULL),  paste0("No data was found for your selected area\\. ",
                                                    "This could be due to cloud coverage or because the area is not over land\\."))
})

source('~/Documents/wallace-disag/inst/shiny/modules/select_query.R')


# test_that("Check select_query module works correctly", {
#   # testServer(select_query_module_server, args=list(common = common), {
#   #testServer(select_query_module_server, {
#
#     app <- shinytest2::AppDriver$new("~/Documents/wallace-disag/inst/shiny")
#
#     # common_class <- R6::R6Class(
#     #   classname = "common",
#     #   public = list(
#     #     poly = NULL,
#     #     ras = NULL
#     #   )
#     # )
#     #
#     # common <- common_class$new()
#     # common$poly <- poly_matrix
#     # app$setValue()
#
#     app$set_inputs(tabs = "select")
#     app$set_inputs(selectSel = "select_query")
#     app$click("select_query-run")
#     Sys.sleep(30)
#     meta <- app$get_value(export = "meta")
#     print(meta)
#     common <- app$get_value(export = "common")
#     expect_is(common$ras, 'SpatRaster')
#     expect_equal(meta$ras$name, "FCover")
#     expect_equal(values$export$ras,NULL)
#
#
#
#   #})
# })
