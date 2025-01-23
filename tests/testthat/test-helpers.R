if (suggests){
  test_that("Check check_url functions as expected", {
    expect_warning(check_url("https://www.a-very-stupid-and-silly-website.com/"), "https://www.a-very-stupid-and-silly-website.com/ is offline")
    expect_is(check_url("https://www.google.com"), "httr2_response")
  })
}

test_that("Check asyncLog functions as expected", {
  expect_error(asyncLog(FALSE, "message", type = "error"), "message")
  expect_warning(asyncLog(FALSE, "message", type = "warning"), "message")
  expect_equal(asyncLog(TRUE, "message", type = "error"), "message")
})

test_that("Check printVecAsis function works as expected", {
  expect_equal(printVecAsis(1) , 1)
  expect_equal(printVecAsis("a") , "\"a\"")
  expect_equal(printVecAsis(c(1, 2, 3)) , "c(1, 2, 3)")
  expect_equal(printVecAsis(c("a", "b", "c")) , "c(\"a\", \"b\", \"c\")")
  expect_equal(printVecAsis(NULL) , "NULL")

  date_in <- as.Date("2025-01-01")
  date_out <- eval(parse(text=printVecAsis(date_in)))
  expect_identical(date_in, date_out)
})
