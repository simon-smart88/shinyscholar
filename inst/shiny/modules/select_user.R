select_user_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    fileInput(inputId = ns("raster"),
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
    if (is.null(input$raster)) {
      common$logger %>% writeLog(type = "error", "Please upload a raster file")
      return()
    }
    if (input$name == "") {
      common$logger %>% writeLog(type = "error", "Please enter a name for the raster file")
      return()
    }
    # FUNCTION CALL ####
    raster <- select_user(input$raster$datapath)
    # LOAD INTO COMMON ####
    common$raster <- raster
    # METADATA ####
    common$meta$select_user$name <- input$name
    common$meta$select_user$path <- input$raster$name
    common$meta$select_user$used <- TRUE
    # TRIGGER ####
    trigger("select_user")
    show_map(parent_session)
    # only required for testing enter key input
    shinyjs::runjs("Shiny.setInputValue('select_user-complete', 'complete');")

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
    req(common$raster)
    ex <- as.vector(terra::ext(common$raster))
    pal <- RColorBrewer::brewer.pal(9, "YlOrRd")
    custom_reds <- colorRampPalette(pal)(10)
    color_bins <- colorBin(custom_reds, domain = terra::values(common$raster), bins = 10, na.color = "#00000000")

    raster_name <- common$meta$select_user$name
    map %>%
      clearGroup(raster_name) %>%
      clearControls() %>%
      removeControl(raster_name) %>%
      addRasterImage(common$raster, colors = color_bins, group = raster_name) %>%
      fitBounds(lng1 = ex[[1]], lng2 = ex[[2]], lat1 = ex[[3]], lat2 = ex[[4]]) %>%
      addLegend(position = "bottomright", pal = color_bins, values = terra::values(common$raster),
                group = raster_name, title = raster_name) %>%
      addLayersControl(overlayGroups = raster_name, options = layersControlOptions(collapsed = FALSE))
}

select_user_module_rmd <- function(common) {
  # Variables used in the module's Rmd code
  list(
    select_user_knit = !is.null(common$meta$select_user$used),
    select_user_path = common$meta$select_user$path,
    select_user_name = common$meta$select_user$name
  )
}
