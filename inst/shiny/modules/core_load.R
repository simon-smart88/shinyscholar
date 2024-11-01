core_load_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
  h4("Load session"),
  includeMarkdown("Rmd/text_loadsesh.Rmd"),
  fileInput(ns("load_session"), "", accept = ".rds"),
  actionButton(ns("goLoad_session"), "Load RDS")
  )
  }

core_load_module_server <- function(id, common, modules, map, COMPONENT_MODULES, parent_session) {
  moduleServer(id, function(input, output, session) {

    observe({
      shinyjs::toggleState("goLoad_session", !is.null(input$load_session$datapath))
    })

    observeEvent(input$goLoad_session, {
      temp <- readRDS(input$load_session$datapath)

      temp_names <- names(temp)
      #exclude the non-public and function objects
      temp_names  <- temp_names[!temp_names %in% c("clone", ".__enclos_env__", "logger")]
      for (name in temp_names){
        common[[name]] <- temp[[name]]
      }

      # Ask each module to load its own data
      for (module_id in names(common$state)) {
        if (module_id != "main"){
          modules[[module_id]]$load(common$state[[module_id]])
        }}

      for (component in names(common$state$main$selected_module)) {
        value <- common$state$main$selected_module[[component]]
        updateRadioButtons(parent_session, glue("{component}Sel"), selected = value)
      }

      #required due to terra objects being pointers to c++ objects
      common$raster <- terra::unwrap(common$raster)

      #restore map and results for used modules
      for (used_module in names(common$meta)){
        gargoyle::trigger(used_module) # to replot results
        component <- strsplit(used_module, "_")[[1]][1]
        map_fx <- COMPONENT_MODULES[[component]][[used_module]]$map_function
        if (!is.null(map_fx)) {
          do.call(map_fx, list(map, common = common))
        }
      }

      common$logger %>% writeLog(type="info", "The previous session has been loaded successfully")
    })

  }
)}

