#' @title Add metadata lines to modules
#' @description Adds lines to modules and their associated rmarkdown files to
#' semi-automate reproducibility. By default all the modules in the application
#' are edited or you can specify a single module. If metadata lines are already
#' present, the file will not be edited. This function is currently experimental
#' and only semi-automates the process. To ensure that the code is functional
#' complete the following steps:
#' \itemize{
#'  \item Check that any inputs created by packages other than 'shiny' are included
#'  \item Add any inputs created dynamically i.e. those without an explicit
#'  line of code to generate them, for example those created inside a loop in a
#'  `renderUI` or from a 'leaflet' or 'DT' object.
#'  \item Use the objects in each `.Rmd` file to call the module's function.
#'  }
#' @param folder_path character. Path to the parent directory containing the application
#' @param module character. (optional) Name of a single module to edit
#' @returns No return value, called for side effects
#' @examples
#' td <- tempfile()
#' dir.create(td, recursive = TRUE)
#'
#' modules <- data.frame(
#'   "component" = c("demo"),
#'   "long_component" = c("demo"),
#'   "module" = c("demo"),
#'   "long_module" = c("demo"),
#'   "map" = c(FALSE),
#'   "result" = c(TRUE),
#'   "rmd" = c(TRUE),
#'   "save" = c(TRUE),
#'   "async" = c(FALSE))
#'
#' create_template(path = td, name = "demo",
#'                 common_objects = c("demo"), modules = modules,
#'                 author = "demo", include_map = FALSE,
#'                 include_table = FALSE, include_code = FALSE, install = FALSE)
#'
#' test_files <- list.files(
#'   system.file("extdata", package = "shinyscholar"),
#'   pattern = "test_test*", full.names = TRUE)
#'
#' module_directory <- file.path(td, "demo", "inst", "shiny", "modules")
#' file.copy(test_files, module_directory, overwrite = TRUE)
#'
#' metadata(file.path(td, "demo"), module = "test_test")
#'
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

metadata <- function(folder_path, module = NULL){

  if (!is.character(folder_path)){
    stop("folder_path must be a character string")
  }

  if (!dir.exists(folder_path)){
    stop("The specified folder_path does not exist")
  }

  message("This function only semi-automates this process - see the documentation
            for information on manual steps you need to complete.")

  # locate modules to run on
  module_path <- file.path(folder_path, "inst", "shiny", "modules")

  if (!dir.exists(module_path)){
    stop("No modules could be found in the specified folder")
  }

  if (is.null(module)){
    targets <- list.files(module_path, pattern = ".R$")
    # exclude core and rep modules
    if (length(grep("(core_|rep_)", targets) > 0)){
      targets <- targets[-grep("(core_|rep_)", targets)]
    }
  } else {
    targets <- glue::glue("{module}.R")
  }

  for (target in targets){

    module_name <- gsub(".R","",target)

    if (!file.exists(file.path(module_path, target))){
      stop("The specified module does not exist")
    }

    lines <- readLines(file.path(module_path, target))

    # extract lines creating input$ values while excluding any updateinput or setInputValue lines
    input_objects <- lines[c(grep("^(?!.*(update|setInputValue)).*Input", lines, perl = TRUE))]
    radio_objects <- lines[c(grep("^(?!.*update).*radioButtons", lines, perl = TRUE))]
    switch_objects <- lines[c(grep("^(?!.*update).*materialSwitch", lines, perl = TRUE))]

    # assemble all objects and add their type to use to split the line in the next step
    objects <- matrix(c(input_objects,
                        radio_objects,
                        switch_objects,
                        rep("Input", length(input_objects)),
                        rep("radioButtons", length(radio_objects)),
                        rep("materialSwitch", length(switch_objects))),
                      ncol = 2)

    meta_start <- grep("*# METADATA ####*", lines)
    rmd_func_start <- grep("*module_rmd <- function(common)*", lines)
    check_for_existing <- grep("*common\\$meta*", lines)

    if (length(rmd_func_start) == 0){
      warning(glue::glue("The {module_name}_module_rmd function could not be located"))
      next
    }

    if (length(meta_start) == 0){
      warning(glue::glue("No # METADATA #### line could be located in {module_name}"))
      next
    }

    if ((length(check_for_existing) > 0) && (length(meta_start) > 0)){
      warning(glue::glue("metadata lines are already present in {module_name}"))
      next
    }

    if ((nrow(objects) >= 1) && (length(meta_start == 1)) && (length(rmd_func_start == 1)) && (length(check_for_existing) == 0)){
      to_server <- list()
      to_rmd_func <- list()
      to_rmd_file <- list()

      to_server <- append(to_server, glue::glue("      common$meta${module_name}$used <- TRUE"))
      to_rmd_func <- append(to_rmd_func, glue::glue("  {module_name}_knit = !is.null(common$meta${module_name}$used)"))

      # loop through the objects and create lines in the module server, rmd function and rmd file for each
      for (row in 1:nrow(objects)){
        split_string <- strsplit(objects[row,1], objects[row,2])[[1]]
        input_id <- strsplit(split_string[2], "\"")[[1]][2]
        if (is.na(input_id)){
          input_id <- strsplit(split_string[2], "'")[[1]][2]
        }
        if (is.na(input_id)){
          warning(glue::glue("No inputId could could be found for {objects[row,1]}) in {module_name} - make sure it is on the same line"))
          next
        }
        input_type <- trimws(split_string[1])

        # wrap numeric values and use $name column of fileInputs
        if ((objects[row,2] == "Input") && (input_type %in% c("numeric", "slider"))){
          server_line <- glue::glue("common$meta${module_name}${input_id} <- as.numeric(input${input_id})")
        } else if ((objects[row,2] == "Input") && (input_type == "file")){
          server_line <- glue::glue("common$meta${module_name}${input_id} <- input${input_id}$name")
        } else {
          server_line <- glue::glue("common$meta${module_name}${input_id} <- input${input_id}")
        }

        rmd_func_line <- glue::glue("{module_name}_{input_id} = common$meta${module_name}${input_id}")

        rmd_file_line <- glue::glue("{{{{{module_name}_{input_id}}}}}")

        to_server <- append(to_server, server_line)
        to_rmd_func <- append(to_rmd_func, rmd_func_line)
        to_rmd_file <- append(to_rmd_file, rmd_file_line)

      }
    }

    server_lines <- paste(unique(to_server), collapse = " \n      ")
    rmd_func_lines <- paste(unique(to_rmd_func), collapse = ", \n  ")
    rmd_func_lines  <- paste0(c(rmd_func_lines,")"), collapse = "")
    rmd_file_lines <- paste(unique(to_rmd_file), collapse = "\n")

    rmd_file <- paste0(target, "md")
    rmd_lines <- readLines(file.path(module_path, rmd_file))
    rmd_target <- paste0("* echo = \\{\\{",module_name,"_knit\\}\\}, include = \\{\\{",module_name,"_knit\\}\\}*")
    rmd_file_start <- grep(rmd_target, rmd_lines)

    lines <- append(lines, server_lines, meta_start)
    rmd_func_start <- grep("*module_rmd <- function(common)*", lines) #update after insert
    lines[rmd_func_start] <- glue::glue("{module_name}_module_rmd <- function(common){{ list(")
    lines <- append(lines, rmd_func_lines, rmd_func_start)
    rmd_lines <- append(rmd_lines, rmd_file_lines, rmd_file_start)

    writeLines(lines, file.path(module_path, target))
    writeLines(rmd_lines, file.path(module_path, rmd_file))
  }
}
