
select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = c("2023-06-20", "2023-06-30", "2023-07-10", "2023-07-20")),
    actionButton(ns("random"), "Pick a random location"),
    br(),br(),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(id, common, parent_session) {
  moduleServer(id, function(input, output, session) {

  #Required to pass the event to the mapping function
  gargoyle::init("select_query_random")
  observeEvent(input$random, {
  gargoyle::trigger("select_query")
  gargoyle::trigger("select_query_random")
  #trigger this again on the first run
  if (input$random == 1){
    shinyjs::click("random")
  }
  })

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
    common$meta$select_query$date <- input$date
    common$meta$select_query$poly <- common$poly
    common$meta$select_query$name <- "FCover"
    common$meta$select_query$used <- TRUE
    # TRIGGER ####
    gargoyle::trigger("select_query")
    show_map(parent_session)
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

  #pick a random location over land, but fail safely in case the API is broken
  gargoyle::on("select_query_random", {
    random_land <- httr2::request("https://api.3geonames.org/?randomland=yes") |> httr2::req_perform()
    if (random_land$status_code == 200){
      random_land <- httr2::resp_body_xml(random_land) |> xml2::as_list()
      map %>% setView(random_land$geodata$nearest$longt, random_land$geodata$nearest$latt, zoom = 9)
    } else {
      common$logger %>% writeLog(type = "error", "Something went wrong requesting a random location")
    }
  })

  req(common$ras)
  ex <- as.vector(terra::ext(common$ras))
  pal <- colorBin("Greens", domain = terra::values(common$ras), bins = 9, na.color = "pink")
  map %>%
    removeDrawToolbar(clearFeatures = TRUE) %>%
    addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE, markerOptions = FALSE,
                   circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE) %>%
    clearGroup(common$meta$select_query$name) %>%
    addRasterImage(common$ras, colors = pal, group = common$meta$select_query$name) %>%
    addTiles(urlTemplate = "", attribution = "Copernicus Sentinel data 2023") %>%
    fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
    addLegend(position = "bottomright", pal = pal, values = terra::values(common$ras),
              group = common$meta$select_query$name, title = common$meta$select_query$name) %>%
    addLayersControl(overlayGroups = common$meta$select_query$name, options = layersControlOptions(collapsed = FALSE))
}

select_query_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_query_knit = !is.null(common$meta$select_query$used),
    select_date = common$meta$select_query$date,
    select_poly = printVecAsis(common$meta$select_query$poly),
    select_name = common$meta$select_query$name

  )
}
