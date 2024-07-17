is_ci <- Sys.getenv("GITHUB_ACTIONS") == "true"

if (is_ci){
  save_path <- tempfile(fileext = ".rds")
} else {
  save_path <- "~/temprds/saved_file.rds"
  if (file.exists(save_path)) {
    file.remove(save_path)
  }
}
