plot_hist <- function(ras) {
  ras_values <- terra::values(ras)[terra::values(ras) <= 250]/2.5
  ras_values
  }
