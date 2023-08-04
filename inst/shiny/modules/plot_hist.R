plot_hist_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    selectInput(ns("bins"),"Number of bins",choices=c(10,20,50,100)),
    actionButton(ns("run"), "Plot histogram")
  )
}

plot_hist_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$ras)) {
      logger %>% writeLog(type = 'error', "Please load a raster file")
      return()
    }
    # FUNCTION CALL ####
    hist_values <- plot_hist(common$ras)
    # LOAD INTO SPP ####
    common$hist <- hist_values
    # METADATA ####
    common$meta$hist$bins <- input$bins
  })

  output$result <- renderPlot({
    req(common$hist)
    hist(common$hist,bins=input$bins)
  })

  return(list(
    save = function() {
      # Save any values that should be saved when the current session is saved
    },
    load = function(state) {
      # Load
    }
  ))

}

plot_hist_module_result <- function(id) {
  ns <- NS(id)
  # Result UI
  plotOutput(ns("hist"))
}


plot_hist_module_rmd <- function(species) {
  # Variables used in the module's Rmd code
  list(
    plot_hist_knit = !is.null(common$hist),
    hist_bins = common$meta$hist$bins
  )
}

