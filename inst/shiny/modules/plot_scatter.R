plot_scatter_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    sliderInput(ns("sample"), "Number of pixels", min = 100, max = 10000, value = 1000),
    radioButtons(ns("axis"), "x axis", choices = c("Longitude", "Latitude")),
    actionButton(ns("run"), "Plot scatterplot", icon = icon("arrow-turn-down")),
    downloadButton(ns("download"), "Download plot")
  )
}


plot_scatter_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  shinyjs::hide("download")

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$raster)) {
      common$logger |> writeLog(type = "error", "Please load a raster file")
      return()
    }
    # FUNCTION CALL ####
    if (input$axis == "Longitude"){axis <- "x"} else {axis <- "y"}
    scatterplot <- plot_scatter(common$raster, input$sample, axis)
    # LOAD INTO SPP ####
    common$scatterplot <- scatterplot
    # METADATA ####
    common$meta$plot_scatter$axis_short <- axis
    common$meta$plot_scatter$axis_long <- input$axis
    common$meta$plot_scatter$sample <- input$sample
    common$meta$plot_scatter$name <-  c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    # TRIGGER ####
    trigger("plot_scatter")
    show_results(parent_session)
    shinyjs::show("download")
  })

  plot_function <- function(){
    plot(common$scatterplot[[1]], common$scatterplot[[2]], xlab = common$meta$plot_scatter$axis_long, ylab = common$meta$plot_scatter$name)
  }

  output$result <- renderPlot({
    watch("plot_scatter")
    req(common$scatterplot)
    plot_function()
  })

  output$download <- downloadHandler(
    filename = function() {
      "shinyscholar_scatterplot.png"
    },
    content = function(file) {
      png(file, width = 1000, height = 500)
      plot_function()
      dev.off()
    })

  return(list(
    save = function() {list(
      ### Manual save start
      ### Manual save end
      sample = input$sample,
      axis = input$axis)
          },
    load = function(state) {
      ### Manual load start
      ### Manual load end
      updateSliderInput(session, "sample", value = state$sample)
      updateRadioButtons(session, "axis", selected = state$axis)
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
      plot_scatter_knit = !is.null(common$scatterplot),
      plot_scatter_axis_short = common$meta$plot_scatter$axis_short,
      plot_scatter_axis_long = common$meta$plot_scatter$axis_long,
      plot_scatter_sample = common$meta$plot_scatter$sample,
      plot_scatter_name = common$meta$plot_scatter$name)
}
