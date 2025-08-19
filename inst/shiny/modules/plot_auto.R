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
    raster_name <- c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    histogram <- plot_hist(common$raster, as.numeric(input$bins), input$pal, raster_name, common$logger)
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

  output$hist <- renderPlot({
    watch("plot_auto")
    req(common$histogram_auto)
    # Included here so that the module is only 'used' if the results are rendered
    common$meta$plot_auto$used <- TRUE
    common$histogram_auto()
  })

  output$download <- downloadHandler(
    filename = function() {
      "shinyscholar_histogram.png"
    },
    content = function(file) {
      png(file, width = 1000, height = 500)
      common$histogram_auto()
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

