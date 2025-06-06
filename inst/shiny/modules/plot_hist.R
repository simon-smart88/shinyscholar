plot_hist_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    selectInput(ns("bins"), "Number of bins", choices = c(10, 20, 50, 100)),
    selectInput(ns("pal"), "Colour palette", choices = c("Greens", "YlOrRd", "Greys", "Blues")),
    actionButton(ns("run"), "Plot histogram", icon = icon("arrow-turn-down")),
    downloadButton(ns("download"), "Download plot")
  )
}

plot_hist_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  shinyjs::hide("download")

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$raster)) {
      common$logger |> writeLog(type = "error", "Please load a raster file")
      return()
    }
    # FUNCTION CALL ####
    raster_name <- c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    histogram <- plot_hist(common$raster, as.numeric(input$bins), input$pal, raster_name, common$logger)
    # LOAD INTO COMMON ####
    common$histogram <- histogram
    # METADATA ####
    common$meta$plot_hist$bins <- as.numeric(input$bins)
    common$meta$plot_hist$pal <- input$pal
    common$meta$plot_hist$name <- raster_name
    # TRIGGER ####
    trigger("plot_hist")
    show_results(parent_session)
    shinyjs::show("download")
  })

  plot_function <- function(){
    pal <- RColorBrewer::brewer.pal(9, common$meta$plot_hist$pal)
    pal_ramp <- colorRampPalette(c(pal[1], pal[9]))
    bins <- common$meta$plot_hist$bins
    cols <- pal_ramp(bins)
    plot(common$histogram, freq = FALSE, main = "", xlab = common$meta$plot_hist$name, ylab = "Frequency (%)", col = cols)
  }

  output$hist <- renderPlot({
    watch("plot_hist")
    req(common$histogram)
    common$histogram()
  })

  output$download <- downloadHandler(
    filename = function() {
      "shinyscholar_histogram.png"
    },
    content = function(file) {
      png(file, width = 1000, height = 500)
      common$histogram()
      dev.off()
    })

  return(list(
    save = function() {list(
      ### Manual save start
      ### Manual save end
      bins = input$bins,
      pal = input$pal)
          },
    load = function(state) {
      ### Manual load start
      ### Manual load end
      updateSelectInput(session, "bins", selected = state$bins)
      updateSelectInput(session, "pal", selected = state$pal)
    }
  ))
})
}

plot_hist_module_result <- function(id) {
  ns <- NS(id)
  # Result UI
  plotOutput(ns("hist"))
}


plot_hist_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    plot_hist_knit = !is.null(common$meta$plot_hist$bins),
    plot_hist_bins = common$meta$plot_hist$bins,
    plot_hist_pal = common$meta$plot_hist$pal,
    plot_hist_name = common$meta$plot_hist$name
  )
}
