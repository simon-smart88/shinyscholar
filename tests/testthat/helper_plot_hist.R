plot_hist_test <- function(raster_path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = raster_path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$set_inputs("plot_hist-pal" = "YlOrRd")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  tryCatch({app$get_download("core_save-save_session", filename = save_path)},
           finally = app$stop())
}
