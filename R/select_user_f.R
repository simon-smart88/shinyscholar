#' @title select_user
#' @description
#' This function is called by the select_user module and loads a
#'  raster image.
#'
#' @param ras_path character. Path to file to be loaded
#' @return a SpatRaster object
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

select_user <- function(ras_path) {
  check_suggests()
  raster_image <- terra::rast(ras_path)
  raster_image
}
