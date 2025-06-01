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
      common$logger |> writeLog(type = "error", "Please load a raster file")
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
    raster_name <- c(common$meta$select_query$name, common$meta$select_async$name, common$meta$select_user$name)
    histogram <- plot_hist(common$raster, as.numeric(input$bins), input$pal, raster_name, common$logger)
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

  output$hist <- renderPlot({
    watch("plot_semi_update")
    req(common$histogram_semi)
    common$histogram_semi()
  })

  output$download <- downloadHandler(
    filename = function() {
      "shinyscholar_histogram.png"
    },
    content = function(file) {
      png(file, width = 1000, height = 500)
      common$histogram_semi()
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

