library(shinyscholar)

source(system.file("shiny/common.R", package = "shinyscholar"))

function(input, output, session) {

  ########################## #
  # INTRODUCTION ####
  ########################## #

  core_intro_module_server("core_intro")

  ########################## #
  # REACTIVE VALUES LISTS ####
  ########################## #

  # Variable to keep track of current log message
  initLogMsg <- function() {
    intro <- "***WELCOME TO shinyscholar***"
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

  ################################
  ### COMMON LIST FUNCTIONALITY ####
  ################################

  common <- common_class$new()
  common$logger <- reactiveVal(initLogMsg())

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
  help_components <- c("select", "plot", "template")
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
  ### MAPPING LOGIC ####
  ######################## #

  map <- core_mapping_module_server("core_mapping", common)

  # Call the module-specific map function for the current module
  observe({
    req(module())
    map_fx <- COMPONENT_MODULES[[component()]][[module()]]$map_function
    if (!is.null(map_fx)) {
      do.call(map_fx, list(map, common = common))
    }
  })

  ######################## #
  ### BUTTONS LOGIC ####
  ######################## #

  # Enable/disable buttons
  observe({
    shinyjs::toggleState("goLoad_session", !is.null(input$load_session$datapath))
    req(common$ras)
    #shinyjs::toggleState("dl_table", !is.null(common$ras))
  })

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

    output$code_module <- renderPrint({
    req(module())

    if (input$code_choice == "Module"){
      code <- readLines(system.file(glue("shiny/modules/{module()}.R"), package = "shinyscholar"))
    }
    if (input$code_choice == "Function"){
      #separate call required in case there are multiple functions
      ga_call <- getAnywhere(module())
      code <- capture.output(print(getAnywhere(module())[which(ga_call$where == "package:shinyscholar")]))
      code <- code[1:(length(code)-2)]
    }
    if (input$code_choice == "Markdown"){
      if (file.exists(system.file(glue::glue("shiny/modules/{module()}.Rmd"), package = "shinyscholar"))){
        code <- readLines(system.file(glue::glue("shiny/modules/{module()}.Rmd"), package = "shinyscholar"))
      } else {
        code <- "There is no markdown file for this module"
        }
    }
    cat(code, sep = "\n")
  })

  ########################################### #
  ### PLOT OBSERVERS ####
  ########################################### #

  #switch to the results tab so that the plot is shown when run
  observeEvent(gargoyle::watch("plot_hist"), updateTabsetPanel(session, "main", selected = "Results"), ignoreInit = TRUE)
  observeEvent(gargoyle::watch("plot_scatter"), updateTabsetPanel(session, "main", selected = "Results"), ignoreInit = TRUE)

  ####################
  ### INITIALISATION ####
  ###################

  # Initialize all modules
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

  observe({
    common_size <- as.numeric(utils::object.size(common))
    shinyjs::toggle("save_warning", condition = (common_size >= SAVE_SESSION_SIZE_MB_WARNING * MB))
  })

  # Save the current session to a file
  save_session <- function(file) {

    common$state$main <- list(
      selected_module = sapply(COMPONENTS, function(x) input[[glue("{x}Sel")]], simplify = FALSE)
    )

    # Ask each module to save whatever data it wants
    for (module_id in names(modules)) {
      common$state[[module_id]] <- modules[[module_id]]$save()
    }

    # wrap and unwrap required due to terra objects being pointers to c++ objects
    if (is.null(common$ras) == FALSE){
    common$ras <- terra::wrap(common$ras)
    }

    saveRDS(common, file)

    if (is.null(common$ras) == FALSE){
    common$ras <- terra::unwrap(common$ras)
    }
  }

  output$save_session <- downloadHandler(
    filename = function() {
      paste0("shinyscholar-session-", Sys.Date(), ".rds")
    },
    content = function(file) {
      save_session(file)
    }
  )

  load_session <- function(file) {
    temp <- readRDS(file)
    temp

    }

  observeEvent(input$goLoad_session, {
    temp <- load_session(input$load_session$datapath)
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

    common$logger %>% writeLog(type="info","The previous session has been loaded successfully")
  })

  ################################
  ### EXPORT TEST VALUES ####
  ################################
  exportTestValues(common = common)
}
