library(leaflet)
library(wallace)
library(shiny)
library(leaflet.extras)
library(gargoyle)
library(terra)
library(sp)

function(input, output, session) {
  ########################## #
  # REACTIVE VALUES LISTS ####
  ########################## #

  # Variable to keep track of current log message
  initLogMsg <- function() {
    intro <- '***WELCOME TO SMART***'
    brk <- paste(rep('------', 14), collapse = '')
    expl <- 'Please find messages for the user in this log window.'
    logInit <- gsub('.{4}$', '', paste(intro, brk, expl, brk, '', sep = '<br>'))
    logInit
  }
  logger <- reactiveVal(initLogMsg())

  # Write out logs to the log Window
  observeEvent(logger(), {
    shinyjs::html(id = "logHeader", html = logger(), add = FALSE)
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
    file <- file.path('Rmd', glue("gtext_{component()}.Rmd"))
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
      addProviderTiles('Esri.WorldTopoMap') %>%
      addDrawToolbar(polylineOptions=F,circleOptions = F, rectangleOptions = T, markerOptions = F, circleMarkerOptions = F, singleFeature = T,polygonOptions = F)
  )

  # create map proxy to make further changes to existing map
  map <- leafletProxy("map")

  # change provider tile option
  observe({
    map %>% addProviderTiles(input$bmap)
  })

  # Call the module-specific map function for the current module
  observe({
    # must have one species selected and occurrence data
    req(module())
    map_fx <- COMPONENT_MODULES[[component()]][[module()]]$map_function
    if (!is.null(map_fx)) {
      do.call(map_fx, list(map, common = common))
    }
  })

  observeEvent(input$map_draw_new_feature, {
    coords <- unlist(input$map_draw_new_feature$geometry$coordinates)
    xy <- matrix(c(coords[c(TRUE,FALSE)], coords[c(FALSE,TRUE)]), ncol=2)
    colnames(xy) <- c('longitude', 'latitude')
    common$poly <- xy
    trigger("change_poly")
  })

  ######################## #
  ### BUTTONS LOGIC ####
  ######################## #

  # Enable/disable buttons
  observe({
    shinyjs::toggleState("goLoad_session", !is.null(input$load_session$datapath))
    req(common$ras)
    # shinyjs::toggleState("dlData", !is.null(occs()))
    # shinyjs::toggleState("dlPlot", !is.null(occs()))

    # shinyjs::toggleState("dlWhatever", !is.null(spp[[curSp()]]$whatever))
  })


  # # # # # # # # # # # # # # # # # #
  # OBTAIN OCCS: other controls ####
  # # # # # # # # # # # # # # # # # #

  # TABLE
  output$table <- DT::renderDataTable({
    # check that a raster exists
    req(common$ras)
    sample_table <- terra::spatSample(common$ras,100,method='random',xy=T,as.df=T)
    colnames(sample_table) <- c('Longitude','Latitude','Value')
    sample_table %>%
      dplyr::mutate(Longitude = round(as.numeric(Longitude), digits = 4),
                    Latitude = round(as.numeric(Latitude), digits = 4))
  }, rownames = FALSE, options = list(scrollX = TRUE))
  #
  # # DOWNLOAD: current species occurrence data table
  # output$dlOccs <- downloadHandler(
  #   filename = function() {
  #     n <- fmtSpN(curSp())
  #     source <- rmm()$data$occurrence$sources
  #     glue("{n}_{source}.csv")
  #   },
  #   content = function(file) {
  #     tbl <- occs() %>%
  #       dplyr::select(-c(pop, occID))
  #     # if bg values are present, add them to table
  #     if(!is.null(bg())) {
  #       tbl <- rbind(tbl, bg())
  #     }
  #     write_csv_robust(tbl, file, row.names = FALSE)
  #   }
  # )


  ############################################# #
  ### COMPONENT: SELECT DATA ####
  ############################################# #




  ########################################### #
  ### RMARKDOWN FUNCTIONALITY ####
  ########################################### #

  filetype_to_ext <- function(type = c("Rmd", "PDF", "HTML", "Word")) {
    type <- match.arg(type)
    switch(
      type,
      Rmd = '.Rmd',
      PDF = '.pdf',
      HTML = '.html',
      Word = '.docx'
    )
  }

  # handler for R Markdown download
  output$dlRMD <- downloadHandler(
    filename = function() {
      paste0("wallace-session-", Sys.Date(), filetype_to_ext(input$rmdFileType))
    },
    content = function(file) {
      spp <- common$spp
      md_files <- c()
      md_intro_file <- tempfile(pattern = "intro_", fileext = ".md")
      rmarkdown::render("Rmd/userReport_intro.Rmd",
                        output_format = rmarkdown::github_document(html_preview = FALSE),
                        output_file = md_intro_file,
                        clean = TRUE,
                        encoding = "UTF-8")
      md_files <- c(md_files, md_intro_file)
      # Abbreviation for one species
      spAbr <- plyr::alply(abbreviate(stringr::str_replace(allSp(), "_", " "),
                                      minlength = 2),
                           .margins = 1, function(x) {x <- as.character(x)})
      names(spAbr) <- allSp()

      for (sp in allSp()) {
        species_rmds <- NULL
        for (component in names(COMPONENT_MODULES[names(COMPONENT_MODULES) != c("espace", "rep")])) {
          for (module in COMPONENT_MODULES[[component]]) {
            rmd_file <- module$rmd_file
            rmd_function <- module$rmd_function
            if (is.null(rmd_file)) next

            if (is.null(rmd_function)) {
              rmd_vars <- list()
            } else {
              rmd_vars <- do.call(rmd_function, list(species = spp[[sp]]))
            }
            knit_params <- c(
              file = rmd_file,
              spName = spName(sp),
              sp = sp,
              spAbr = spAbr[[sp]],
              rmd_vars
            )
            module_rmd <- do.call(knitr::knit_expand, knit_params)

            module_rmd_file <- tempfile(pattern = paste0(module$id, "_"),
                                        fileext = ".Rmd")
            writeLines(module_rmd, module_rmd_file)
            species_rmds <- c(species_rmds, module_rmd_file)
          }
        }

        species_md_file <- tempfile(pattern = paste0(sp, "_"),
                                    fileext = ".md")
        rmarkdown::render(input = "Rmd/userReport_species.Rmd",
                          params = list(child_rmds = species_rmds,
                                        spName = spName(sp),
                                        spAbr = spAbr[[sp]]),
                          output_format = rmarkdown::github_document(html_preview = FALSE),
                          output_file = species_md_file,
                          clean = TRUE,
                          encoding = "UTF-8")
        md_files <- c(md_files, species_md_file)
      }

      combined_md <-
        md_files %>%
        lapply(readLines) %>%
        lapply(paste, collapse = "\n") %>%
        paste(collapse = "\n\n")

      result_file <- tempfile(pattern = "result_", fileext = filetype_to_ext(input$rmdFileType))
      if (input$rmdFileType == "Rmd") {
        combined_rmd <- gsub('``` r', '```{r}', combined_md)
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
      knitcitations::citep(citation("wallace"))
      knitcitations::citep(citation("knitcitations"))
      knitcitations::citep(citation("knitr"))
      knitcitations::citep(citation("rmarkdown"))
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
  ### COMMON LIST FUNTIONALITY ####
  ################################

  common_class <- R6::R6Class(
    classname = "common",
    public = list(
      ras = NULL,
      hist = NULL,
      scat = NULL,
      meta = NULL,
      logger = NULL
    )
  )

  common <- common_class$new()
  common$logger <- reactiveVal(initLogMsg())

  # Initialize all modules
  modules <- list()
  lapply(names(COMPONENT_MODULES), function(component) {
    lapply(COMPONENT_MODULES[[component]], function(module) {
      return <- callModule(get(module$server_function), module$id, common = common)
      if (is.list(return) &&
          "save" %in% names(return) && is.function(return$save) &&
          "load" %in% names(return) && is.function(return$load)) {
        modules[[module$id]] <<- return
      }
    })
  })

  # should add these as part of the setup
  gargoyle::init("change_user_ras")
  gargoyle::init("change_query_ras")
  gargoyle::init("change_poly")

  observe({
    common_size <- as.numeric(utils::object.size(common))
    shinyjs::toggle("save_warning", condition = (common_size >= SAVE_SESSION_SIZE_MB_WARNING * MB))
  })

  output$code_module <- renderPrint({
    req(module())
    if (input$code_choice == 'Module'){code <- readLines(glue("modules/{module()}.R"))}
    if (input$code_choice == 'Function'){code <- readLines(glue("../../R/{module()}.R"))}
    cat(code,sep='\n')
  })

  # Save the current session to a file
  save_session <- function(file) {
    state <- list()

    spp_save <- reactiveValuesToList(spp)

    # Save general data
    state$main <- list(
      version = as.character(packageVersion("wallace")),
      spp = spp_save,
      envs_global = reactiveValuesToList(envs.global),
      cur_sp = input$curSp,
      selected_module = sapply(COMPONENTS, function(x) input[[glue("{x}Sel")]], simplify = FALSE)
    )

    # Ask each module to save whatever data it wants
    for (module_id in names(modules)) {
      state[[module_id]] <- modules[[module_id]]$save()
    }

    saveRDS(state, file)
  }

  output$save_session <- downloadHandler(
    filename = function() {
      paste0("wallace-session-", Sys.Date(), ".rds")
    },
    content = function(file) {
      save_session(file)
    }
  )

  # Load a wallace session from a file
  load_session <- function(file) {
    if (tools::file_ext(file) != "rds") {
      shinyalert::shinyalert("Invalid session file", type = "error")
      return()
    }

    state <- readRDS(file)

    if (!is.list(state) || is.null(state$main) || is.null(state$main$version)) {
      shinyalert::shinyalert("Invalid session file", type = "error")
      return()
    }

    # Load general data
    new_version <- as.character(packageVersion("wallace"))
    if (state$main$version != new_version) {
      shinyalert::shinyalert(
        glue("The input file was saved using Wallace v{state$main$version}, but you are using Wallace v{new_version}"),
        type = "warning"
      )
    }

    for (spname in names(state$main$spp)) {
      spp[[spname]] <- state$main$spp[[spname]]
    }
    for (envname in names(state$main$envs_global)) {
      envs.global[[envname]] <- state$main$envs_global[[envname]]
    }
    for (component in names(state$main$selected_module)) {
      value <- state$main$selected_module[[component]]
      updateRadioButtons(session, glue("{component}Sel"), selected = value)
    }
    updateSelectInput(session, "curSp", selected = state$main$cur_sp)

    state$main <- NULL

    # Ask each module to load its own data
    for (module_id in names(state)) {
      modules[[module_id]]$load(state[[module_id]])
    }
  }

  observeEvent(input$goLoad_session, {
    load_session(input$load_session$datapath)
    # Select names of species in spp object
    sppLoad <- grep("\\.", names(spp), value = TRUE, invert = TRUE)
    # Storage species with no env data
    noEnvsSpp <- NULL
    for (i in sppLoad) {
      # Check if envs.global object exists in spp
      if (!is.null(spp[[i]]$envs)) {
        diskRast <- raster::fromDisk(envs.global[[spp[[i]]$envs]])
        if (diskRast) {
          if (class(envs.global[[spp[[i]]$envs]]) == "RasterStack") {
            diskExist <- !file.exists(envs.global[[spp[[i]]$envs]]@layers[[1]]@file@name)
          } else if (class(envs.global[[spp[[i]]$envs]]) == "RasterBrick") {
            diskExist <- !file.exists(envs.global[[spp[[i]]$envs]]@file@name)
          }
          if (diskExist) {
            noEnvsSpp <- c(noEnvsSpp, i)
          }
        }
      }
    }
    if (is.null(noEnvsSpp)) {
      shinyalert::shinyalert(title = "Session loaded", type = "success")
    } else {
      msgEnvAgain <- paste0("Load variables again for: ",
                            paste0(noEnvsSpp, collapse = ", "))
      shinyalert::shinyalert(title = "Session loaded", type = "warning",
                             text = msgEnvAgain)
    }
  })
}
