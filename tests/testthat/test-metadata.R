test_that("Check metadata function adds lines as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  dir.create(file.path(td, "inst/shiny/modules/"), recursive = TRUE, showWarnings = FALSE)
  file.copy(test_files, file.path(td, "inst/shiny/modules/"), overwrite = TRUE)


  # locate modules to run on
  module_path <- file.path(td, "inst/shiny/modules/")
    targets <- list.files(module_path, pattern=".R$")
    # exclude core and rep modules
    targets <- targets[-grep("(core_|rep_)", targets)]
    print(targets)

    grep("(core_|rep_)", targets)

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
  expect_true(any(grepl("*test_test_checkbox = common\\$meta\\$test_test\\$checkbox,*", r_out)))
  expect_true(any(grepl("*test_test_checkboxgroup = common\\$meta\\$test_test\\$checkboxgroup,*", r_out)))
  expect_true(any(grepl("*test_test_date = common\\$meta\\$test_test\\$date,*", r_out)))
  expect_true(any(grepl("*test_test_daterange = common\\$meta\\$test_test\\$daterange,*", r_out)))
  expect_true(any(grepl("*test_test_file = common\\$meta\\$test_test\\$file,*", r_out)))
  expect_true(any(grepl("*test_test_numeric = common\\$meta\\$test_test\\$numeric,*", r_out)))
  expect_true(any(grepl("*test_test_radio = common\\$meta\\$test_test\\$radio,*", r_out)))
  expect_true(any(grepl("*test_test_select = common\\$meta\\$test_test\\$select,*", r_out)))
  expect_true(any(grepl("*test_test_slider = common\\$meta\\$test_test\\$slider,*", r_out)))
  expect_true(any(grepl("*test_test_text = common\\$meta\\$test_test\\$text,*", r_out)))
  expect_true(any(grepl("*test_test_single_quote = common\\$meta\\$test_test\\$single_quote,*", r_out)))
  expect_true(any(grepl("*test_test_switch = common\\$meta\\$test_test\\$switch,*", r_out)))

  expect_true(any(grepl("*\\{\\{test_test_checkbox\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_checkboxgroup\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_date\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_daterange\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\{\\{test_test_file\\}\\}*', rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_numeric\\}\\}*", rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_radio\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\{\\{test_test_select\\}\\}*', rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_slider\\}\\}*", rmd_out)))
  expect_true(any(grepl('*\\{\\{test_test_text\\}\\}*', rmd_out)))
  expect_true(any(grepl('*\\{\\{test_test_single_quote\\}\\}*', rmd_out)))
  expect_true(any(grepl("*\\{\\{test_test_switch\\}\\}*", rmd_out)))
})

test_that("Check metadata function returns errors as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  dir.create(file.path(td, "inst/shiny/modules/"), recursive = TRUE)
  file.copy(test_files, file.path(td, "inst/shiny/modules/"), overwrite = TRUE)

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

  td <- tempfile()
  dir.create(td, recursive = TRUE)
  #the name must be shinyscholar so that the calls to package files work
  create_template(path = td, name = "shinyscholar",
                  include_map = FALSE, include_table = FALSE, include_code = FALSE,
                  common_objects = c("test"), modules = modules,
                  author = "Simon E. H. Smart", install = FALSE)

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  file.copy(test_files, file.path(td, "shinyscholar/inst/shiny/modules/"), overwrite = TRUE)

  shinyscholar::metadata(file.path(td, "shinyscholar"))

  # edit to use newly created core_modules
  global_lines <- readLines(file.path(td, "shinyscholar/inst/shiny/global.R"))
  core_line <- grep("*core_modules <-*", global_lines)
  global_lines[core_line] <- glue::glue('core_modules <- file.path("modules", list.files(file.path("{td}", "shinyscholar/inst/shiny/modules"), pattern="core_*"))')
  writeLines(global_lines, file.path(td, "shinyscholar/inst/shiny/global.R"))

  app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholar/inst/shiny/"), name = "save_and_load_test")
  app$set_inputs(tabs = "test")
  app$set_inputs(testSel = "test_test")
  app$set_inputs("test_test-checkbox" = TRUE)
  app$set_inputs("test_test-checkboxgroup" = "A")
  app$set_inputs("test_test-date" = "2024-01-01")
  app$set_inputs("test_test-daterange" = c("2024-01-01", "2024-01-02"))
  app$set_inputs("test_test-numeric" = 4)
  app$set_inputs("test_test-radio" = "B")
  app$set_inputs("test_test-select" = "C")
  app$set_inputs("test_test-slider" = 6)
  app$set_inputs("test_test-text" = "test1")
  app$set_inputs("test_test-single_quote" = "test2")
  app$set_inputs("test_test-inputid" = "test3")
  app$set_inputs("test_test-switch" = FALSE)
  #upload for file
  app$upload_file("test_test-file" = upload_path)
  app$click("test_test-run")

  app$set_inputs(tabs = "rep")
  app$set_inputs(repSel = "rep_markdown")
  sess_file <- app$get_download("rep_markdown-dlRMD")
  expect_false(is.null(sess_file))
  lines <- readLines(sess_file)

  start_line <- grep("```\\{r\\}", lines)[2]
  expect_equal(lines[start_line + 1], "TRUE")
  expect_equal(lines[start_line + 2], "\"A\"")
  expect_equal(lines[start_line + 3], "as.Date(\"2024-01-01\")")
  expect_equal(lines[start_line + 4], "c(as.Date(\"2024-01-01\"), as.Date(\"2024-01-02\"))")
  expect_equal(lines[start_line + 5], "\"bio05.tif\"")
  expect_equal(lines[start_line + 6], "4")
  expect_equal(lines[start_line + 7], "\"C\"")
  expect_equal(lines[start_line + 8], "6")
  expect_equal(lines[start_line + 9], "\"test1\"")
  expect_equal(lines[start_line + 10], "\"test2\"")
  expect_equal(lines[start_line + 11], "\"test3\"")
  expect_equal(lines[start_line + 12], "\"B\"")
  expect_equal(lines[start_line + 13], "FALSE")

})
