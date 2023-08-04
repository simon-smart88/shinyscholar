plot_scatter_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    sliderInput(ns("sample"), "Number of pixels",min=100,max=10000,value=1000),
    radioButtons("axis","x axis",choices=c('x','y')),
    actionButton(ns("run"), "Plot scatterplot")
  )
}

plot_scatter_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####

    # FUNCTION CALL ####
    scat <- plot_scatter(ras,input$sample,input$axis)
    # LOAD INTO SPP ####
    common$scat <- scat
    # METADATA ####
    common$meta$scat$axis <- input$axis
    common$meta$scat$sample <- input$sample
  })

  output$result <- renderPlot({
    plot(common$scat[[1]],common$scat[[2]])
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

plot_scatter_module_result <- function(id) {
  ns <- NS(id)
  # Result UI
  plotOutput(ns("result"))
}

plot_scatter_module_rmd <- function(species) {
  # Variables used in the module's Rmd code
  list(
    plot_scatter_knit = !is.null(common$scat),
    scat_axis = common$meta$scat$axis,
    scat_sample = common$meta$scat$sample   )
}

