select_query_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    selectInput(ns("date"), "Select date",
                choices = '2023-01-10','2023-01-20','2023-01-31','2023-02-10','2023-02-20','2023-02-28',
                          '2023-03-10','2023-03-20','2023-03-31','2023-04-10','2023-04-20','2023-04-30',
                          '2023-05-10','2023-05-20','2023-05-31','2023-06-10','2023-06-20','2023-06-30',
                          '2023-07-10','2023-07-20'),
    actionButton(ns("run"), "Load imagery")
  )
}

select_query_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####
    req(input$date,common$poly)
    poly <- SpatialPolygons(list(Polygons(list(Polygon(common$poly)),1)))
    extent <- extent(poly)
    # FUNCTION CALL ####
    ras <- select_query(extent,date)
    # LOAD INTO COMMON ####
    common$ras <- ras
    # METADATA ####
    common$meta$query$poly <- input$poly
    common$meta$query$date <- input$date
    common$meta$query$used <- T
  })

  output$result <- renderText({
    # Result
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
  observeEvent(watch("change_shape"),{
  ex <- extent(common$ras)
  pal <- colorBin("YlOrRd", domain = as.numeric(common$select_ras), bins = 9,na.color ="#00000000")
  map %>%
    clearGroup("Fcover") %>%
    addRasterImage(common$ras,colors = pal,group="Fcover") %>%
    fitBounds(lng1=ex@xmin,lng2=ex@xmax,lat1=ex@ymin,lat2=ex@ymax) %>%
    addLegend(position ="bottomright",pal = pal, values = as.numeric(common$ras), group="Fcover", title="Fcover") %>%
    addLayersControl(overlayGroups = "Fcover", options = layersControlOptions(collapsed = FALSE))
  })
}

select_query_module_rmd <- function(species) {
  # Variables used in the module's Rmd code
  list(
    select_query_knit = !is.null(common$meta$query$used),
    select_date = common$meta$query$date,
    select_poly = common$meta$query$poly
  )
}

