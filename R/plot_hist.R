#' @title plot_hist
#' @description
#' This function is called by the plot_hist module and extracts
#'  values from a raster image.
#'  @param ras SpatRaster object
#'  @param bins The number of breaks in the histogram
#' @return a vector of values extracted from the raster
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

plot_hist <- function(ras, bins) {
  ras_values <- terra::values(ras)
  h <- graphics::hist(ras_values, plot = FALSE, breaks = seq(min(ras_values, na.rm = TRUE),
                                                             max(ras_values, na.rm = TRUE),
                                                             length.out = as.numeric(bins) + 1))
  h$density <- h$counts / sum(h$counts) * 100
  h
}
