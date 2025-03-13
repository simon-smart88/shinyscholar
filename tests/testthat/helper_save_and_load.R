save_and_load_p1_test <- function(td, save_path){
  app <- shinytest2::AppDriver$new(app_dir = file.path(td, "shinyscholara", "inst", "shiny"), name = "save_and_load_test")
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
  common <- app$get_value(export = "common")
  tryCatch({app$get_download("core_save-save_session", filename = save_path)},
           finally = app$stop())
}

