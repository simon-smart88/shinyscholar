select_query_test <- function(save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_select_query", timeout = 60000)
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_query")
  app$click("select_query-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}
