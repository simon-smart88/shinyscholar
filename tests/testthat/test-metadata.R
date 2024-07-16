test_that("Check metadata function works as expected", {

  #copy from inst to tempdir
  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempdir()
  dir.create(file.path(td, "inst/shiny/modules/"), recursive = TRUE)
  file.copy(test_files, file.path(td, "inst/shiny/modules/"))

  shinyscholar::metadata(td)

  r_out <- readLines(file.path(td, "inst/shiny/modules/test_test.R"))
  rmd_out <- readLines(file.path(td, "inst/shiny/modules/test_test.Rmd"))

  expect_true(any(grepl("*common\\$meta\\$test_test\\$used <- TRUE*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$checkbox <- input\\$checkbox*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$checkboxgroup <- input\\$checkboxgroup*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$date <- input\\$date*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$daterange <- input\\$daterange*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$file <- input\\$file\\$name*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$numeric <- as.numeric(input\\$numeric)*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$radio <- input\\$radio*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$select <- input\\$select*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$slider <- as.numeric(input\\$slider)*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$text <- input\\$text*", r_out)))
  expect_true(any(grepl("*common\\$meta\\$test_test\\$single_quote <- input\\$single_quote*", r_out)))

  expect_true(any(grepl("*test_test_knit = !is.null\\(common\\$meta\\$test_test\\$used\\),*", r_out)))
  expect_true(any(grepl("*checkbox = common\\$meta\\$test_test\\$checkbox,*", r_out)))
  expect_true(any(grepl("*checkboxgroup = common\\$meta\\$test_test\\$checkboxgroup,*", r_out)))
  expect_true(any(grepl("*date = common\\$meta\\$test_test\\$date,*", r_out)))
  expect_true(any(grepl("*daterange = common\\$meta\\$test_test\\$daterange,*", r_out)))
  expect_true(any(grepl("*file = common\\$meta\\$test_test\\$file,*", r_out)))
  expect_true(any(grepl("*numeric = common\\$meta\\$test_test\\$numeric,*", r_out)))
  expect_true(any(grepl("*radio = common\\$meta\\$test_test\\$radio,*", r_out)))
  expect_true(any(grepl("*select = common\\$meta\\$test_test\\$select,*", r_out)))
  expect_true(any(grepl("*slider = common\\$meta\\$test_test\\$slider,*", r_out)))
  expect_true(any(grepl("*text = common\\$meta\\$test_test\\$text,*", r_out)))
  expect_true(any(grepl("*single_quote = common\\$meta\\$test_test\\$single_quote,*", r_out)))

  expect_true(any(grepl("*\\{\\{checkbox\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{checkboxgroup\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{date\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{daterange\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\"\\{\\{file\\}\\}\\"*', rmd_out)))
  expect_true(any(grepl("*\\{\\{numeric\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{radio\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\"\\{\\{select\\}\\}\\"*', rmd_out)))
  expect_true(any(grepl("*\\{\\{slider\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\"\\{\\{text\\}\\}\\"*', rmd_out)))
  expect_true(any(grepl('*\\"\\{\\{single_quote\\}\\}\\"*', rmd_out)))

})

