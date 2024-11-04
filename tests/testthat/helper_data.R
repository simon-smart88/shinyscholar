is_ci <- Sys.getenv("GITHUB_ACTIONS") == "true"

if (is_ci){
  save_path <- tempfile(fileext = ".rds")
} else {
  save_path <- "~/temprds/saved_file.rds"
  if (file.exists(save_path)) {
    file.remove(save_path)
  }
}

poly_matrix <- matrix(c(0.5, 0.5, 1, 1, 0.5, 52, 52.5, 52.5, 52, 52), ncol = 2)
colnames(poly_matrix) <- c('longitude', 'latitude')

poly_matrix_large <- matrix(c(0, 0, 50, 50, 0, 10, 60, 60, 10, 10), ncol = 2)
colnames(poly_matrix_large) <- c('longitude', 'latitude')
poly_matrix_sea <- matrix(c(-20, -20, -19.5, -19.5, -20, 52, 52.5, 52.5, 52, 52), ncol=2)
colnames(poly_matrix_sea) <- c('longitude', 'latitude')

check_live <- suppressWarnings(check_url("https://ladsweb.modaps.eosdis.nasa.gov/api/v2/content/archives"))

token <- get_nasa_token(Sys.getenv("NASA_username"), Sys.getenv("NASA_password"))

retry_test <- function(test_expr, retries = 3, delay = 1) {
  attempts <- 0
  while (attempts < retries) {
    result <- tryCatch({
      test_expr()
      return(TRUE)
    }, error = function(e) {
      return(FALSE)
    })
    if (result) {
      return(TRUE)
    } else {
      attempts <- attempts + 1
      Sys.sleep(delay)
    }
  }
  stop("Test failed after multiple retries")
}
