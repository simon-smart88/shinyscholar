#' @title plot_scatter
#' @description
#' This function is called by the plot_scatter module and samples
#'  values from a raster
#'  @param ras SpatRaster object. Image to be analysed
#'  @param sample numeric. Number of points to sample
#'  @param axis character.
#' @return a dataframe containing the axis values and the cell values
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export
plot_scatter <- function(ras,sample,axis) {
  set.seed(12345)
  samp <- terra::spatSample(ras,sample,method='random',xy=T,as.df=T)
  colnames(samp)[3] <- 'value'
  samp <- samp[,c(axis,'value')]
  samp
}
