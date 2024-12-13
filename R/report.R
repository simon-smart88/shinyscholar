report <- function(folder_path){


  folder_path <- "~/Documents/shinyscholar"
  module_path <- file.path(folder_path, "inst", "shiny", "modules")
  targets <- list.files(module_path, pattern = ".R$")
  targets <- targets[!grepl("rep_|core_|template_", targets)]
  target <- targets[1]

  lines <- readLines(file.path(module_path, target))

  # find the module_result function
  result_start <- grep("module_result", lines)
  curly_lines <- grep("}", lines)
  result_end <- min(curly_lines[curly_lines > result_start])
  results <- lines[(result_start + 1) : (result_end - 1)]

  # extract the output ids
  output_id_ines <- grep("ns\\(", results)
  output_id <- strsplit(results[output_id_lines], "\"")[[1]][2]
  if (is.na(output_id)){
    output_id <- strsplit(results[output_id_lines], "'")[[1]][2]
  }

  # find the output$ objects
  output_start <- grep(paste0("output\\$", output_id), lines)
  closing_output_lines <- grep("}\\)", lines)
  output_end <- min(closing_output_lines[closing_output_lines > output_start])

  output_lines <- lines[(output_start + 1):(output_end - 1)]
  gargoyle_lines <- grep("gargoyle", output_lines)
  output_lines <- output_lines[-gargoyle_lines]
  req_lines <- grep("req\\(", output_lines)
  output_lines <- output_lines[-req_lines]

  output_lines <- trimws(output_lines)

  make_module_header <- function(module){
    module_yaml <- yaml::read_yaml(file.path(module_path, paste0(module, ".yml")))
    return(c(
      glue::glue('```{{r results="asis", echo = FALSE, eval = ("{module}" %in% names(common$meta))}}'),
      glue::glue('  cat("### {module_yaml$long_name}")')))
  }

  make_module_header("plot_hist")

  module_results_chunk_start <- '```{{r {module}, echo=FALSE, fig.height=5, fig.align="center", eval = ({module} %in% names(common$meta))}}'




}
