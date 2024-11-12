is_ci <- Sys.getenv("GITHUB_ACTIONS") == "true"

if (is_ci){
  save_path <- tempfile(fileext = ".rds")
} else {
  save_path <- "~/temprds/saved_file.rds"
  if (file.exists(save_path)) {
    file.remove(save_path)
  }
}

poly_matrix <- matrix(c(0.5, 0.5, 1, 1, 0.5, 52, 52.5, 52.5, 52, 52), ncol = 2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 50, 50, 0, 10, 60, 60, 10, 10), ncol = 2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')
poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix_sea) <- c('longitude', 'latitude')

check_live <- suppressWarnings(check_url("https://ladsweb.modaps.eosdis.nasa.gov/api/v2/content/archives"))

token <- get_nasa_token(Sys.getenv("NASA_username"), Sys.getenv("NASA_password"))

rerun_test <- function(test_function, args){
  attempt <- 0
  while(attempt < 5){
    x = try(do.call(test_function, args))
    if ("try-error" %in% class(x)) {
      attempt <- attempt + 1
      print(paste0(test_function, " setup failed - retrying"))
    } else {
      break
    }
  }
}

empty_save_test <- function(save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_empty_save")
  app$set_inputs(tabs = "select")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}

save_hist_test <- function(path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_save_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}

save_scat_test <- function(path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_save_scat")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}

plot_hist_test <- function(path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_hist")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_hist")
  app$set_inputs("plot_hist-pal" = "YlOrRd")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}


plot_scatter_test <- function(path, save_path){
  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_scatter")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file("select_user-raster" = path)
  app$set_inputs("select_user-name" = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}

save_and_load_p1_test <- function(td, save_path){
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
  app$get_download("core_save-save_session", filename = save_path)
  app$stop()
}



