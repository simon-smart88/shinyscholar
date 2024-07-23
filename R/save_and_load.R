#' @title save_and_load
#' @description Adds lines to modules to save and load input values. By default
#' all the modules in the application are edited. Currently only input
#' functions from `{shiny}` and `shinyWidgets::materialSwitch` are included.
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
module_path <- file.path(folder_path, "inst", "shiny", "modules")
if (is.null(module)){
  targets <- list.files(module_path, pattern=".R$")
} else {
  targets <- glue::glue("{module}.R")
}

for (target in targets){

  module_name <- gsub(".R","",target)
  lines <- readLines(file.path(module_path, target))

  ##extract lines creating input$ values while excluding any updateinput, fileInput or setInputValue lines
  input_objects <- lines[c(grep("^(?!.*(update|fileInput|setInputValue)).*Input", lines, perl = TRUE))]
  radio_objects <- lines[c(grep("^(?!.*update).*radioButtons", lines, perl = TRUE))]
  switch_objects <- lines[c(grep("^(?!.*update).*materialSwitch", lines, perl = TRUE))]

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
      if (is.na(input_id)){
        input_id <- strsplit(split_string[2], "'")[[1]][2]
      }
      if (is.na(input_id)){
        warning(glue::glue("No inputId could could be found for {objects[row,1]} in {target}"))
        next
      }
      save_line <- glue::glue("{input_id} = input${input_id}")
      input_type <- firstup(trimws(split_string[1]))

      if (objects[row,2] == "Input"){
        if (input_type %in% c("Checkbox", "Date", "Numeric", "Slider", "Text")){
          update_function <- glue::glue("update{input_type}Input")
          update_parameter <- "value"
        }
        else if (input_type %in% c("CheckboxGroup", "Select", "Selectize")){
          update_function <- glue::glue("update{input_type}Input")
          update_parameter <- "selected"
        }
        else if (input_type %in% c("DateRange")){
          # handle this later on
        }
        else {
          warning(glue::glue("{input_type}Input in {target} is not currently supported - please add this manually"))
          next
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

      if ((objects[row,2] == "Input") & (input_type == "DateRange")){
        load_line <- glue::glue("updateDateRangeInput(session, \"{input_id}\", start = state${input_id}[1], end = state${input_id}[2])")
      } else {
        load_line <- glue::glue("{update_function}(session, \"{input_id}\", {update_parameter} = state${input_id})")
      }

      to_load <- append(to_load, load_line)
      to_save <- append(to_save, save_line)

    }

    #search for manual insertion lines, add if not present, store existing lines
    manual_save_marker <- grep("*### Manual save*", lines)
    if (length(manual_save_marker) == 0){
      manual_save_lines <- c("      ### Manual save start", "      ### Manual save end")
    }
    if (length(manual_save_marker) == 2){
      manual_save_lines <- lines[manual_save_marker[1]:manual_save_marker[2]]
    }

    manual_load_marker <- grep("*### Manual load*", lines)
    if (length(manual_load_marker) == 0){
      manual_load_lines <- c("      ### Manual load start", "      ### Manual load end")
    }
    if (length(manual_load_marker) == 2){
      manual_load_lines <- lines[manual_load_marker[1]:manual_load_marker[2]]
    }

    #search for insertion and closing lines, delete existing lines.
    #remove duplicated new lines, put all new lines in one object and add new lines
    insert_save_line <- grep("*save = function()*", lines)
    lines[insert_save_line] <- "    save = function() {list("
    curly_lines <- grep("*},", lines)
    end_save_line <- min(curly_lines[curly_lines > insert_save_line])
    if ((end_save_line - insert_save_line) > 1){
      existing_save_lines <- seq(insert_save_line + 1, end_save_line - 1, 1)
      lines <- lines[-existing_save_lines]
    }
    save_lines <- paste(unique(to_save), collapse = ", \n      ")
    manual_save_lines <- paste(manual_save_lines, collapse = "\n")
    save_lines <- paste0(c(manual_save_lines, "\n      ", save_lines,")"), collapse = "")
    lines <- append(lines, save_lines, insert_save_line)

    insert_load_line <- grep("*load = function(state)*", lines)
    curly_lines <- grep("*}", lines)
    end_load_line <- min(curly_lines[curly_lines > insert_load_line])
    if ((end_load_line - insert_load_line) > 1){
      existing_load_lines <- seq(insert_load_line + 1, end_load_line - 1, 1)
      lines <- lines[-existing_load_lines]
    }
    load_lines <- paste(unique(to_load), collapse = " \n      ")
    manual_load_lines <- paste(manual_load_lines, collapse = "\n")
    load_lines <- paste0(c(manual_load_lines, "\n      ", load_lines), collapse = "")
    lines <- append(lines, load_lines, insert_load_line)

    #tidy up any template comments
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
