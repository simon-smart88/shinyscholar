core_load_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
  h4("Load session"),
  includeMarkdown("Rmd/text_loadsesh.Rmd"),
  fileInput(ns("load_session"), "", accept = ".rds"),
  actionButton(ns("goLoad_session"), "Load RDS")
  )
  }

core_load_module_server <- function(id, common) {
  moduleServer(id, function(input, output, session) {

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
        updateRadioButtons(session, glue("{component}Sel"), selected = value)
      }

      #required due to terra objects being pointers to c++ objects
      common$ras <- terra::unwrap(common$ras)

      common$logger %>% writeLog(type="info", "The previous session has been loaded successfully")
    })

  }
)}

