select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = c('2023-06-20','2023-06-30','2023-07-10','2023-07-20')),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(common$poly)) {
      common$logger %>% writeLog(type = 'error', "Please draw a rectangle on the map")
      return()
    }
    req(input$date,common$poly)
    # FUNCTION CALL ####
    poly <- SpatialPolygons(list(Polygons(list(Polygon(common$poly)),1)))
    extent <- terra::ext(poly)
    ras <- select_query(extent,input$date)
    # LOAD INTO COMMON ####
    common$ras <- ras
    # METADATA ####
    common$meta$query$date <- input$date
    common$meta$query$poly <- common$poly
    common$meta$ras$name <- 'FCover'
    common$meta$query$used <- TRUE
    trigger("select_query")
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

select_query_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  verbatimTextOutput(ns("result"))
}

select_query_module_map <- function(map, common) {
  observeEvent(watch("select_query"),{
  req(common$meta$query$used == T)
  ex <- as.vector(terra::ext(common$ras))
  pal <- colorBin("Greens", domain = terra::values(common$ras), bins = 9,na.color ="#00000000")
  map %>%
    clearGroup(common$meta$ras$name) %>%
    addRasterImage(raster::raster(common$ras),colors = pal,group=common$meta$ras$name) %>%
    fitBounds(lng1=ex[[1]],lng2=ex[[2]],lat1=ex[[3]],lat2=ex[[4]]) %>%
    addLegend(position ="bottomright",pal = pal, values = terra::values(common$ras), group=common$meta$ras$name, title=common$meta$ras$name) %>%
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

