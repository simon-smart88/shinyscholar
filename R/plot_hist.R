#' @title plot_hist
#' @description
#' This function is called by the plot_hist module and extracts
#'  values from a raster image.
#'  @param ras SpatRaster object
#' @return a vector of values extracted from the raster
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

plot_hist <- function(ras) {
  ras_values <- terra::values(ras)
  ras_values
  }
