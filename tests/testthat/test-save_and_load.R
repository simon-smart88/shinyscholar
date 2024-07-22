test_that("Check metadata function adds line as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_directory <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_directory, recursive = TRUE)
  file.copy(test_files, module_directory)

  shinyscholar::save_and_load(td)

  temp_file <- file.path(module_directory, "test_test.R")
  r_out <- readLines(temp_file)

  expect_true(any(grepl("*checkbox = input\\$checkbox*", r_out)))
  expect_true(any(grepl("*checkboxgroup = input\\$checkboxgroup*", r_out)))
  expect_true(any(grepl("*date = input\\$date*", r_out)))
  expect_true(any(grepl("*daterange = input\\$daterange*", r_out)))
  expect_true(any(grepl("*numeric = input\\$numeric*", r_out)))
  expect_true(any(grepl("*radio = input\\$radio*", r_out)))
  expect_true(any(grepl("*select = input\\$select*", r_out)))
  expect_true(any(grepl("*slider = input\\$slider*", r_out)))
  expect_true(any(grepl("*text = input\\$text*", r_out)))
  expect_true(any(grepl("*single_quote = input\\$single_quote*", r_out)))
  expect_true(any(grepl("*switch = input\\$switch*", r_out)))
  expect_true(any(grepl("*inputid = input\\$inputid*", r_out)))

  expect_true(any(grepl('*updateCheckboxInput\\(session, "checkbox", value = state\\$checkbox*', r_out)))
  expect_true(any(grepl('*updateCheckboxGroupInput\\(session, "checkboxgroup", selected = state\\$checkboxgroup*', r_out)))
  expect_true(any(grepl('*updateDateInput\\(session, "date", value = state\\$date*', r_out)))
  expect_true(any(grepl('*updateDateRangeInput\\(session, "daterange", start = state\\$daterange\\[1\\], end = state\\$daterange\\[2\\]*', r_out)))
  expect_true(any(grepl('*updateNumericInput\\(session, "numeric", value = state\\$numeric)*', r_out)))
  expect_true(any(grepl('*updateRadioButtons\\(session, "radio", selected = state\\$radio)*', r_out)))
  expect_true(any(grepl('*updateSelectInput\\(session, "select", selected = state\\$select)*', r_out)))
  expect_true(any(grepl('*updateSliderInput\\(session, "slider", value = state\\$slider)*', r_out)))
  expect_true(any(grepl('*updateTextInput\\(session, "text", value = state\\$text)*', r_out)))
  expect_true(any(grepl('*updateTextInput\\(session, "single_quote", value = state\\$single_quote)*', r_out)))
  expect_true(any(grepl('*shinyWidgets::updateMaterialSwitch\\(session, "switch", value = state\\$switch)*', r_out)))
  expect_true(any(grepl('*updateTextInput\\(session, "inputid", value = state\\$inputid)*', r_out)))

  expect_true(any(grepl("*### Manual load start*", r_out)))
  expect_true(any(grepl("*### Manual load end*", r_out)))
  expect_true(any(grepl("*### Manual save start*", r_out)))
  expect_true(any(grepl("*### Manual save end*", r_out)))

  meta_start_line <- grep("*# METADATA*", r_out)
  save_start_line <- grep("*### Manual save start*", r_out)
  load_start_line <- grep("*### Manual load start*", r_out)

  expect_gt(save_start_line, meta_start_line)
  expect_gt(load_start_line, save_start_line)

  expect_true(grepl("*save = function\\(\\) \\{list\\(*", r_out[save_start_line-1]))
  expect_true(grepl("*load = function\\(state\\) \\{*", r_out[load_start_line-1]))
})


test_that("Check metadata function keeps manually added lines", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_directory <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_directory, recursive = TRUE)
  file.copy(test_files, module_directory)

  shinyscholar::save_and_load(td)

  temp_file <- file.path(module_directory, "test_test.R")
  r_out <- readLines(temp_file)

  save_start_line <- grep("*### Manual save start*", r_out)
  load_start_line <- grep("*### Manual load start*", r_out)

  r_out <- append(r_out, "manual_save = TRUE,", save_start_line)
  r_out <- append(r_out, "manual_load = TRUE,", load_start_line + 1) # +1 due to previous append

  writeLines(r_out, temp_file)

  shinyscholar::save_and_load(td)

  r_out <- readLines(temp_file)

  save_start_line <- grep("*### Manual save start*", r_out)
  load_start_line <- grep("*### Manual load start*", r_out)

  expect_true(grepl('*manual_save = TRUE,*', r_out[save_start_line + 1]))
  expect_true(grepl('*manual_load = TRUE,*', r_out[load_start_line + 1]))
})

test_that("Check that lines added by save_and_load are functional", {

  skip_on_ci()

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

  module_directory <- file.path(td, "shinyscholar", "inst", "shiny", "modules")
  file.copy(test_files, module_directory, overwrite = TRUE)

  shinyscholar::save_and_load(file.path(td, "shinyscholar"))

  # edit to use newly created core_modules
  global_path <- file.path(td, "shinyscholar", "inst", "shiny", "global.R")
  global_lines <- readLines(global_path)
  core_line <- grep("*core_modules <-*", global_lines)
  global_lines[core_line] <- glue::glue('core_modules <- file.path("modules", list.files(file.path("{td}", "shinyscholar", "inst", "shiny", "modules"), pattern="core_*"))')
  writeLines(global_lines, global_path)

  app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholar", "inst", "shiny"), name = "save_and_load_test")
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

  app$set_inputs(main = "Save")
  save_file <- app$get_download("core_save-save_session", filename = save_path)
  common <- readRDS(save_file)

  expect_equal(common$state$test_test$checkbox, FALSE)
  expect_equal(common$state$test_test$checkboxgroup, "B")
  expect_equal(common$state$test_test$date, as.Date("2024-01-01"))
  expect_equal(common$state$test_test$daterange, c(as.Date("2024-01-01"), as.Date("2024-01-02")))
  expect_equal(common$state$test_test$numeric, 6)
  expect_equal(common$state$test_test$radio, "B")
  expect_equal(common$state$test_test$select, "B")
  expect_equal(common$state$test_test$slider, 6)
  expect_equal(common$state$test_test$text, "test")
  expect_equal(common$state$test_test$single_quote, "test")
  expect_equal(common$state$test_test$switch, FALSE)

  app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholar", "inst", "shiny"), name = "save_and_load_test")
  app$set_inputs(introTabs = "Load Prior Session")
  app$upload_file("core_load-load_session" = save_path)
  app$click("core_load-goLoad_session")
  loaded_values <- app$get_values()

  expect_equal(loaded_values$input[["test_test-checkbox"]], FALSE)
  expect_equal(loaded_values$input[["test_test-checkboxgroup"]], "B")
  expect_equal(loaded_values$input[["test_test-date"]], as.Date("2024-01-01"))
  expect_equal(loaded_values$input[["test_test-daterange"]], c(as.Date("2024-01-01"), as.Date("2024-01-02")))
  expect_equal(loaded_values$input[["test_test-numeric"]], 6)
  expect_equal(loaded_values$input[["test_test-radio"]], "B")
  expect_equal(loaded_values$input[["test_test-select"]], "B")
  expect_equal(loaded_values$input[["test_test-slider"]], 6)
  expect_equal(loaded_values$input[["test_test-text"]], "test")
  expect_equal(loaded_values$input[["test_test-single_quote"]], "test")
  expect_equal(loaded_values$input[["test_test-switch"]], FALSE)


})
