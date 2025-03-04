{{id}}_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    bslib::input_task_button(ns("run"), "Run module {{id}}")
  )
}

{{id}}_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {


  #create the asynchronous task
  common$tasks${{id}} <- ExtendedTask$new(function(...) {
    promises::future_promise({
      {{id}}(...)
    })
  }) |> bslib::bind_task_button("run")

    observeEvent(input$run, {
      # WARNING ####

      # FUNCTION CALL ####
      common$logger %>% writeLog(type = "starting", "Starting to run {{id}}")
      # invoke the async task
      common$tasks${{id}}$invoke()
      # reactivate the results observer if it has already been used
      results$resume()

      # METADATA ####
      # Populate using metadata()
    })


    results <- observe({
      # LOAD INTO COMMON ####

      # fetch the result
      result <- common$tasks${{id}}$result()
      # suspend the observer
      results$suspend()

      # check the class of the result is the class when the function runs successfully
      if (class(result) == "list"){

        common$logger %>% writeLog(type = "complete", "{{id}} has completed")

        # TRIGGER
        trigger("{{id}}")

        # explicitly call the mapping function
        do.call("{{id}}_module_map", list(map, common))
        show_map(parent_session)

        # set an input value to use in testing
        shinyjs::runjs("Shiny.setInputValue('{{id}}-complete', 'complete');")
      } else {
        common$logger %>% writeLog(type = "error", result)
      }
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

