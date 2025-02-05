select_user_test <- function(raster_path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_user")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = raster_path)
  app$set_inputs("select_user-name" = "test")
  app$click("select_user-run")
  app$set_inputs(main = "Save")
  tryCatch({app$get_download("core_save-save_session", filename = save_path)},
           finally = app$stop())
}

select_user_test_enter <- function(raster_path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_user")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = raster_path)
  app$set_inputs("select_user-name" = "test")
  app$run_js('
    var event = new KeyboardEvent("keydown", { keyCode: 13 });
    document.dispatchEvent(event);
  ')
  app$wait_for_value(input = "select_user-complete")
  app$set_inputs(main = "Save")
  tryCatch({app$get_download("core_save-save_session", filename = save_path)},
           finally = app$stop())
}
