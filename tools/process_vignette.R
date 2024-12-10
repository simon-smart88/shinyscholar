prepend_vignette_header <- function(input_file, output_file) {
  current_date <- format(Sys.Date(), "%Y-%m-%d")
  header <- c(
    '---',
    'title: "A guide to developing applications with Shinyscholar"',
    'author: "Simon Smart"',
    paste0(c('date: "', current_date, '"')),
    'output: rmarkdown::html_vignette',
    'vignette: >',
    '  %\\VignetteIndexEntry{A guide to developing applications with Shinyscholar}',
    '  %\\VignetteEngine{knitr::rmarkdown}',
    '  %\\VignetteEncoding{UTF-8}',
    '---',
    ''
  )
  content <- readLines(input_file)
  writeLines(c(header, content), output_file)
}

file.copy("README.md", "vignettes/README-vignette.md", overwrite = TRUE)
prepend_vignette_header("vignettes/README-vignette.md", "vignettes/README-vignette.md")

# Run with source("tools/process_vignette.R")
