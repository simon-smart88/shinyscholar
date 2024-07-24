
select_async_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = c("2023-06-20", "2023-06-30", "2023-07-10", "2023-07-20")),
    actionButton(ns("random"), "Pick a random location"),
    br(),br(),
    bslib::input_task_button(ns("run"), "Load imagery")
  )
}

select_async_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  #pick a random location over land, but fail safely in case the API is broken
  observeEvent(input$random, {
    random_land <- httr2::request("https://api.3geonames.org/?randomland=yes") |> httr2::req_perform()
    if (random_land$status_code == 200){
      random_land <- httr2::resp_body_xml(random_land) |> xml2::as_list()
      map %>% setView(random_land$geodata$nearest$longt, random_land$geodata$nearest$latt, zoom = 9)
    } else {
      common$logger %>% writeLog(type = "error", "Something went wrong requesting a random location")
    }
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
      poly_matrix <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
      colnames(poly_matrix) <- c('longitude', 'latitude')
      common$poly <- poly_matrix
    }

    # WARNING ####
    if (is.null(common$poly)) {
      common$logger %>% writeLog(type = "error", "Please draw a rectangle on the map")
      return()
    }

    # FUNCTION CALL ####
    common$logger %>% writeLog(type = "starting", "Starting to download Fcover data")
    # invoke the async task
    common$tasks$select_async$invoke(common$poly, input$date, TRUE)
    # reactive the results observer if it has already been used
    results$resume()

    # METADATA ####
    common$meta$select_async$date <- input$date
    common$meta$select_async$poly <- common$poly
    common$meta$select_async$name <- "FCover"
    common$meta$select_async$used <- TRUE

  })

  results <- observe({
    # LOAD INTO COMMON ####

    #fetch the result
    result <- common$tasks$select_async$result()
    #suspend the observer
    results$suspend()

    # check the class of the result is the class when the function runs successfully
    if (class(result) == "list"){
      raster <- terra::unwrap(result$raster)
      common$ras <- raster

      common$logger %>% writeLog(type = "complete", "Fcover data has been downloaded")
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
        select_date = input$date
      )
    },
    load = function(state) {
      updateSelectInput(session, "date", selected = state$select_date)
    }
  ))
})
}

select_async_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  verbatimTextOutput(ns("result"))
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
    addTiles(urlTemplate = "", attribution = "Copernicus Sentinel data 2023") %>%
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
    select_name = common$meta$select_async$name

  )
}
