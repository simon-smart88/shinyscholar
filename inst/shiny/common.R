#create common class and then initiate instance
common_class <- R6::R6Class(
  classname = "common",
  public = list(
    raster = NULL,
    histogram = NULL,
    histogram_auto = NULL,
    scatterplot = NULL,
    tasks = list(),
    meta = NULL,
    state = NULL,
    poly = NULL,
    logger = NULL
  )
)
