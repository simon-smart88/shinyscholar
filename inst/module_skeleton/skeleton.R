{{id}}_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    actionButton(ns("run"), "Run module {{id}}")
  )
}

{{id}}_module_server <- function(id, common, parent_session) {
  moduleServer(id, function(input, output, session) {

  observeEvent(input$run, {
    # WARNING ####

    # FUNCTION CALL ####

    # LOAD INTO COMMON ####

    # METADATA ####
    # Populate using metadata()

    # TRIGGER
    trigger("{{id}}")
  })

  output$result <- renderText({
    watch("{{id}}")
    # Result
  })

  return(list(
    save = function() {
      # Save any values that should be saved when the current session is saved
      # Populate using save_and_load()
    },
    load = function(state) {
      # Load
      # Populate using save_and_load()
    }
  ))
})
}

{{id}}_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  verbatimTextOutput(ns("result"))
}

{{id}}_module_map <- function(map, common) {
  # Map logic
}

{{id}}_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  # Populate using metadata()
}

