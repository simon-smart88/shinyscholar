rep_renv_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    downloadButton(ns("run"), "Download dependency list")
  )
}

rep_renv_module_server <- function(id, common, parent_session) {
  moduleServer(id, function(input, output, session) {

    output$run <- downloadHandler(
      filename = function() {
        paste0("shinyscholar-dependencies.lock")
      },
      content = function(file) {
      common$meta$rep_renv$used <- TRUE
      renv::snapshot(prompt = FALSE, type = "implicit",
                     lockfile = file, force = TRUE)
      }
  )

})
}

rep_renv_module_rmd <- function(common) {
  list(rep_renv_knit = !is.null(common$meta$rep_renv$used))
}
