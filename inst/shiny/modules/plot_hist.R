plot_hist_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    selectInput(ns("bins"), "Number of bins", choices = c(10, 20, 50, 100)),
    selectInput(ns("pal"), "Colour palette", choices = c("Greens", "Greys", "Blues")),
    actionButton(ns("run"), "Plot histogram")
  )
}

plot_hist_module_server <- function(input, output, session, common) {

  # logger <- common$logger
  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$ras)) {
      common$logger %>% writeLog(type = "error", "Please load a raster file")
      return()
    }
    # FUNCTION CALL ####
    hist <- plot_hist(common$ras, input$bins)
    # LOAD INTO COMMON ####
    common$hist <- hist
    # METADATA ####
    common$meta$hist$bins <- as.numeric(input$bins)
    #common$meta$hist$pal <- input$pal
    common$meta$hist$name <- common$meta$ras$name
    trigger("plot_hist")
  })

  output$hist <- renderPlot({
    watch("plot_hist")
    req(common$hist)
    pal <- brewer.pal(9, common$meta$hist$pal)
    pal_ramp <- colorRampPalette(c(pal[1], pal[9]))
    bins <- common$meta$hist$bins
    cols <- rep(pal_ramp(bins), 1, each = 100/bins)[min(common$hist$breaks):max(common$hist$breaks)]

    plot(common$hist, freq = FALSE, main = "", xlab = common$meta$hist$name, ylab = "Frequency (%)", cols = cols)
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


plot_hist_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    plot_hist_knit = !is.null(common$hist),
    hist_bins = common$meta$hist$bins,
    hist_pal = common$meta$hist$pal,
    hist_name = common$meta$hist$name
  )
}
