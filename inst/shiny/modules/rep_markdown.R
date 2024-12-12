rep_markdown_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    strong("Select download file type"),
    selectInput(ns("rmdFileType"), label = "",
                choices = c("Rmd" = ".Rmd", "PDF" = ".pdf", "HTML" = ".html", "Word" = ".docx")),
    downloadButton(ns("dlRMD"), 'Download Session Code'),
    downloadButton(ns("report"), 'Download report')
  )
}

rep_markdown_module_server <- function(id, common, parent_session, map, COMPONENT_MODULES) {
  moduleServer(id, function(input, output, session) {

    output$report <- downloadHandler(
      filename = function() {
        paste0("shinyscholar-session-report.html")
      },
      content = function(file) {
        rmarkdown::render("Rmd/report.Rmd",
                          # rmarkdown::pdf_document(),
                          output_file = file)
      }
    )

    # handler for R Markdown download
    output$dlRMD <- downloadHandler(
      filename = function() {
        paste0("shinyscholar-session-", Sys.Date(), input$rmdFileType)
      },
      content = function(file) {
        md_files <- c()
        md_intro_file <- tempfile(pattern = "intro_", fileext = ".md")
        rmarkdown::render("Rmd/userReport_intro.Rmd",
                          output_format = rmarkdown::github_document(html_preview = FALSE),
                          output_file = md_intro_file,
                          clean = TRUE,
                          encoding = "UTF-8")
        md_files <- c(md_files, md_intro_file)

        module_rmds <- NULL
        #force rep_renv to beginning
        components <- names(COMPONENT_MODULES)
        components <- c("rep", components[components != c("rep")])
        for (component in components) {
          for (module in COMPONENT_MODULES[[component]]) {
            rmd_file <- module$rmd_file
            rmd_function <- module$rmd_function
            if (is.null(rmd_file)) next
            if (is.null(rmd_function)) {
              rmd_vars <- list()
            } else {
              rmd_vars <- do.call(rmd_function, list(common))
            }
            knit_params <- c(
              file = rmd_file,
              lapply(rmd_vars, printVecAsis)
            )
            module_rmd <- do.call(knitr::knit_expand, knit_params)

            module_rmd_file <- tempfile(pattern = paste0(module$id, "_"),
                                        fileext = ".Rmd")
            writeLines(module_rmd, module_rmd_file)
            module_rmds <- c(module_rmds, module_rmd_file)
          }
        }

        module_md_file <- tempfile(pattern = paste0(module$id, "_"),
                                   fileext = ".md")
        rmarkdown::render(input = "Rmd/userReport_module.Rmd",
                          params = list(child_rmds = module_rmds),
                          output_format = rmarkdown::github_document(html_preview = FALSE),
                          output_file = module_md_file,
                          clean = TRUE,
                          encoding = "UTF-8")
        md_files <- c(md_files, module_md_file)

        combined_md <-
          md_files %>%
          lapply(readLines) %>%
          lapply(paste, collapse = "\n") %>%
          paste(collapse = "\n\n")

        result_file <- tempfile(pattern = "result_", fileext = input$rmdFileType)
        if (input$rmdFileType == ".Rmd") {
          combined_rmd <- gsub("``` r", "```{r}", combined_md)
          writeLines(combined_rmd, result_file, useBytes = TRUE)
        } else {
          combined_md_file <- tempfile(pattern = "combined_", fileext = ".md")
          writeLines(combined_md, combined_md_file)
          rmarkdown::render(
            input = combined_md_file,
            output_format =
              switch(
                input$rmdFileType,
                ".pdf" = rmarkdown::pdf_document(),
                ".html" = rmarkdown::html_document(),
                ".docx" = rmarkdown::word_document()
              ),
            output_file = result_file,
            clean = TRUE,
            encoding = "UTF-8"
          )
        }

        file.rename(result_file, file)
      }
    )

  }
)}
