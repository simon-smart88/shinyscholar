test_that("Check metadata function adds lines as expected", {

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
  expect_true(any(grepl("*common\\$meta\\$test_test\\$switch <- input\\$switch*", r_out)))

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
  expect_true(any(grepl("*switch = common\\$meta\\$test_test\\$switch,*", r_out)))

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
  expect_true(any(grepl("*\\{\\{switch\\}\\}*", rmd_out)))
})

test_that("Check metadata function returns errors as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempdir()
  dir.create(file.path(td, "inst/shiny/modules/"), recursive = TRUE)
  file.copy(test_files, file.path(td, "inst/shiny/modules/"))

  lines <- readLines(file.path(td, "inst/shiny/modules", "test_test.R"))
  rmd_func_line <- grep("*module_rmd <- function(common)*", lines)
  lines <- lines[-rmd_func_line]
  writeLines(lines, file.path(td, "inst/shiny/modules", "test_test.R"))
  expect_warning(shinyscholar::metadata(td), "The test_test_module_rmd function could not be located")

  file.copy(test_files, file.path(td, "inst/shiny/modules/"), overwrite = TRUE)
  lines <- readLines(file.path(td, "inst/shiny/modules", "test_test.R"))
  metadata_line <- grep("*# METADATA ####*", lines)
  lines <- lines[-metadata_line]
  writeLines(lines, file.path(td, "inst/shiny/modules", "test_test.R"))
  expect_warning(shinyscholar::metadata(td), "No # METADATA #### line could be located in test_test")

  file.copy(test_files, file.path(td, "inst/shiny/modules/"), overwrite = TRUE)
  lines <- readLines(file.path(td, "inst/shiny/modules", "test_test.R"))
  metadata_line <- grep("*# METADATA ####*", lines)
  lines <- append(lines, "common$meta$test <- input$test", metadata_line)
  writeLines(lines, file.path(td, "inst/shiny/modules", "test_test.R"))
  expect_warning(shinyscholar::metadata(td), "metadata lines are already present in test_test")
})

test_that("Check that lines added by metadata are functional", {

  upload_path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                     pattern = ".tif$", full.names = TRUE)

  modules <- data.frame(
    "component" = c("test"),
    "long_component" = c("test"),
    "module" = c("test"),
    "long_module" = c("test"),
    "map" = c(TRUE),
    "result" = c(TRUE),
    "rmd" = c(TRUE),
    "save" = c(TRUE),
    "async" = c(FALSE))

  td <- tempdir()
  #the name must be shinyscholar so that the calls to package files work
  create_template(path = td, name = "shinyscholar",
                  include_map = FALSE, include_table = FALSE, include_code = FALSE,
                  common_objects = c("test"), modules = modules,
                  author = "Simon E. H. Smart", install = FALSE)

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  file.copy(test_files, file.path(td, "shinyscholar/inst/shiny/modules/"), overwrite = TRUE)

  shinyscholar::save_and_load(file.path(td, "shinyscholar"))

  # edit to use newly created core_modules
  global_lines <- readLines(file.path(td, "shinyscholar/inst/shiny/global.R"))
  core_line <- grep("*core_modules <-*", global_lines)
  global_lines[core_line] <- glue::glue('core_modules <- file.path("modules", list.files(file.path("{td}", "shinyscholar/inst/shiny/modules"), pattern="core_*"))')
  writeLines(global_lines, file.path(td, "shinyscholar/inst/shiny/global.R"))

  app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholar/inst/shiny/"), name = "save_and_load_test")
  app$set_inputs(tabs = "test")
  app$set_inputs(testSel = "test_test")
  app$set_inputs("test_test-checkbox" = FALSE)
  app$set_inputs("test_test-checkboxgroup" = "B")
  app$set_inputs("test_test-date" = "2024-01-01")
  app$set_inputs("test_test-daterange" = c("2024-01-01", "2024-01-02"))
  app$set_inputs("test_test-numeric" = 6)
  app$set_inputs("test_test-radio" = "B")
  app$set_inputs("test_test-select" = "B")
  app$set_inputs("test_test-slider" = 6)
  app$set_inputs("test_test-text" = "test")
  app$set_inputs("test_test-single_quote" = "test")
  app$set_inputs("test_test-switch" = FALSE)
  # #upload for file
  # app$upload_file("test_test-file" = upload_path)

})
