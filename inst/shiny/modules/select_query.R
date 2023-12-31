
select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = c("2023-06-20", "2023-06-30", "2023-07-10", "2023-07-20")),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(id, common) {
  moduleServer(id, function(input, output, session) {

  observeEvent(input$run, {

    # TEST MODE - required due to the polygon not being able to be tested correctly.
    if (isTRUE(getOption("shiny.testmode"))) {
      poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
      colnames(poly_matrix) <- c('longitude', 'latitude')
      common$poly <- poly_matrix
    }

    # WARNING ####
    if (is.null(common$poly)) {
      common$logger %>% writeLog(type = "error", "Please draw a rectangle on the map")
      return()
    }
    req(input$date, common$poly)
    # FUNCTION CALL ####
    show_loading_modal("Please wait while the data is loaded.
                          This window will close once it is complete.")
    ras <- select_query(common$poly, input$date, common$logger)
    #close if the function returns null
    close_loading_modal()
    # LOAD INTO COMMON ####
    common$ras <- ras
    # METADATA ####
    common$meta$query$date <- input$date
    common$meta$query$poly <- common$poly
    common$meta$ras$name <- "FCover"
    common$meta$query$used <- TRUE
    # TRIGGER ####
    gargoyle::trigger("select_query")

  })

  return(list(
    save = function() {
      list(
        select_date = input$date
      )
    },
    load = function(state) {
      updateSelectInput(session, "date", selected = state$select_date)
    }
  ))
})
}

select_query_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  verbatimTextOutput(ns("result"))
}

select_query_module_map <- function(map, common) {
  observeEvent(gargoyle::watch("select_query"), {
    req(common$meta$query$used == TRUE)
    req(common$ras)
    ex <- as.vector(terra::ext(common$ras))
    pal <- colorBin("Greens", domain = terra::values(common$ras), bins = 9, na.color = "pink")
    map %>%
      removeDrawToolbar(clearFeatures = TRUE) %>%
      addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE, markerOptions = FALSE,
                     circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE) %>%
      clearGroup(common$meta$ras$name) %>%
      addRasterImage(raster::raster(common$ras), colors = pal, group = common$meta$ras$name) %>%
      addTiles(urlTemplate = "", attribution = "Copernicus Sentinel data 2023") %>%
      fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
      addLegend(position = "bottomright", pal = pal, values = terra::values(common$ras),
                group = common$meta$ras$name, title = common$meta$ras$name) %>%
      addLayersControl(overlayGroups = common$meta$ras$name, options = layersControlOptions(collapsed = FALSE))
  })
}

select_query_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_query_knit = !is.null(common$meta$query$used),
    select_date = common$meta$query$date,
    select_poly = printVecAsis(common$meta$query$poly),
    select_name = common$meta$ras$name

  )
}
