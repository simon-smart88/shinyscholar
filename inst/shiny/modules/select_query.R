select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = c('2023-01-10','2023-01-20','2023-01-31','2023-02-10','2023-02-20','2023-02-28',
                          '2023-03-10','2023-03-20','2023-03-31','2023-04-10','2023-04-20','2023-04-30',
                          '2023-05-10','2023-05-20','2023-05-31','2023-06-10','2023-06-20','2023-06-30',
                          '2023-07-10','2023-07-20')),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####
    req(input$date,common$poly)
    poly <- SpatialPolygons(list(Polygons(list(Polygon(common$poly)),1)))
    extent <- terra::ext(poly)
    # FUNCTION CALL ####
    ras <- select_query(extent,input$date)
    # LOAD INTO COMMON ####
    common$ras <- ras
    # METADATA ####
    common$meta$query$poly <- input$poly
    common$meta$query$date <- input$date
    common$meta$ras$name <- 'Fcover'
    common$meta$query$used <- TRUE
    trigger("change_query_ras")
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
  observeEvent(watch("change_query_ras"),{
  req(common$meta$query$used == T)
  ex <- terra::ext(common$ras)
  print(paste(x[1],ex[2],ex[3],ex[4]))
  pal <- colorBin("Greens", domain = terra::values(common$ras), bins = 9,na.color ="#00000000")
  map %>%
    clearGroup(common$meta$ras$name) %>%
    addRasterImage(raster::raster(common$ras),colors = pal,group=common$meta$ras$name) %>%
    fitBounds(lng1=ex[1],lng2=ex[2],lat1=ex[3],lat2=ex[4]) %>%
    addLegend(position ="bottomright",pal = pal, values = terra::values(common$ras), group=common$meta$ras$name, title=common$meta$ras$name) %>%
    addLayersControl(overlayGroups = common$meta$ras$name, options = layersControlOptions(collapsed = FALSE))
  })
}

select_query_module_rmd <- function(species) {
  # Variables used in the module's Rmd code
  list(
    select_query_knit = !is.null(common$meta$query$used),
    select_date = common$meta$query$date,
    select_poly = common$meta$query$poly,
    select_name = common$ras$name

  )
}

