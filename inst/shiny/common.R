#create common class and then initiate instance
common_class <- R6::R6Class(
  classname = "common",
  public = list(
    raster = NULL,
    histogram = NULL,
    histogram_auto = NULL,
    histogram_semi = NULL,
    scatterplot = NULL,
    tasks = list(),
    meta = NULL,
    state = NULL,
    poly = NULL,
    logger = NULL,
    reset = function(){
      self$raster = NULL
      self$histogram = NULL
      self$histogram_auto = NULL
      self$histogram_semi = NULL
      self$scatterplot = NULL
      self$meta = NULL
      self$state = NULL
      self$poly = NULL
      invisible(self)
    }
  )
)
