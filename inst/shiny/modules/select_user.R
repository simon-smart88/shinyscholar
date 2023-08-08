select_user_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    # UI
    fileInput(inputId = NS(id,"ras"),
              label = "Upload raster",
              multiple = F,
              accept = c('.tif')),
    textInput(NS(id,'name'),'Raster name', value=''),
    actionButton(ns("run"), "Plot raster")
  )
}

select_user_module_server <- function(input, output, session, common) {

  observeEvent(input$run, {
    # WARNING ####

    # FUNCTION CALL ####
    ras <- select_user(input$ras$datapath)
    # LOAD INTO SPP ####
    common$ras <- ras
    common$ras$name <- input$name
    # METADATA ####
    common$meta$user$path <- input$ras$datapath
    common$meta$user$used <- TRUE
    trigger("change_user_ras")
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

select_user_module_result <- function(id) {
  ns <- NS(id)

  # Result UI
  verbatimTextOutput(ns("result"))
}

select_user_module_map <- function(map, common) {
  observeEvent(watch("change_user_ras"),{
    req(common$meta$user$used == TRUE)
    ex <- terra::ext(common$ras)
    pal <- colorBin("YlOrRd", domain = values(common$ras), bins = 9,na.color ="#00000000")
    map %>%
      clearGroup(common$ras$name) %>%
      addRasterImage(raster::raster(common$ras),colors = pal,group=common$ras$name) %>%
      fitBounds(lng1=ex[1],lng2=ex[2],lat1=ex[3],lat2=ex[4]) %>%
      addLegend(position ="bottomright",pal = pal, values = values(common$ras), group=common$ras$name, title=common$ras$name) %>%
      addLayersControl(overlayGroups = common$ras$name, options = layersControlOptions(collapsed = FALSE))
  })
}

select_user_module_rmd <- function(species) {
  # Variables used in the module's Rmd code
  list(
    select_user_knit = !is.null(common$meta$user$used),
    user_path = common$meta$user$path,
    user_name = common$ras$name
  )
}

