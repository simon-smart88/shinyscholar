#' @title save_and_load
#' @description Adds lines to modules to save and load input values. By default
#' all the modules in the application are edited.
#' @param folder_path character. Path to the parent directory containing the application
#' @param module character. (optional) Name of a single module to edit
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

save_and_load <- function(folder_path, module = NULL){

#function to capitalise first letter of string
firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

#locate modules to run on
module_path <- file.path(folder_path, "inst/shiny/modules/")
if (is.null(module)){
  targets <- list.files(module_path, pattern=".R$")
} else {
  targets <- c(glue::glue("{module}.R"))
}

for (target in targets){

module_name <- gsub(".R","",target)
lines <- readLines(paste0(module_path, target))

#extract lines creating input$ values
input_objects <- lines[c(grep("*Input*", lines))]
radio_objects <- lines[c(grep("*radioButtons*", lines))]
switch_objects <- lines[c(grep("*materialSwitch*", lines))]

#exclude any updateinput and fileInput lines
input_objects <- input_objects[c(grep("^(?!.*update).*$", input_objects, perl = TRUE))]
input_objects <- input_objects[c(grep("^(?!.*fileInput).*$", input_objects, perl = TRUE))]
radio_objects <- radio_objects[c(grep("^(?!.*update).*$", radio_objects, perl = TRUE))]
switch_objects <- switch_objects[c(grep("^(?!.*update).*$", switch_objects, perl = TRUE))]

#assemble all objects and add their type to use to split the line in the next step
objects <- matrix(c(input_objects,
                    radio_objects,
                    switch_objects,
                    rep("Input", length(input_objects)),
                    rep("radioButtons", length(radio_objects)),
                    rep("materialSwitch", length(switch_objects))),
                  ncol = 2)

check_for_save <- grep("*save = function()*", lines)

if ((nrow(objects) >= 1) & (length(check_for_save) == 1)){

  to_save <- list()
  to_load <- list()

  #loop through the objects and create save and load lines for each
  for (row in 1:nrow(objects)){
    split_string <- strsplit(objects[row,1], objects[row,2])[[1]]
    input_id <- strsplit(split_string[2], "\"")[[1]][2]
    save_line <- glue::glue("{input_id} = input${input_id}")
    input_type <- firstup(trimws(split_string[1]))

    if (objects[row,2] == "Input"){
      if (input_type %in% c("Checkbox", "Date", "Numeric", "Slider", "Text")){
        update_function <- glue::glue("update{input_type}Input")
        update_parameter <- "value"
      }
        if (input_type %in% c("Select", "Selectize")){
          update_function <- glue::glue("update{input_type}Input")
          update_parameter <- "selected"
          }
      }
    if (objects[row,2] == "radioButtons"){
      update_function <- "updateRadioButtons"
      update_parameter <- "selected"
    }

    if (objects[row,2] == "materialSwitch"){
      update_function <- "shinyWidgets::updateMaterialSwitch"
      update_parameter <- "value"
    }

    load_line <- glue::glue("{update_function}(session, \"{input_id}\", {update_parameter} = state${input_id})")

    to_load <- append(to_load, load_line)
    to_save <- append(to_save, save_line)

  }

  #search for insertion and closing lines, delete existing lines.
  #remove duplicated new lines, put all new lines in one object and add new lines
  insert_save_line <- grep("*save = function()*", lines)
  curly_lines <- grep("*},", lines)
  end_save_line <- min(curly_lines[curly_lines > insert_save_line])
  existing_save_lines <- seq(insert_save_line + 1, end_save_line - 1, 1)
  lines <- lines[-existing_save_lines]
  save_lines <- paste(unique(to_save), collapse = ", \n")
  save_lines <- paste0(c("list(",save_lines,")"), collapse = "")
  lines <- append(lines, save_lines, insert_save_line)

  insert_load_line <- grep("*load = function(state)*", lines)
  curly_lines <- grep("*}", lines)
  end_load_line <- min(curly_lines[curly_lines > insert_load_line])
  existing_load_lines <- seq(insert_load_line + 1, end_load_line - 1, 1)
  lines <- lines[-existing_load_lines]
  load_lines <- paste(unique(to_load), collapse = " \n")
  lines <- append(lines, load_lines, insert_load_line)

  #tidy up and template comments
  load_comment <- grep("*# Load*", lines)
  if ((length(load_comment)) != 0){
    lines <- lines[-load_comment]
  }
  save_comment <- grep("*# Save any values*", lines)
  if ((length(save_comment)) != 0){
    lines <- lines[-save_comment]
  }

  writeLines(lines, file.path(module_path, target))
}
}
}
