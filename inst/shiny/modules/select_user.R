select_user_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    fileInput(inputId = ns("ras"),
              label = "Upload raster",
              multiple = FALSE,
              accept = c(".tif")),
    textInput(ns("name"), "Raster name", value = ""),
    actionButton(ns("run"), "Plot raster")
  )
}

select_user_module_server <- function(id, common, parent_session, map) {
  moduleServer(id, function(input, output, session) {

  observeEvent(input$run, {
    # WARNING ####
    if (is.null(input$ras)) {
      common$logger %>% writeLog(type = "error", "Please upload a raster file")
      return()
    }
    if (input$name == "") {
      common$logger %>% writeLog(type = "error", "Please enter a name for the raster file")
      return()
    }
    # FUNCTION CALL ####
    ras <- select_user(input$ras$datapath)
    # LOAD INTO COMMON ####
    common$ras <- ras
    # METADATA ####
    common$meta$select_user$name <- input$name
    common$meta$select_user$path <- input$ras$name
    common$meta$select_user$used <- TRUE
    # TRIGGER ####
    gargoyle::trigger("select_user")
    show_map(parent_session)
  })

  return(list(
    save = function() {list(
      ### Manual save start
      ### Manual save end
      name = input$name)
    },
    load = function(state) {
      ### Manual load start
      ### Manual load end
      updateTextInput(session, "name", value = state$name)
    }
  ))
})
}

select_user_module_map <- function(map, common) {
    req(common$ras)
    ex <- as.vector(terra::ext(common$ras))
    pal <- colorBin("YlOrRd", domain = terra::values(common$ras), bins = 9, na.color = "#00000000")
    raster_name <- common$meta$select_user$name
    map %>%
      clearGroup(raster_name) %>%
      addRasterImage(common$ras, colors = pal, group = raster_name) %>%
      fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
      addLegend(position = "bottomright", pal = pal, values = terra::values(common$ras),
                group = raster_name, title = raster_name) %>%
      addLayersControl(overlayGroups = raster_name, options = layersControlOptions(collapsed = FALSE))
}

select_user_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_user_knit = !is.null(common$meta$select_user$used),
    user_path = common$meta$select_user$path,
    user_name = common$meta$select_user$name
  )
}
