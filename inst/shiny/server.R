library(SMART)

source(system.file("shiny/common.R", package = "SMART"))

function(input, output, session) {

  ########################## #
  # REACTIVE VALUES LISTS ####
  ########################## #

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
  help_components <- c("select","plot")
  lapply(help_components, function(component) {
    btn_id <- paste0(component, "Help")
    observeEvent(input[[btn_id]], updateTabsetPanel(session, "main", "Component Guidance"))
  })

  # Help Module
  observeEvent(input$select_queryHelp, updateTabsetPanel(session, "main", "Module Guidance"))
  observeEvent(input$select_userHelp, updateTabsetPanel(session, "main", "Module Guidance"))
  observeEvent(input$plot_histHelp, updateTabsetPanel(session, "main", "Module Guidance"))
  observeEvent(input$plot_scatterHelp, updateTabsetPanel(session, "main", "Module Guidance"))

  ######################## #
  ### MAPPING LOGIC ####
  ######################## #

  # create map
  output$map <- renderLeaflet(
    leaflet() %>%
      setView(0, 0, zoom = 2) %>%
      addProviderTiles("Esri.WorldTopoMap") %>%
      addDrawToolbar(polylineOptions = FALSE, circleOptions = FALSE, rectangleOptions = TRUE,
                     markerOptions = FALSE, circleMarkerOptions = FALSE, singleFeature = TRUE, polygonOptions = FALSE)
  )

  # create map proxy to make further changes to existing map
  map <- leafletProxy("map")

  # change provider tile option
  observe({
    map %>% addProviderTiles(input$bmap)
  })

  # Call the module-specific map function for the current module
  observe({
    req(module())
    map_fx <- COMPONENT_MODULES[[component()]][[module()]]$map_function
    if (!is.null(map_fx)) {
      do.call(map_fx, list(map, common = common))
    }
  })

  # Capture coordinates of polygons
  observe({
    coords <- unlist(input$map_draw_new_feature$geometry$coordinates)
    xy <- matrix(c(coords[c(TRUE,FALSE)], coords[c(FALSE,TRUE)]), ncol=2)
    colnames(xy) <- c("longitude", "latitude")
    #convert any longitudes drawn outside of the original map
    xy[,1] <- ((xy[,1] + 180) %% 360) - 180
    common$poly <- xy
    gargoyle::trigger("change_poly")
  }) %>% bindEvent(input$map_draw_new_feature)

  gargoyle::init("change_poly")

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
      "SMART_sample_table.csv"
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
      code <- readLines(system.file(glue("shiny/modules/{module()}.R"),package = "SMART"))
    }
    if (input$code_choice == "Function"){
      #separate call required in case there are multiple functions
      ga_call <- getAnywhere(module())
      code <- capture.output(print(getAnywhere(module())[which(ga_call$where == "package:SMART")]))
      code <- code[1:(length(code)-2)]
    }
    if (input$code_choice == "Markdown"){
      code <- readLines(system.file(glue("shiny/modules/{module()}.Rmd"), package = "SMART"))
    }
    cat(code,sep="\n")
  })

  ########################################### #
  ### PLOT OBSERVERS ####
  ########################################### #

  #switch to the results tab so that the plot is shown when run
  observeEvent(gargoyle::watch("plot_hist"), updateTabsetPanel(session, "main", selected = "Results"), ignoreInit = TRUE)
  observeEvent(gargoyle::watch("plot_scatter"), updateTabsetPanel(session, "main", selected = "Results"), ignoreInit = TRUE)

  ########################################### #
  ### RMARKDOWN FUNCTIONALITY ####
  ########################################### #

  filetype_to_ext <- function(type = c("Rmd", "PDF", "HTML", "Word")) {
    type <- match.arg(type)
    switch(
      type,
      Rmd = ".Rmd",
      PDF = ".pdf",
      HTML = ".html",
      Word = ".docx"
    )
  }

  # handler for R Markdown download
  output$dlRMD <- downloadHandler(
    filename = function() {
      paste0("SMART-session-", Sys.Date(), filetype_to_ext(input$rmdFileType))
    },
    content = function(file) {
      md_files <- c()
      md_intro_file <- tempfile(pattern = "intro_", fileext = ".md")
      rmarkdown::render("Rmd/userReport_intro.Rmd",
                        output_format = rmarkdown::github_document(html_preview = FALSE),
                        output_file = md_intro_file,
                        clean = TRUE,
                        encoding = "UTF-8")
      md_files <- c(md_files, md_intro_file)


      module_rmds <- NULL
      for (component in names(COMPONENT_MODULES[names(COMPONENT_MODULES) != c("rep")])) {
        for (module in COMPONENT_MODULES[[component]]) {
          rmd_file <- module$rmd_file
          rmd_function <- module$rmd_function
          if (is.null(rmd_file)) next

          if (is.null(rmd_function)) {
            rmd_vars <- list()
          } else {
            rmd_vars <- do.call(rmd_function, list(common))
          }
          knit_params <- c(
            file = rmd_file,
            rmd_vars
          )
          module_rmd <- do.call(knitr::knit_expand, knit_params)

          module_rmd_file <- tempfile(pattern = paste0(module$id, "_"),
                                      fileext = ".Rmd")
          writeLines(module_rmd, module_rmd_file)
          module_rmds <- c(module_rmds, module_rmd_file)
        }
      }

      module_md_file <- tempfile(pattern = paste0(module$id, "_"),
                                  fileext = ".md")
      rmarkdown::render(input = "Rmd/userReport_module.Rmd",
                        params = list(child_rmds = module_rmds),
                        output_format = rmarkdown::github_document(html_preview = FALSE),
                        output_file = module_md_file,
                        clean = TRUE,
                        encoding = "UTF-8")
      md_files <- c(md_files, module_md_file)

      combined_md <-
        md_files %>%
        lapply(readLines) %>%
        lapply(paste, collapse = "\n") %>%
        paste(collapse = "\n\n")

      result_file <- tempfile(pattern = "result_", fileext = filetype_to_ext(input$rmdFileType))
      if (input$rmdFileType == "Rmd") {
        combined_rmd <- gsub("``` r", "```{r}", combined_md)
        writeLines(combined_rmd, result_file, useBytes = TRUE)
      } else {
        combined_md_file <- tempfile(pattern = "combined_", fileext = ".md")
        writeLines(combined_md, combined_md_file)
        rmarkdown::render(
          input = combined_md_file,
          output_format =
            switch(
              input$rmdFileType,
              "PDF" = rmarkdown::pdf_document(),
              "HTML" = rmarkdown::html_document(),
              "Word" = rmarkdown::word_document()
            ),
          output_file = result_file,
          clean = TRUE,
          encoding = "UTF-8"
        )
      }

      file.rename(result_file, file)
    }
  )

  ################################
  ### REFERENCE FUNCTIONALITY ####
  ################################

  output$dlrefPackages <- downloadHandler(
    filename = function() {paste0("ref-packages-", Sys.Date(),
                                  filetype_to_ext(input$refFileType))},
    content = function(file) {
      # Create BIB file
      bib_file <- "Rmd/references.bib"
      temp_bib_file <- tempfile(pattern = "ref_", fileext = ".bib")
      # Package always cited
      knitcitations::citep(citation("SMART"))
      knitcitations::citep(citation("knitcitations"))
      knitcitations::citep(citation("knitr"))
      knitcitations::citep(citation("rmarkdown"))
      knitcitations::citep(citation("terra"))
      knitcitations::citep(citation("raster"))
      # Write BIBTEX file
      knitcitations::write.bibtex(file = temp_bib_file)
      # Replace NOTE fields with VERSION when R package
      bib_ref <- readLines(temp_bib_file)
      bib_ref  <- gsub(pattern = "note = \\{R package version", replace = "version = \\{R package", x = bib_ref)
      writeLines(bib_ref, con = temp_bib_file)
      file.rename(temp_bib_file, bib_file)
      # Render reference file
      md_ref_file <- tempfile(pattern = "ref_", fileext = ".md")
      rmarkdown::render("Rmd/references.Rmd",
                        output_format =
                          switch(
                            input$refFileType,
                            "PDF" = rmarkdown::pdf_document(),
                            "HTML" = rmarkdown::html_document(),
                            "Word" = rmarkdown::word_document()
                          ),
                        output_file = file,
                        clean = TRUE,
                        encoding = "UTF-8")
    })

  ################################
  ### COMMON LIST FUNCTIONALITY ####
  ################################

  common <- common_class$new()
  common$logger <- reactiveVal(initLogMsg())

  ####################
  ### INITIALISATION ####
  ###################

  # Initialize all modules
  modules <- list()
  lapply(names(COMPONENT_MODULES), function(component) {
    lapply(COMPONENT_MODULES[[component]], function(module) {
      # Initialize event triggers for each module
      gargoyle::init(module$id)
      return <- do.call(get(module$server_function), args = list(id = module$id, common = common))
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
      paste0("SMART-session-", Sys.Date(), ".rds")
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
