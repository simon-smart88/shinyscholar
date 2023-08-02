function(input, output, session) {
  ########################## #
  # REACTIVE VALUES LISTS ####
  ########################## #

  # single species list of lists
  spp <- reactiveValues()
  envs.global <- reactiveValues()

  # Variable to keep track of current log message
  initLogMsg <- function() {
    intro <- '***WELCOME TO WALLACE***'
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
  help_components <- c("occs", "envs", "poccs", "penvs", "espace", "part", "model", "vis", "xfer")
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
      leafem::addMouseCoordinates()
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
    #req(length(curSp()) == 1, occs(), module())
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
    req(length(curSp()) == 1)
    shinyjs::toggleState("dlDbOccs", !is.null(occs()))
    shinyjs::toggleState("dlOccs", !is.null(occs()))

    # shinyjs::toggleState("dlWhatever", !is.null(spp[[curSp()]]$whatever))
  })


  # # # # # # # # # # # # # # # # # #
  # OBTAIN OCCS: other controls ####
  # # # # # # # # # # # # # # # # # #

  # TABLE
  # options <- list(autoWidth = TRUE, columnDefs = list(list(width = '40%', targets = 7)),
  #                 scrollX=TRUE, scrollY=400)
  output$occTbl <- DT::renderDataTable({
    # check if spp has species in it
    req(length(reactiveValuesToList(spp)) > 0)
    occs() %>%
      dplyr::mutate(occID = as.numeric(occID),
                    longitude = round(as.numeric(longitude), digits = 2),
                    latitude = round(as.numeric(latitude), digits = 2)) %>%
      dplyr::select(-pop) %>%
      dplyr::arrange(occID)
  }, rownames = FALSE, options = list(scrollX = TRUE))

  # DOWNLOAD: current species occurrence data table
  output$dlOccs <- downloadHandler(
    filename = function() {
      n <- fmtSpN(curSp())
      source <- rmm()$data$occurrence$sources
      glue("{n}_{source}.csv")
    },
    content = function(file) {
      tbl <- occs() %>%
        dplyr::select(-c(pop, occID))
      # if bg values are present, add them to table
      if(!is.null(bg())) {
        tbl <- rbind(tbl, bg())
      }
      write_csv_robust(tbl, file, row.names = FALSE)
    }
  )


  ############################################# #
  ### COMPONENT: SELECT DATA ####
  ############################################# #

  # # # # # # # # # # # # # # # # # #
  # OBTAIN ENVS: other controls ####
  # # # # # # # # # # # # # # # # # #

  bcSel <- reactive(input$bcSel)
  ecoClimSel <- reactive(input$ecoClimSel)
  VarSelector <- reactive(input$VarSelector)
  # shortcut to currently selected environmental variable, read from curEnvUI
  curEnv <- reactive(input$curEnv)

  # convenience function for environmental variables for current species
  envs <- reactive({
    req(curSp(), spp[[curSp()]]$envs)
    envs.global[[spp[[curSp()]]$envs]]
  })

  # map center coordinates for 30 arcsec download
  mapCntr <- reactive({
    req(occs())
    round(c(mean(occs()$longitude), mean(occs()$latitude)), digits = 3)
  })

  # CONSOLE PRINT
  output$envsPrint <- renderPrint({
    req(envs())
    envs()
  })

  output$dlGlobalEnvs <- downloadHandler(
    filename = function() paste0(spp[[curSp()]]$envs, '_envs.zip'),
    content = function(file) {
      withProgress(
        message = paste0("Preparing ", paste0(spp[[curSp()]]$envs, '_envs.zip ...')), {
          tmpdir <- tempdir()
          owd <- setwd(tmpdir)
          on.exit(setwd(owd))
          type <- input$globalEnvsFileType
          nm <- names(envs.global[[spp[[curSp()]]$envs]])

          raster::writeRaster(envs.global[[spp[[curSp()]]$envs]], nm, bylayer = TRUE,
                              format = type, overwrite = TRUE)
          ext <- switch(type, raster = 'grd', ascii = 'asc', GTiff = 'tif')

          fs <- paste0(nm, '.', ext)
          if (ext == 'grd') {
            fs <- c(fs, paste0(nm, '.gri'))
          }
          zip::zipr(zipfile = file, files = fs)
          if (file.exists(paste0(file, ".zip"))) file.rename(paste0(file, ".zip"), file)
        })
    },
    contentType = "application/zip"
  )

  

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

      if (!is.null(multSp())) {
        for (sp in multSp()) {
          namesMult <- unlist(strsplit(sp, "\\."))
          multSpecies_rmds <- NULL
          for (component in names(COMPONENT_MODULES[names(COMPONENT_MODULES) == "espace"])) {
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
                spName1 = spName(namesMult[1]),
                spName2 = spName(namesMult[2]),
                sp1 = namesMult[1],
                spAbr1 = spAbr[[namesMult[1]]],
                sp2 = namesMult[2],
                spAbr2 = spAbr[[namesMult[2]]],
                multAbr = paste0(spAbr[[namesMult[1]]], "_", spAbr[[namesMult[2]]]),
                rmd_vars
              )
              module_rmd <- do.call(knitr::knit_expand, knit_params)

              module_rmd_file <- tempfile(pattern = paste0(module$id, "_"),
                                          fileext = ".Rmd")
              writeLines(module_rmd, module_rmd_file)
              multSpecies_rmds <- c(multSpecies_rmds, module_rmd_file)
            }
          }

          multSpecies_md_file <- tempfile(pattern = paste0(sp, "_"),
                                          fileext = ".md")
          rmarkdown::render(input = "Rmd/userReport_multSpecies.Rmd",
                            params = list(child_rmds = multSpecies_rmds,
                                          spName1 = spName(namesMult[1]),
                                          spName2 = spName(namesMult[2]),
                                          multAbr = paste0(spAbr[[namesMult[1]]], "_",
                                                           spAbr[[namesMult[2]]])
                            ),
                            output_format = rmarkdown::github_document(html_preview = FALSE),
                            output_file = multSpecies_md_file,
                            clean = TRUE,
                            encoding = "UTF-8")
          md_files <- c(md_files, multSpecies_md_file)
        }
      }

      combined_md <-
        md_files %>%
        lapply(readLines) %>%
        # lapply(readLines, encoding = "UTF-8") %>%
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
  ### METADATA FUNCTIONALITY ####
  ################################

  output$dlRMM <- downloadHandler(
    filename = function() {paste0("wallace-metadata-", Sys.Date(), ".zip")},
    content = function(file) {
      tmpdir <- tempdir()
      owd <- setwd(tmpdir)
      on.exit(setwd(owd))
      # REFERENCES ####
      knitcitations::citep(citation("rangeModelMetadata"))
      namesSpp <- allSp()
      for (i in namesSpp) {
        rangeModelMetadata::rmmToCSV(spp[[i]]$rmm, filename = paste0(i, "_RMM.csv"))
      }
      zip::zipr(zipfile = file, files = paste0(namesSpp, "_RMM.csv"))
    })

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

  # Create a data structure that holds variables and functions used by modules
  common = list(
    # Reactive variables to pass on to modules
    logger = logger,
    spp = spp,
    curSp = curSp,
    allSp = allSp,
    multSp = multSp,
    curEnv = curEnv,
    curModel = curModel,
    component = component,
    module = module,
    envs.global = envs.global,
    mapCntr = mapCntr,

    # Shortcuts to values nested inside spp
    occs = occs,
    envs = envs,
    bcSel = bcSel,
    ecoClimSel = ecoClimSel,
    bg = bg,
    bgExt = bgExt,
    bgMask = bgMask,
    bgShpXY = bgShpXY,
    selCatEnvs = selCatEnvs,
    evalOut = evalOut,
    mapPred = mapPred,
    mapXfer = mapXfer,
    rmm = rmm,

    # Switch to a new component tab
    update_component = function(tab = c("Map", "Table", "Results", "Download")) {
      tab <- match.arg(tab)
      updateTabsetPanel(session, "main", selected = tab)
    },

    # Disable a specific module so that it will not be selectable in the UI
    disable_module = function(component = COMPONENTS, module) {
      component <- match.arg(component)
      shinyjs::js$disableModule(component = component, module = module)
    },

    # Enable a specific module so that it will be selectable in the UI
    enable_module = function(component = COMPONENTS, module) {
      component <- match.arg(component)
      shinyjs::js$enableModule(component = component, module = module)
    }
  )

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

  observe({
    spp_size <- as.numeric(utils::object.size(reactiveValuesToList(spp)))
    shinyjs::toggle("save_warning", condition = (spp_size >= SAVE_SESSION_SIZE_MB_WARNING * MB))
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
      shinyalert::shinyalert("Invalid Wallace session file", type = "error")
      return()
    }

    state <- readRDS(file)

    if (!is.list(state) || is.null(state$main) || is.null(state$main$version)) {
      shinyalert::shinyalert("Invalid Wallace session file", type = "error")
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
