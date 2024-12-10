test_that("Check check_suggests function works as expected", {
  if (!no_suggests){
    expect_no_error(check_suggests())
  }
  if (no_suggests){
    expect_error(check_suggests(testing = TRUE))
    if (!is_local){
      expect_error(check_suggests())
    }
  }
})

