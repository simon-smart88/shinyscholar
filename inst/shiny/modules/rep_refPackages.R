rep_refPackages_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("file_type"), label = "Select download file type",
                choices = c("PDF" = ".pdf", "HTML" = ".html", "Word" = ".docx")),
    downloadButton(ns("download"), "Download References")
  )
}

rep_refPackages_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

    output$download <- downloadHandler(
      filename = function() {
        paste0("ref-packages-", Sys.Date(), input$file_type)
        },
      content = function(file) {
        # Create BIB file
        bib_file <- "Rmd/references.bib"
        temp_bib_file <- tempfile(pattern = "ref_", fileext = ".bib")
        # Package always cited
        knitcitations::citep(citation("shinyscholar"))
        knitcitations::citep(citation("knitcitations"))
        knitcitations::citep(citation("knitr"))
        knitcitations::citep(citation("rmarkdown"))
        knitcitations::citep(citation("terra"))
        knitcitations::citep(citation("raster"))
        # Write BIBTEX file
        knitcitations::write.bibtex(file = temp_bib_file)
        # Replace NOTE fields with VERSION when R package
        bib_ref <- readLines(temp_bib_file)
        bib_ref <- gsub(pattern = "note = \\{R package version", replace = "version = \\{R package", x = bib_ref)
        writeLines(bib_ref, con = temp_bib_file)
        file.rename(temp_bib_file, bib_file)
        # Render reference file
        md_ref_file <- tempfile(pattern = "ref_", fileext = ".md")
        rmarkdown::render("Rmd/references.Rmd",
                          output_format =
                            switch(
                              input$file_type,
                              ".pdf" = rmarkdown::pdf_document(),
                              ".html" = rmarkdown::html_document(),
                              ".docx" = rmarkdown::word_document()
                            ),
                          output_file = file,
                          clean = TRUE,
                          encoding = "UTF-8")
      })


  }

)}
