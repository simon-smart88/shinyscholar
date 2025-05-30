is_local <- Sys.getenv("local") == "true"

if (is_local){
  save_path <- "~/temprds/saved_file.rds"
  if (file.exists(save_path)) {
    file.remove(save_path)
  }
} else {
  save_path <- tempfile(fileext = ".rds")
}

is_fedora <- function() {
  sys_info <- Sys.info()
  if (sys_info["sysname"] == "Linux") {
    os_release <- tryCatch(
      {
        readLines("/etc/os-release")
      },
      error = function(e) {
        return(NULL)
      }
    )
    if (!is.null(os_release)) {
      id_line <- grep("^ID=", os_release, value = TRUE)
      if (length(id_line) > 0 && grepl("fedora", id_line, ignore.case = TRUE)) {
        return(TRUE)
      }
    }
  }
  return(FALSE)
}

rerun_test <- function(test_function, args){
  attempt <- 0
  while(attempt < 10){
    x = try(do.call(test_function, args))
    if ("try-error" %in% class(x)) {
      attempt <- attempt + 1
      print(paste0(test_function, " setup failed - retrying"))
    } else {
      break
    }
  }
}

# flag to check whether --no-suggests is being used
suggests <- check_suggests(example = TRUE)

if (suggests){
  poly_matrix <- matrix(c(0.5, 0.5, 1, 1, 0.5, 52, 52.5, 52.5, 52, 52), ncol = 2)
  colnames(poly_matrix) <- c('longitude', 'latitude')

  poly_matrix_large <- matrix(c(0, 0, 50, 50, 0, 10, 60, 60, 10, 10), ncol = 2)
  colnames(poly_matrix_large) <- c('longitude', 'latitude')
  poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
  colnames(poly_matrix_sea) <- c('longitude', 'latitude')

  if (is_local){
    check_live <- suppressWarnings(check_url("https://ladsweb.modaps.eosdis.nasa.gov/api/v2/content/archives"))
    token <- get_nasa_token(Sys.getenv("NASA_username"), Sys.getenv("NASA_password"))
  }

  raster_path <- list.files(system.file("extdata", "wc", package = "shinyscholar"),
                     full.names = TRUE)
  raster <- terra::rast(raster_path)
}
