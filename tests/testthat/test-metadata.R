test_that("Check metadata function returns errors as expected", {

  expect_error(metadata(123), "folder_path must be a character string")
  expect_error(metadata("faulty_path"), "The specified folder_path does not exist")
  expect_error(metadata("~"), "No modules could be found in the specified folder")

  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_path <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_path, recursive = TRUE)
  file.copy(test_files, module_path, overwrite = TRUE)

  expect_error(metadata(td, "not_there"), "The specified module does not exist")

  original <- readLines(file.path(module_path, "test_test.R"))
  rmd_func_line <- grep("*module_rmd <- function(common)*", original)
  lines <- original[-rmd_func_line]
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(metadata(td), "The test_test_module_rmd function could not be located")

  metadata_line <- grep("*# METADATA ####*", original)
  lines <- original[-metadata_line]
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(metadata(td), "No # METADATA #### line could be located in test_test")

  insert_line <- grep("textInput\\(inputId", original)
  lines <- append(original, c('textInput(', 'ns("invalid"), "Text")'), insert_line)
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(save_and_load(td), "No inputId could could be found for textInput")

  metadata_line <- grep("*# METADATA ####*", original)
  lines <- append(original, "common$meta$test <- input$test", metadata_line)
  writeLines(lines, file.path(module_path, "test_test.R"))
  expect_warning(metadata(td), "metadata lines are already present in test_test")
})

test_that("Check metadata function adds lines as expected", {
  test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
  td <- tempfile()
  dir.create(td, recursive = TRUE)
  module_path <- file.path(td, "inst", "shiny", "modules")
  dir.create(module_path, recursive = TRUE, showWarnings = FALSE)
  file.copy(test_files, module_path, overwrite = TRUE)

  shinyscholar::metadata(td)

  r_out <- readLines(file.path(module_path, "test_test.R"))
  rmd_out <- readLines(file.path(module_path, "test_test.Rmd"))

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

if (suggests){
  test_that("Check that lines added by metadata are functional", {

    skip_if(Sys.which("pandoc") == "")
    skip_if(is_fedora())

    withr::with_temp_libpaths({
      upload_path <- list.files(system.file("extdata", "wc", package = "shinyscholar"),
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
      name <- "shinyscholara"

      create_template(path = td, name = name,
                      common_objects = c("test"), modules = modules,
                      author = "Simon E. H. Smart", include_map = FALSE,
                      include_table = FALSE, include_code = FALSE, install = FALSE)

      devtools::document(file.path(td, name))
      devtools::install(file.path(td, name), force = TRUE, quick = TRUE, dependencies = FALSE)

      test_files <- list.files(system.file("extdata", package = "shinyscholar"), pattern = "test_test*", full.names = TRUE)
      shiny_path <- file.path(td, name, "inst", "shiny")
      file.copy(test_files, file.path(shiny_path, "modules"), overwrite = TRUE)

      metadata(file.path(td, name))

      app <- shinytest2::AppDriver$new(app_dir = shiny_path, name = "e2e_metadata_test")
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
      app$stop()

      expect_false(is.null(sess_file))
      lines <- readLines(sess_file)
      start_line <- grep("```\\{r\\}", lines)[2]
      expect_equal(lines[start_line + 1], "TRUE")
      expect_equal(lines[start_line + 2], "\"A\"")
      expect_equal(lines[start_line + 3], "structure(19723, class = \"Date\")")
      expect_equal(lines[start_line + 4], "structure(c(19723, 19724), class = \"Date\")")
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
  })
}
