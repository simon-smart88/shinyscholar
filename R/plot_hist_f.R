#' @title Extract values from a raster to produce a histogram
#' @description Called by the plot_hist module in the example app
#' and extracts values from a raster image, returning a histogram of density
#' @param raster SpatRaster object
#' @param bins The number of breaks in the histogram
#' @param palette character. The colour palette to use
#' @param name character. The name of the variable
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default NULL
#' @return a function that generates a histogram
#' @author Simon Smart <simon.smart@@cantab.net>
#' @examples
#' if (check_suggests(example = TRUE)) {
#'   raster <- terra::rast(ncol = 8, nrow = 8)
#'   raster[] <- sapply(1:terra::ncell(raster), function(x){
#'     rnorm(1, ifelse(x %% 8 != 0, x %% 8, 8), 3)})
#'   histogram <- plot_hist(raster, bins = 10, palette = "Greens", name = "Example")
#'   histogram()
#' } else {
#'   message('reinstall with install.packages("shinyscholar", dependencies = TRUE)
#'   to run this example')
#' }
#' @export

plot_hist <- function(raster, bins, palette, name, logger = NULL) {

  check_suggests()

  if (!("SpatRaster" %in% class(raster))){
    logger |> writeLog(type = "error", "The raster must be a SpatRaster")
    return()
  }

  if (!is.numeric(bins)){
    logger |> writeLog(type = "error", "bins must be numeric")
    return()
  }

  raster_values <- terra::values(raster)
  histogram <- graphics::hist(raster_values, plot = FALSE,
                              breaks = seq(min(raster_values, na.rm = TRUE),
                                           max(raster_values, na.rm = TRUE),
                                           length.out = bins + 1))
  histogram$density <- histogram$counts / sum(histogram$counts) * 100

  pal <- RColorBrewer::brewer.pal(9, palette)
  pal_ramp <- colorRampPalette(c(pal[1], pal[9]))
  hist_cols <- pal_ramp(bins)

  function(){plot(histogram, freq = F, main = "", xlab = name, ylab = "Frequency (%)", col = hist_cols)}

}
