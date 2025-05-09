test_that("Check check_suggests function works as expected", {
  if (suggests){
    expect_no_error(check_suggests())
    expect_false(check_suggests(testing = TRUE, example = TRUE))
  }
  if (!suggests){
    expect_error(check_suggests(testing = TRUE))
    if (!is_local){
      expect_error(check_suggests())
      expect_false(check_suggests(example = TRUE))
    }
  }
})

