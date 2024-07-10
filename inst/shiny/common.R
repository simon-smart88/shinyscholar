#create common class and then initiate instance
common_class <- R6::R6Class(
  classname = "common",
  public = list(
    ras = NULL,
    hist = NULL,
    scat = NULL,
    tasks = list(),
    meta = NULL,
    state = NULL,
    poly = NULL,
    logger = NULL
  )
)
