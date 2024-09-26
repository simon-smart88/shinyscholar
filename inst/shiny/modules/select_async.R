
select_async_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    dateInput(ns("date"), "Select date",
              min = "2005-01-01",
              max = as.character(Sys.Date()-20),
              value = as.character(Sys.Date()-20)),
    uiOutput(ns("token_out")),
    actionButton(ns("random"), "Pick a random location"),
    br(),br(),
    bslib::input_task_button(ns("run"), "Load imagery")
  )
}

select_async_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  # pick a random location over land, but fail safely in case the API is broken
  observeEvent(input$random, {
    random_land <- httr2::request("https://api.3geonames.org/?randomland=yes") |> httr2::req_perform()
    if (random_land$status_code == 200){
      random_land <- httr2::resp_body_xml(random_land) |> xml2::as_list()
      map %>% setView(random_land$geodata$nearest$longt, random_land$geodata$nearest$latt, zoom = 7)
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

  #create the asynchronous task
  common$tasks$select_async <- ExtendedTask$new(function(...) {
    promises::future_promise({
      select_async(...)
    })
  }) |> bslib::bind_task_button("run")

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
    common$logger %>% writeLog(type = "starting", "Starting to download FAPAR data")
    # invoke the async task
    common$tasks$select_async$invoke(common$poly, input$date, token(), TRUE)
    # reactivate the results observer if it has already been used
    results$resume()

    # METADATA ####
    common$meta$select_query$date <- as.character(input$date)
    common$meta$select_async$token <- input$token
    common$meta$select_async$poly <- common$poly
    common$meta$select_async$name <- "FAPAR"
    common$meta$select_async$used <- TRUE

  })

  results <- observe({
    # LOAD INTO COMMON ####

    # fetch the result
    result <- common$tasks$select_async$result()
    # suspend the observer
    results$suspend()

    # check the class of the result is the class when the function runs successfully
    if (class(result) == "list"){
      raster <- terra::unwrap(result$raster)
      common$ras <- raster

      common$logger %>% writeLog(type = "complete", "FAPAR data has been downloaded")
      common$logger %>% writeLog(result$message)

      # TRIGGER
      gargoyle::trigger("select_async")

      # explicitly call the mapping function
      do.call("select_async_module_map", list(map, common))
      show_map(parent_session)

      # set an input value to use in testing
      shinyjs::runjs("Shiny.setInputValue('select_async-complete', 'complete');")
    } else {
      common$logger |> writeLog(type = "error", result)
    }
  })

  return(list(
    save = function() {
      list(
        select_date = input$date,
        select_token = input$token
      )
    },
    load = function(state) {
      updateDateInput(session, "date", selected = state$select_date)
      updateTextInput(session, "token", selected = state$select_token)
    }
  ))
})
}

select_async_module_map <- function(map, common) {
  ex <- as.vector(terra::ext(common$ras))
  pal <- colorBin("Greens", domain = terra::values(common$ras), bins = 9, na.color = "pink")
  name <- common$meta$select_async$name
  map %>%
    leaflet.extras::removeDrawToolbar(clearFeatures = TRUE) %>%
    leaflet.extras::addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE, markerOptions = FALSE,
                   circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE) %>%
    clearGroup(name) %>%
    removeControl(name) %>%
    addRasterImage(common$ras, colors = pal, group = name) %>%
    addTiles(urlTemplate = "", attribution = "MODIS data via LAADS DAAC") %>%
    fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
    addLegend(position = "bottomright", pal = pal, values = terra::values(common$ras),
              group = name, title = name, layer = name) %>%
    addLayersControl(overlayGroups = name, options = layersControlOptions(collapsed = FALSE))
}

select_async_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_async_knit = !is.null(common$meta$select_async$used),
    select_date = common$meta$select_async$date,
    select_poly = common$meta$select_async$poly,
    select_name = common$meta$select_async$name,
    select_token = common$meta$select_async$token
  )
}