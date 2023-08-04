plot_scatter <- function(ras,sample,axis) {
  set.seed(12345)
  globalland_ras <- clamp(ras, upper=250, value=FALSE)
  samp <- spatSample(ras,sample,method='random',xy=T,as.df=T)
  colnames(samp)[3] <- 'value'
  samp <- samp[,c(axis,'value')]
  samp
}
