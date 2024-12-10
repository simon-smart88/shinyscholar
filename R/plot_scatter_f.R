#' @title plot_scatter
#' @description
#' This function is called by the plot_scatter module and samples
#'  values from a raster along with either the x or y coordinates
#'  of the points sampled
#' @param raster SpatRaster. Raster to be sampled
#' @param sample numeric. Number of points to sample
#' @param axis character. Which axis coordinates of the raster to return
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default NULL
#' @return a dataframe containing the axis values and the cell values
#' @author Simon Smart <simon.smart@@cantab.net>
#' @examples
#' if (check_suggests(example = TRUE)) {
#'   raster <- terra::rast(ncol = 8, nrow = 8)
#'   raster[] <- sapply(1:terra::ncell(raster), function(x){
#'      rnorm(1, ifelse(x %% 8 != 0, x %% 8, 8), 3)})
#'   scatterplot <- plot_scatter(raster, sample = 10, axis = "y")
#' } else {
#'   message('reinstall with install.packages("shinyscholar", dependencies = TRUE)
#'   to run this example')
#' }
#' @export
plot_scatter <- function(raster, sample, axis, logger = NULL) {

  check_suggests()

  if (!("SpatRaster" %in% class(raster))){
    logger %>% writeLog(type = "error", "The raster must be a SpatRaster")
    return()
  }

  if (!is.numeric(sample)){
    logger %>% writeLog(type = "error", "sample must be numeric")
    return()
  }

  if (!(axis %in% c("x", "y"))){
    logger %>% writeLog(type = "error", "axis must be either x or y")
    return()
  }

  samp <- terra::spatSample(raster, sample, method = "random", xy = TRUE, as.df = TRUE)
  colnames(samp)[3] <- "value"
  samp[, c(axis, "value")]

}
