#' @title Register a shinyscholar module
#' @description Currently disabled as cannot be used with apps created by shinyscholar.
#' Before running the shinyscholar application with
#' \code{run_shinyscholar()}, you can register your own modules to be used in
#' shinyscholar.
#' @param config_file The path to a YAML file that contains the information about
#' one or more modules.
#' @returns No return value, called for side effects
#' @seealso \code{\link[shinyscholar]{create_module}}
#' @export
register_module <- function(config_file) {

  stop("This function is not yet developed for use with apps created by shinyscholar")

  full_path <- NULL
  tryCatch({
    full_path <- normalizePath(path = config_file, mustWork = TRUE)
  }, error = function(e) {})

  if (is.null(full_path)) {
    stop("Cannot find the given file: ", config_file, call. = FALSE)
  }
  if (tools::file_ext(full_path) != "yml") {
    stop("The provided file is not a YAML file: ", config_file, call. = FALSE)
  }

  new_paths <- unique(c(getOption("shinyscholar_module_configs"), full_path))
  options("shinyscholar_module_configs" = new_paths)
}

#' @title Create a shinyscholar module
#' @description Create the template of a new shinyscholar module.
#' @param id character. The id of the module.
#' @param dir character. Path to the parent directory containing the application
#' @param map logical. Whether or not the module should support modifying the map.
#' @param result logical. Whether or not the module should support showing information in
#' the Result tab.
#' @param rmd logical. Whether or not the module should add Rmd code to the Session Code
#' download.
#' @param save logical. Whether or not the module has some custom data to save when the
#' user saves the current session.
#' @param download logical. Whether or not the module should add code to handle downloading
#' a file.
#' @param async logical. Whether or not the module will operate asynchronously.
#' @param init logical. Whether or not the function is being used inside of the init function
#' @returns No return value, called for side effects
#' @seealso \code{\link[shinyscholar]{register_module}}
#' @export
create_module <- function(id, dir, map = FALSE, result = FALSE, rmd = FALSE, save = FALSE, download = FALSE, async = FALSE, init = FALSE) {
  if (!grepl("^[A-Za-z0-9_]+$", id)) {
    stop("The id can only contain English characters, digits, and underscores",
         call. = FALSE)
  }

  if (file.exists(file.path(dir, glue::glue("{id}.R")))){
    stop("A module with that name already exists", call. = FALSE)
  }

  module_dir <- file.path(dir, "inst", "shiny", "modules")

  if (!dir.exists(module_dir)){
    stop("No modules could be found in the specified folder")
  }

  # only create the yml when not created with init() which otherwise creates it
  if (!init){
  file.copy(system.file("module_skeleton", "skeleton.yml", package = "shinyscholar"),
            file.path(module_dir, glue::glue("{id}.yml")), overwrite = TRUE)
  }
  file.copy(system.file("module_skeleton", "skeleton.md", package = "shinyscholar"),
            file.path(module_dir, glue::glue("{id}.md")), overwrite = TRUE)

  if (rmd) {
    file.copy(system.file("module_skeleton", "skeleton.Rmd", package = "shinyscholar"),
              file.path(module_dir, glue::glue("{id}.Rmd")), overwrite = TRUE)
    # add the module ID
    rmd_file <- readLines(file.path(module_dir, glue::glue("{id}.Rmd")))
    rmd_file <- gsub("moduleID_knit", glue::glue("{id}_knit"), rmd_file)
    writeLines(rmd_file, file.path(module_dir, glue::glue("{id}.Rmd")))
  }

  # create the main module file with the custom options
  if (!async){
    r_file <- system.file("module_skeleton", "skeletonR.Rmd", package = "shinyscholar")
  } else {
    r_file <- system.file("module_skeleton", "skeleton_asyncR.Rmd", package = "shinyscholar")
  }

  module_params <- c(file = r_file,
                     list(id = id,
                          map = map,
                          result = result,
                          rmd = rmd,
                          save = save,
                          download = download))
  module_lines <- tidy_purl(module_params)
  writeLines(module_lines, file.path(module_dir, glue::glue("{id}.R")))

  # create empty function
  empty_function <- paste0(id," <- function(x){return(NULL)}")
  writeLines(empty_function, file.path(dir, "R", paste0(id, "_f.R")))

  # create test
  desc <- readLines(file.path(dir, "DESCRIPTION"))
  app_library <- sub("Package: ", "", desc[1])
  common <- readLines(file.path(dir, "inst", "shiny", "common.R"))
  common_object <- sub("\\s*(\\w+)\\s*=.*", "\\1", common[5])

  test_params <- c(
    file = system.file("app_skeleton", "test.Rmd", package = "shinyscholar"),
    list(app_library = app_library,
         component = sub("_.*", "", id),
         module = id,
         common_object = common_object)
  )

  test_lines <- tidy_purl(test_params)
  writeLines(test_lines, file.path(dir, "tests", "testthat", paste0("test-", id, ".R")))

  if (!init){
  message(glue::glue("Template for module `{id}` successfully created at ",
                     "`{normalizePath(module_dir)}`."))
  }
  invisible()
}
