
select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    dateInput(ns("date"), "Select date",
              min = "2005-01-01",
              max = as.character(Sys.Date()-20),
              value = as.character(Sys.Date()-20)),
    uiOutput(ns("token_out")),
    actionButton(ns("random"), "Pick a random location"),
    br(),br(),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  # pick a random location over land, but fail safely in case the API is broken
  observeEvent(input$random, {
    random_land <- httr2::request("https://api.3geonames.org/?randomland=yes") %>% httr2::req_perform()
    if (httr2::resp_status(random_land) == 200){
      content_type <- httr2::resp_content_type(random_land)
      if (grepl("application/xml|text/xml", content_type)) {
        random_land <- httr2::resp_body_xml(random_land) %>% xml2::as_list()
        map %>% setView(random_land$geodata$nearest$longt, random_land$geodata$nearest$latt, zoom = 7)
      } else {
        common$logger %>% writeLog(type = "error", "Something went wrong requesting a random location")
      }
    } else {
      common$logger %>% writeLog(type = "error", "Something went wrong requesting a random location")
    }
  })

  # use the environmental variable if set, if not display box to enter it
  output$token_out <- renderUI({
    if (Sys.getenv("NASA_username") == ""){
      textInput(session$ns("token"), "NASA Earthdata token")}
  })

  token <- reactive({
    if (Sys.getenv("NASA_username") != ""){
      token = get_nasa_token(Sys.getenv("NASA_username"), Sys.getenv("NASA_password"))
    } else {
      token = input$token
    }
    token
  })

  observeEvent(input$run, {

    # TEST MODE - required due to the polygon not being able to be tested correctly.
    if (isTRUE(getOption("shiny.testmode"))) {
      poly_matrix <- matrix(c(0.5, 0.5, 1, 1, 0.5, 52, 52.5, 52.5, 52, 52), ncol = 2)
      colnames(poly_matrix) <- c('longitude', 'latitude')
      common$poly <- poly_matrix
    }

    # WARNING ####
    if (is.null(common$poly)) {
      common$logger %>% writeLog(type = "error", "Please draw a rectangle on the map")
      return()
    }

    if (length(input$date) == 0) {
      common$logger %>% writeLog(type = "error", "Please pick a date")
      return()
    }

    if (nchar(token()) < 200){
      common$logger %>% writeLog(type = "error", "That doesn't look like a valid NASA bearer token")
      return()
    }

    # FUNCTION CALL ####
    show_loading_modal("Please wait while the data is loaded.
                          This window will close once it is complete.")
    raster <- select_query(common$poly, as.character(input$date), token(), common$logger)
    #close if the function returns null
    close_loading_modal()
    if (!is.null(raster)){
      # LOAD INTO COMMON ####
      common$raster <- raster
      # METADATA ####
      common$meta$select_query$date <- as.character(input$date)
      common$meta$select_query$token <- input$token
      common$meta$select_query$poly <- common$poly
      common$meta$select_query$name <- "FAPAR"
      common$meta$select_query$used <- TRUE
      # TRIGGER ####
      trigger("select_query")
      show_map(parent_session)
    }
  })

  return(list(
    save = function() {list(
      ### Manual save start
      ### Manual save end
      date = input$date,
      token = input$token)
    },
    load = function(state) {
      ### Manual load start
      ### Manual load end
      updateDateInput(session, "date", value = state$date)
      updateTextInput(session, "token", value = state$token)
    }
  ))
})
}

select_query_module_map <- function(map, common) {
  req(common$raster)
  ex <- as.vector(terra::ext(common$raster))
  pal <- RColorBrewer::brewer.pal(9, "Greens")
  custom_greens <- colorRampPalette(pal)(10)
  color_bins <- colorBin(custom_greens, domain = terra::values(common$raster), bins = 10, na.color = "pink")
  name <- common$meta$select_query$name

  map %>%
    leaflet.extras::removeDrawToolbar(clearFeatures = TRUE) %>%
    leaflet.extras::addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE, markerOptions = FALSE,
                   circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE) %>%
    clearGroup(name) %>%
    removeControl(name) %>%
    addRasterImage(common$raster, colors = color_bins, group = name) %>%
    addTiles(urlTemplate = "", attribution = "MODIS data via LAADS DAAC") %>%
    fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
    addLegend(position = "bottomright", pal = color_bins, values = terra::values(common$raster),
              group = name, title = name, layer = name) %>%
    addLayersControl(overlayGroups = name, options = layersControlOptions(collapsed = FALSE))
}

select_query_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_query_knit = !is.null(common$meta$select_query$used),
    select_query_date = common$meta$select_query$date,
    select_query_poly = common$meta$select_query$poly,
    select_query_name = common$meta$select_query$name,
    select_query_token = common$meta$select_query$token
  )
}
