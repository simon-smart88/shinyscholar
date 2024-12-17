make_module_header <- function(module_path, module){
  module_yaml <- yaml::read_yaml(file.path(module_path, paste0(module, ".yml")))
  return(c(
    glue::glue('```{{r results="asis", echo = FALSE, eval = ("{module}" %in% names(common$meta))}}'),
    glue::glue('  cat("### {module_yaml$long_name}")'), "```", ""))
}


make_component_header <- function(shiny_path, component){
  component_guidance <- readLines(file.path(shiny_path, "Rmd", paste0("gtext_", component, ".Rmd")))
  long_name_line <- component_guidance[grep("Component:", component_guidance)]
  component_long_name <- gsub('.*Component: (.*?)\\*\\*.*', '\\1', long_name_line)
  return(c(
    glue::glue('```{{r results="asis", echo = FALSE, eval = ("{component}" %in% gsub("_(.*)", "", names(common$meta)))}}'),
    glue::glue('  cat("## {component_long_name}")'), "```", ""))
}

find_closing_brace <- function(lines, start) {

  lines <- lines[start:length(lines)]

  stack <- 0
  for (i in seq_along(lines)) {
    line <- lines[i]

    open_braces <- nchar(gsub("[^\\{]", "", line))
    close_braces <- nchar(gsub("[^\\}]", "", line))

    stack <- stack + open_braces - close_braces

    if (stack == 0) {
      return(i)
    }
  }
  return(NA)
}

report <- function(folder_path){

  out_lines <- c()

  shiny_path <- file.path(folder_path, "inst", "shiny")
  module_path <- file.path(shiny_path, "modules")

  # extract the order of modules from global.R
  global_path <- file.path(shiny_path, "global.R")
  global_lines <- readLines(global_path)
  module_lines <- global_lines[grep(".yml", global_lines)]
  module_ids <- gsub('.*modules/(.*)\\.yml.*', '\\1', module_lines)
  module_ids <- module_ids[!grepl("rep_|core_|template_", module_ids)]

  components <- unique(gsub("_(.*)", "", module_ids))

  for (component in components){

    modules <- module_ids[grepl(component, module_ids)]

    component_header <- make_component_header(shiny_path, component)

    out_lines <- c(out_lines, component_header)

    for (module in modules){

      module_header <- make_module_header(module_path, module)
      module_results_chunk_start <- glue::glue('```{{r {module}, echo=FALSE, fig.height=5, fig.align="center", eval = ({module} %in% names(common$meta))}}')

      out_lines <- c(out_lines, module_header, module_results_chunk_start)

      lines <- readLines(file.path(module_path, paste0(module,".R")))

      # look for the module_result function
      result_start <- grep("module_result", lines)
      if (length(result_start) > 0){
        result_end <- find_closing_brace(lines, result_start)
        results <- lines[(result_start + 1) : (result_end - 1)]

        # extract the output ids
        output_id_lines <- grep("ns\\(", results)
        output_id <- strsplit(results[output_id_lines], "\"")[[1]][2]
        if (is.na(output_id)){
          output_id <- strsplit(results[output_id_lines], "'")[[1]][2]
        }
        # warn and next if this output_id is still NA

        # need a loop here in case of multiple output$

        # find the output$ objects
        output_start <- grep(paste0("output\\$", output_id), lines)
        #closing_output_lines <- grep("}\\)", lines)
        #output_end <- min(closing_output_lines[closing_output_lines > output_start])
        output_end <- find_closing_brace(lines, output_start)
        # warn and next if this is Inf

        # find the lines producing outputs and trim req() and gargoyle::
        output_lines <- lines[(output_start + 1):(output_end - 1)]
        gargoyle_lines <- grep("gargoyle", output_lines)
        output_lines <- output_lines[-gargoyle_lines]
        req_lines <- grep("req\\(", output_lines)
        output_lines <- output_lines[-req_lines]
        output_lines <- trimws(output_lines)
        out_lines <- c(out_lines, output_lines)
      }

      # look for the module_map function
      map_start <- grep("function\\(map, common\\)", lines)
      if (length(map_start) > 0){
        map_end <- find_closing_brace(lines, map_start)
        map_lines <- lines[(map_start + 1) : (map_end - 1)]
        out_lines <- c(out_lines, map_lines)
      }

      out_lines <- c(out_lines, "```", "")
    }
  }

  writeLines(out_lines, file.path(shiny_path, "Rmd", "test_report.Rmd"))
}
