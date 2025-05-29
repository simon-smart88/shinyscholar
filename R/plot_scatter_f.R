#' @title Extract values from a raster to produce a scatterplot
#' @description Called by the plot_scatter module in the example app and samples
#'  values from a raster along with either the x or y coordinates of the points
#'  sampled
#' @param raster SpatRaster. Raster to be sampled
#' @param sample numeric. Number of points to sample
#' @param axis character. Which axis coordinates of the raster to return
#' @param name character. The name of the raster variable
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default NULL
#' @return a function that generates a scatterplot
#' @author Simon Smart <simon.smart@@cantab.net>
#' @examples
#' if (check_suggests(example = TRUE)) {
#'   raster <- terra::rast(ncol = 8, nrow = 8)
#'   raster[] <- sapply(1:terra::ncell(raster), function(x){
#'      rnorm(1, ifelse(x %% 8 != 0, x %% 8, 8), 3)})
#'   scatterplot <- plot_scatter(raster, sample = 10, axis = "Longitude", name = "Example")
#'   scatterplot()
#' } else {
#'   message('reinstall with install.packages("shinyscholar", dependencies = TRUE)
#'   to run this example')
#' }
#' @export
plot_scatter <- function(raster, sample, axis, name, logger = NULL) {

  check_suggests()

  if (!inherits(raster, "SpatRaster")){
    logger |> writeLog(type = "error", "The raster must be a SpatRaster")
    return()
  }

  if (!is.numeric(sample)){
    logger |> writeLog(type = "error", "sample must be numeric")
    return()
  }

  if (!inherits(axis, "character")){
    logger |> writeLog(type = "error", "axis must be a character string")
    return()
  }

  if (!(axis %in% c("Longitude", "Latitude"))){
    logger |> writeLog(type = "error", "axis must be either Longitude or Latitude")
    return()
  }

  if (!inherits(name, "character")){
    logger |> writeLog(type = "error", "name must be a character string")
    return()
  }

  if (axis == "Longitude"){short_axis <- "x"} else {short_axis <- "y"}

  sampled <- terra::spatSample(raster, sample, method = "random", xy = TRUE, as.df = TRUE)
  colnames(sampled)[3] <- "value"
  sampled <-sampled[, c(short_axis, "value")]

  function(){plot(sampled[[1]], sampled[[2]], xlab = axis, ylab = name)}


}
