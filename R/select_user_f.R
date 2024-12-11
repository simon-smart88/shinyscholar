#' @title select_user
#' @description
#' This function is called by the select_user module and loads a
#'  .tif file as a SpatRaster
#'
#' @param raster_path character. Path to file to be loaded
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default NULL
#' @return a SpatRaster object
#' @author Simon Smart <simon.smart@@cantab.net>
#' @examples
#' if (check_suggests(example = TRUE)) {
#'   raster_path <- list.files(system.file("extdata", "wc", package = "shinyscholar"),
#'   full.names = TRUE)
#'   raster <- select_user(raster_path)
#' } else {
#'   message('reinstall with install.packages("shinyscholar", dependencies = TRUE)
#'   to run this example')
#' }
#' @export

select_user <- function(raster_path, logger = NULL) {

  check_suggests()

  if (!file.exists(raster_path)) {
    logger %>% writeLog(type = "error", "The specified raster does not exist")
    return()
  }

  if (tools::file_ext(raster_path) != "tif") {
    logger %>% writeLog(type = "error", "The raster must be a .tif")
    return()
  }

  terra::rast(raster_path)
}
