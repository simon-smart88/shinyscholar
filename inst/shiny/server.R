library(shinyscholar)

function(input, output, session) {

  ########################## #
  # INTRODUCTION ####
  ########################## #

  core_intro_module_server("core_intro")

  ########################## #
  # LOGGING ####
  ########################## #

  initLogMsg <- function() {
    intro <- "***WELCOME TO shinyscholar***"
    brk <- paste(rep("------", 14), collapse = "")
    expl <- "Please find messages for the user in this log window."
    logInit <- gsub(".{4}$", "", paste(intro, brk, expl, brk, "", sep = "<br>"))
    logInit
  }
  common$logger <- reactiveVal(initLogMsg())

  # Write out logs to the log Window
  observeEvent(common$logger(), {
    shinyjs::html(id = "logHeader", html = common$logger(), add = FALSE)
    shinyjs::js$scrollLogger()
  })

  ########################## #
  # REACTIVE VALUES LISTS ####
  ########################## #

  # tab and module-level reactives
  component <- reactive({
    input$tabs
  })
  observe({
    if (component() == "_stopapp") {
      shinyjs::runjs("window.close();")
      stopApp()
    }
  })
  module <- reactive({
    if (component() == "intro") "intro"
    else input[[glue("{component()}Sel")]]
  })

  ######################## #
  ### GUIDANCE TEXT ####
  ######################## #

  # UI for component guidance text
  output$gtext_component <- renderUI({
    file <- file.path("Rmd", glue("gtext_{component()}.Rmd"))
    if (!file.exists(file)) return()
    includeMarkdown(file)
  })

  # UI for module guidance text
  output$gtext_module <- renderUI({
    req(module())
    file <- COMPONENT_MODULES[[component()]][[module()]]$instructions
    if (is.null(file)) return()
    includeMarkdown(file)
  })

  # Help Component
  help_components <- COMPONENTS[!COMPONENTS == "rep"]
  lapply(help_components, function(component) {
    btn_id <- paste0(component, "Help")
    observeEvent(input[[btn_id]], updateTabsetPanel(session, "main", "Component Guidance"))
  })

  # Help Module
  lapply(help_components, function(component) {
    lapply(COMPONENT_MODULES[[component]], function(module) {
      btn_id <- paste0(module$id, "Help")
      observeEvent(input[[btn_id]], updateTabsetPanel(session, "main", "Module Guidance"))
    })})

  ######################## #
  ### MAP TAB ####
  ######################## #

  map <- core_mapping_module_server("core_mapping", common, input, COMPONENT_MODULES)

  ############################################# #
  ### TABLE TAB ####
  ############################################# #

  sample_table <- reactive({
  req(common$ras)
  gargoyle::watch("select_user")
  gargoyle::watch("select_query")
  set.seed(12345)
  sample_table <- terra::spatSample(common$ras, 100, method = "random", xy = TRUE, as.df = TRUE)
  colnames(sample_table) <- c("Longitude", "Latitude", "Value")
  sample_table %>%
    dplyr::mutate(Longitude = round(as.numeric(Longitude), digits = 4),
                  Latitude = round(as.numeric(Latitude), digits = 4))
  sample_table
  })

  # TABLE
  output$table <- DT::renderDataTable({
    # check that a raster exists
    req(common$ras)
    sample_table()
  }, rownames = FALSE, options = list(scrollX = TRUE))

  # DOWNLOAD
  output$dl_table <- downloadHandler(
    filename = function() {
      "shinyscholar_sample_table.csv"
    },
    content = function(file) {
      write.csv(sample_table(), file, row.names = FALSE)
    }
  )

  ############################################# #
  ### CODE TAB ####
  ############################################# #

  observe({
  req(module())
    module <- module()
    core_code_module_server("core_code", common, module)
  })

  ####################
  ### INITIALISATION ####
  ###################

  # Initialize all modules
  gargoyle::init("intro")
  modules <- list()
  lapply(names(COMPONENT_MODULES), function(component) {
    lapply(COMPONENT_MODULES[[component]], function(module) {
      # Initialize event triggers for each module
      gargoyle::init(module$id)
      if (module$id == "rep_markdown"){
        return <- do.call(get(module$server_function), args = list(id = module$id, common = common, parent_session = session, COMPONENT_MODULES))
      } else {
        return <- do.call(get(module$server_function), args = list(id = module$id, common = common, parent_session = session))
      }
      if (is.list(return) &&
          "save" %in% names(return) && is.function(return$save) &&
          "load" %in% names(return) && is.function(return$load)) {
        modules[[module$id]] <<- return
      }
    })
  })

  ################################
  ### SAVE / LOAD FUNCTIONALITY ####
  ################################

  core_save_module_server("core_save", common, modules, COMPONENTS, input)
  core_load_module_server("core_load", common, modules, map, COMPONENT_MODULES, parent_session = session)

  onRestored(function(common, COMPONENT_MODULES) {
    #restore map for used modules
    for (used_module in names(common$meta)){
      component <- strsplit(used_module, "_")[[1]][1]
      map_fx <- COMPONENT_MODULES[[component]][[used_module]]$map_function
      if (!is.null(map_fx)) {
        do.call(map_fx, list(map, common = common))
      }
    }
  })

  ################################
  ### EXPORT TEST VALUES ####
  ################################
  exportTestValues(common = common)
}
