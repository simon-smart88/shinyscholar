plot_scatter_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    sliderInput(ns("sample"), "Number of pixels", min = 100, max = 10000, value = 1000),
    radioButtons(ns("axis"), "x axis", choices = c("Longitude", "Latitude")),
    actionButton(ns("run"), "Plot scatterplot"),
    downloadButton(ns("dl"), "Download plot")
  )
}


plot_scatter_module_server <- function(id, common) {
  moduleServer(id, function(input, output, session) {

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$ras)) {
      common$logger %>% writeLog(type = "error", "Please load a raster file")
      return()
    }
    # FUNCTION CALL ####
    if (input$axis == "Longitude"){axis <- "x"} else {axis <- "y"}
    scat <- plot_scatter(common$ras, input$sample, axis)
    # LOAD INTO SPP ####
    common$scat <- scat
    # METADATA ####
    common$meta$scat$axis_short <- axis
    common$meta$scat$axis_long <- input$axis
    common$meta$scat$sample <- input$sample
    common$meta$scat$name <- common$meta$ras$name
    # TRIGGER ####
    gargoyle::trigger("plot_scatter")
  })

  output$result <- renderPlot({
    gargoyle::watch("plot_scatter")
    req(common$scat)
    plot(common$scat[[1]], common$scat[[2]], xlab = common$meta$scat$axis_long, ylab = common$meta$scat$name)
  })

  output$dl <- downloadHandler(
    filename = function() {
      "shinyscholar_scatterplot.png"
    },
    content = function(file) {
      png(file, width = 1000, height = 500)
      plot(common$scat[[1]], common$scat[[2]], xlab = common$meta$scat$axis_long, ylab = common$meta$scat$name)
      dev.off()
    })

  return(list(
    save = function() {
      list(
      scatter_sample = input$sample,
      scatter_axis = input$axis
      )
          },
    load = function(state) {
      updateSliderInput(session, "sample", value = state$scatter_sample)
      updateRadioButtons(session, "axis", selected = state$scatter_axis)
    }
  ))
  }
)}

plot_scatter_module_result <- function(id) {
  ns <- NS(id)
  # Result UI
  plotOutput(ns("result"))
}

plot_scatter_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
      plot_scatter_knit = !is.null(common$scat),
      scat_axis_short = common$meta$scat$axis_short,
      scat_axis_long = common$meta$scat$axis_long,
      scat_sample = common$meta$scat$sample,
      scat_name = common$meta$scat$name)
}
