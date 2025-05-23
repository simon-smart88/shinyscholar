test_that("Check save_and_load function returns errors as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_path <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_path, recursive = TRUE)
  file.copy(test_files, module_path, overwrite = TRUE)

  expect_error(save_and_load(123), "folder_path must be a character string")
  expect_error(save_and_load("faulty_path"), "The specified folder_path does not exist")
  expect_error(save_and_load(module_path), "No modules could be found in the specified folder")
  expect_error(save_and_load(td, "not_there"), "The module not_there does not exist")

  original <- readLines(file.path(module_path, "test_test.R"))
  insert_line <- grep("textInput\\(inputId", original)
  lines <- append(original, 'invalidInput(ns("invalid"), "Text")', insert_line)
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(save_and_load(td), "invalidInput in test_test is not currently supported")

  lines <- append(original, c('textInput(', 'ns("invalid"), "Text")'), insert_line)
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(save_and_load(td), "No inputId could could be found for textInput")

})

test_that("Check save_and_load function adds line as expected", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_directory <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_directory, recursive = TRUE)
  file.copy(test_files, module_directory)

  save_and_load(td)

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


test_that("Check save_and_load function keeps manually added lines", {

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_directory <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_directory, recursive = TRUE)
  file.copy(test_files, module_directory)

  save_and_load(td)

  temp_file <- file.path(module_directory, "test_test.R")
  r_out <- readLines(temp_file)

  save_start_line <- grep("*### Manual save start*", r_out)
  load_start_line <- grep("*### Manual load start*", r_out)

  r_out <- append(r_out, "manual_save = TRUE,", save_start_line)
  r_out <- append(r_out, "manual_load = TRUE,", load_start_line + 1) # +1 due to previous append

  writeLines(r_out, temp_file)

  save_and_load(td)

  r_out <- readLines(temp_file)

  save_start_line <- grep("*### Manual save start*", r_out)
  load_start_line <- grep("*### Manual load start*", r_out)

  expect_true(grepl('*manual_save = TRUE,*', r_out[save_start_line + 1]))
  expect_true(grepl('*manual_load = TRUE,*', r_out[load_start_line + 1]))
})

if (suggests){
  test_that("Check that lines added by save_and_load are functional", {

    skip_on_ci()
    skip_on_cran()
    withr::with_temp_libpaths({
      modules <- data.frame(
        "component" = c("test"),
        "long_component" = c("test"),
        "module" = c("test"),
        "long_module" = c("test"),
        "map" = c(FALSE),
        "result" = c(TRUE),
        "rmd" = c(TRUE),
        "save" = c(TRUE),
        "download" = c(TRUE),
        "async" = c(FALSE))

      td <- tempfile()
      dir.create(td, recursive = TRUE)
      create_template(path = td, name = "shinyscholara",
                      common_objects = c("test"), modules = modules,
                      author = "Simon E. H. Smart", include_map = FALSE,
                      include_table = FALSE, include_code = FALSE, install = TRUE)

      test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)

      module_directory <- file.path(td, "shinyscholara", "inst", "shiny", "modules")
      file.copy(test_files, module_directory, overwrite = TRUE)

      save_and_load(file.path(td, "shinyscholara"))

      # edit to use newly created core_modules
      global_path <- file.path(td, "shinyscholara", "inst", "shiny", "global.R")
      global_lines <- readLines(global_path)
      core_target <- grep("*core_modules <-*", global_lines)
      global_lines[core_target] <- 'core_modules <- c(file.path("modules", "core_intro.R"), file.path("modules", "core_load.R"), file.path("modules", "core_save.R"))'
      writeLines(global_lines, global_path)

      rerun_test("save_and_load_p1_test", list(td = td, save_path = save_path))

      common <- readRDS(save_path)

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

      app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholara", "inst", "shiny"), name = "save_and_load_test", timeout = 15000)
      app$set_inputs(introTabs = "Load Prior Session")
      app$upload_file("core_load-load_session" = save_path)
      app$click("core_load-goLoad_session")
      common <- app$get_value(export = "common")
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
      app$stop()
    })
  })
}
