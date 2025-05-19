plot_semi_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("bins"), "Number of bins", choices = c(10, 20, 50, 100)),
    selectInput(ns("pal"), "Colour palette", choices = c("Greens", "YlOrRd", "Greys", "Blues")),
    actionButton(ns("run"), "Plot histogram", icon = icon("arrow-turn-down")),
    downloadButton(ns("download"), "Download plot")
  )
}

plot_semi_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  shinyjs::hide("download")
  init("plot_semi_update")

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$raster)) {
      common$logger %>% writeLog(type = "error", "Please load a raster file")
      return()
    }
    # TRIGGER
    trigger("plot_semi")
  })

  triggers <- reactive({
    # block until warning conditions are met
    req(watch("plot_semi") > 0)
    list(watch("plot_semi"),
         input$bins,
         input$pal)
  })

  observeEvent(triggers(), {
    req(common$raster)
    # FUNCTION CALL ####
    histogram <- plot_hist(common$raster, as.numeric(input$bins))
    # LOAD INTO COMMON ####
    common$histogram_semi <- histogram
    # METADATA ####
    common$meta$plot_semi$used <- TRUE
    common$meta$plot_semi$bins <- as.numeric(input$bins)
    common$meta$plot_semi$pal <- input$pal
    common$meta$plot_semi$name <- c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    # TRIGGER ####
    trigger("plot_semi_update")
    show_results(parent_session)
    shinyjs::show("download")
  })

  plot_function <- function(){
    pal <- RColorBrewer::brewer.pal(9, common$meta$plot_semi$pal)
    pal_ramp <- colorRampPalette(c(pal[1], pal[9]))
    bins <- common$meta$plot_semi$bins
    cols <- pal_ramp(bins)
    plot(common$histogram_semi, freq = FALSE, main = "", xlab = common$meta$plot_semi$name, ylab = "Frequency (%)", col = cols)
  }

  output$hist <- renderPlot({
    watch("plot_semi_update")
    req(common$histogram_semi)
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

plot_semi_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  plotOutput(ns("hist"))
}

plot_semi_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    plot_semi_knit = !is.null(common$meta$plot_semi$used),
    plot_semi_bins = common$meta$plot_semi$bins,
    plot_semi_pal = common$meta$plot_semi$pal,
    plot_semi_name = common$meta$plot_semi$name
  )
}

