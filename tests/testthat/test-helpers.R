
test_that("Check check_url functions as expected", {
  expect_null(check_url("https://www.a-very-stupid-and-silly-website.com/"))
  expect_is(check_url("https://www.google.com"), "httr2_response")
})
