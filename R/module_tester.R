#' @title Run an individual \emph{SMART} module for testing
#' @description This function runs the selected \emph{SMART} module
#' @param module The name of the module to run
#'
#' @examples
#' if(interactive()) {
#' test_module("select_query")
#' }
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

test_module <- function(module){

#load the module functions
source(system.file(glue::glue("shiny/modules/{module}.R"), package = "SMART"))

#load js
resourcePath <- system.file("shiny", "www", package = "SMART")
shiny::addResourcePath("smartres", resourcePath)

test_ui <- tagList(
  shinyjs::useShinyjs(),
  shinyjs::extendShinyjs(
    script = file.path("smartres", "js", "shinyjs-funcs.js"),
    functions = c("scrollLogger", "disableModule", "enableModule")
  ),
  fluidPage(
  div(id = "wallaceLog",div(id = "logHeader", div(id = "logContent"))),
  do.call(glue::glue("{module}_module_ui"),list(module)),
  if (exists(glue::glue("{module}_module_result"))){do.call(glue::glue("{module}_module_result"),list(module))},
  if (exists(glue::glue("{module}_module_map"))){leaflet::leafletOutput("map", height = 700)}
  )
)

test_server <- function(input, output, session) {

  #initiate gargoyle event
  gargoyle::init(module)

  # Variable to keep track of current log message
  initLogMsg <- function() {
    intro <- "***WELCOME TO SMART***"
    brk <- paste(rep("------", 14), collapse = "")
    expl <- "Please find messages for the user in this log window."
    logInit <- gsub(".{4}$", "", paste(intro, brk, expl, brk, "", sep = "<br>"))
    logInit
  }

  # Write out logs to the log Window
  observeEvent(common$logger(), {
    shinyjs::html(id = "logHeader", html = common$logger(), add = FALSE)
    shinyjs::js$scrollLogger()
  })

  #create common class and then initiate instance
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

  common <- common_class$new()
  common$logger <- reactiveVal(initLogMsg())

  #load demo raster data if testing a plotting module
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
  gargoyle::init("change_poly")
  observe({
    coords <- unlist(input$map_draw_new_feature$geometry$coordinates)
    xy <- matrix(c(coords[c(TRUE, FALSE)], coords[c(FALSE, TRUE)]), ncol = 2)
    colnames(xy) <- c("longitude", "latitude")
    #convert any longitudes drawn outside of the original map
    xy[,1] <- ((xy[,1] + 180) %% 360) - 180
    common$poly <- xy
    trigger("change_poly")
  }) %>% bindEvent(input$map_draw_new_feature)

  #main server function
  callModule(get(glue::glue("{module}_module_server")), module, common)

  #load map function if it exists
  if (exists(glue::glue("{module}_module_map"))){
  map <- leafletProxy("map")
  do.call(glue::glue("{module}_module_map"), list(map, common))}
}

shinyApp(test_ui,test_server)
}


