plot_auto_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("bins"), "Number of bins", choices = c(10, 20, 50, 100)),
    selectInput(ns("pal"), "Colour palette", choices = c("Greens", "YlOrRd", "Greys", "Blues")),
    downloadButton(ns("download"), "Download plot")
  )
}

plot_auto_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  shinyjs::hide("download")

  # List of objects that will trigger the module to run
  triggers <- reactive({
    list(watch("select_async"),
         watch("select_user"),
         watch("select_query"),
         input$bins,
         input$pal)
  })

  observeEvent(triggers(), {
    req(common$raster)

    # FUNCTION CALL ####
    histogram <- plot_hist(common$raster, as.numeric(input$bins))
    # LOAD INTO COMMON ####
    common$histogram_auto <- histogram
    # METADATA ####
    common$meta$plot_auto$bins <- as.numeric(input$bins)
    common$meta$plot_auto$pal <- input$pal
    common$meta$plot_auto$name <- c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    # TRIGGER ####
    trigger("plot_auto")
    shinyjs::show("download")
  })

  plot_function <- function(){
    pal <- RColorBrewer::brewer.pal(9, common$meta$plot_auto$pal)
    pal_ramp <- colorRampPalette(c(pal[1], pal[9]))
    bins <- common$meta$plot_auto$bins
    cols <- pal_ramp(bins)
    plot(common$histogram_auto, freq = FALSE, main = "", xlab = common$meta$plot_auto$name, ylab = "Frequency (%)", col = cols)
  }

  output$hist <- renderPlot({
    watch("plot_auto")
    req(common$histogram_auto)
    # Included here so that the module is only 'used' if the results are rendered
    common$meta$plot_auto$used <- TRUE
    plot_function()
  })

  output$download <- downloadHandler(
    filename = function() {
      "shinyscholar_histogram.png"
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

plot_auto_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  plotOutput(ns("hist"))
}

plot_auto_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    plot_auto_knit = !is.null(common$meta$plot_auto$used),
    plot_auto_bins = common$meta$plot_auto$bins,
    plot_auto_pal = common$meta$plot_auto$pal,
    plot_auto_name = common$meta$plot_auto$name
  )
}

