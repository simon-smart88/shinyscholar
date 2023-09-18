library(SMART)
library(glue)

module <- "plot_hist"

source(glue("modules/{module}.R"))

common_class <- R6::R6Class(
  classname = "common",
  public = list(
    ras = NULL,
    hist = NULL,
    scat = NULL,
    meta = NULL,
    poly = NULL,
    logger = NULL
  )
)

ui <- fluidPage(
  do.call(glue("{module}_module_ui"),list(module)),
  if (exists(glue("{module}_module_result"))){do.call(glue("{module}_module_result"),list(module))},
  if (exists(glue("{module}_module_map"))){leaflet::leafletOutput("map", height = 700)}

)

server <- function(input, output, session) {

  init(module)

  common <- common_class$new()

  if (grepl("plot", module)){
    path <- list.files(system.file("extdata/wc", package = "SMART"),
                       pattern = ".tif$", full.names = TRUE)
    common$ras <- terra::rast(path)
  }

  # create map
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(0, 0, zoom = 2) %>%
      addProviderTiles("Esri.WorldTopoMap") %>%
      addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE,
                     markerOptions = FALSE, circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE)
  })

  # Capture coordinates of polygons
  observe({
    coords <- unlist(input$map_draw_new_feature$geometry$coordinates)
    xy <- matrix(c(coords[c(TRUE,FALSE)], coords[c(FALSE,TRUE)]), ncol=2)
    colnames(xy) <- c("longitude", "latitude")
    #convert any longitudes drawn outside of the original map
    xy[,1] <- ((xy[,1] + 180) %% 360) - 180
    common$poly <- xy
    trigger("change_poly")
  }) %>% bindEvent(input$map_draw_new_feature)

  gargoyle::init("change_poly")

  callModule(get(glue("{module}_module_server")), module, common)

  if (exists(glue("{module}_module_map"))){
  map <- leafletProxy("map")
  do.call(glue("{module}_module_map"),list(module))}
}

shinyApp(ui,server)

