template_create_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    textInput(ns("name"), "Name"),
    textInput(ns("comps"), "Components"),
    textInput(ns("long_comps"), "Long components"),
    uiOutput(ns("mods")),
    shinyWidgets::materialSwitch(ns("include_map"), "Include map tab?", TRUE, status = "success"),
    shinyWidgets::materialSwitch(ns("include_table"), "Include table tab?", TRUE, status = "success"),
    shinyWidgets::materialSwitch(ns("include_code"), "Include code tab?", TRUE, status = "success"),
    uiOutput(ns("module_options")),
    textInput(ns("common"), "Common objects"),
    textInput(ns("author"), "Author"),
    uiOutput(ns("download"))
  )
}

template_create_module_server <- function(id, common, parent_session) {
  moduleServer(id, function(input, output, session) {

    output$mods <- renderUI({
      req(input$comps)
      components <- strsplit(input$comps,",")[[1]]
      lapply(1:length(components), function(c) {
        tagList(
          textInput(session$ns(paste0("mod",c)), glue::glue("Modules in {components[c]} component:")),
          textInput(session$ns(paste0("long_mod",c)), glue::glue("Long modules names for {components[c]} component:"))
        )
      })
    })

    #Render download button after checking inputs
    output$download <- renderUI({
      req(input$name)
      req(input$comps)
      req(input$long_comps)
      req(input$common)
      req(input$author)
      validate(need(length(split_and_clean(input$comps)) == length(split_and_clean(input$long_comps)),
                    "Components and Long components must have the same number of entries"))
      components <- split_and_clean(input$comps)
      for (c in 1:length(components)){
      validate(need(length(split_and_clean(input[[paste0("mod",c)]])) == length(split_and_clean(input[[paste0("long_mod",c)]])),
                    glue::glue("Modules and Long modules for component {components[c]} are different lengths")))
      }
      downloadButton(session$ns("dl"), "Download!")
    })

    #split strings into vectors and remove whitespace
    split_and_clean <- function(input){
      vect <- strsplit(as.character(input), ",")[[1]]
      vect <- trimws(vect, which = "both")
      return(vect)
    }

    modules <- reactive({
      req(input$name)
      req(input$comps)
      req(input$long_comps)
      components <- split_and_clean(input$comps)
      long_components <- split_and_clean(input$long_comps)

      df_comps <- NULL
      df_long_comps <- NULL
      df_mods <- NULL
      df_long_mods <- NULL
      for (c in 1:length(components)){
        mods_in_comp <- split_and_clean(input[[paste0("mod",c)]])
        long_mods_in_comp <- split_and_clean(input[[paste0("long_mod",c)]])

        comps_rep <- rep(components[c], length(mods_in_comp))
        long_comps_rep <- rep(long_components[c], length(mods_in_comp))
        df_comps <- append(df_comps, comps_rep)
        df_long_comps <- append(df_long_comps, long_comps_rep)
        df_mods <- append(df_mods, mods_in_comp)
        df_long_mods <- append(df_long_mods, long_mods_in_comp)
      }
      df <- data.frame("component" = df_comps,
                       "long_component" = df_long_comps,
                       "module" = df_mods,
                       "long_module" = df_long_mods
      )
      df
    })

    module_list <- reactive(paste(modules()$component, modules()$module, sep= '_'))

    output$module_options <- renderUI({

      if (input$include_map){
        choices <- c("Map", "Results", "Rmd", "Save")
      } else {
        choices <- c("Results", "Rmd", "Save")
      }

      lapply(module_list(), function(id){shinyWidgets::checkboxGroupButtons(
        session$ns(id), label = glue::glue("Options for {id}"),
        choices = choices, selected = choices,
        checkIcon = list(yes = icon("check"), no = icon("xmark")), size = 'xs')})
    })

      module_options <- reactive({
        df <- t(as.data.frame(lapply(module_list(), function(x){
          c("Map", "Results", "Rmd", "Save") %in% input[[x]]})))
        colnames(df) <- c("map", "results", "rmd", "save")
        df
      })

    output$dl <- downloadHandler(
      filename = function() {
        paste0(input$name, ".zip")
      },
      content = function(file) {

        common_objects = split_and_clean(input$common)

        tmpdir <- tempdir()

        module_df <- cbind(modules(), module_options())
        browser()
        create_template(path = tmpdir,
                        name = input$name,
                        include_map = input$include_map,
                        include_table = input$include_map,
                        include_code = input$include_map,
                        modules = module_df,
                        common_objects = common_objects,
                        author = input$author,
                        install = FALSE)

        owd <- setwd(file.path(tmpdir, input$name))
        on.exit(setwd(owd))

        files <- list.files(".", recursive = TRUE)

        zip::zipr(zipfile = file,
                  files = files,
                  mode = "mirror",
                  include_directories = TRUE)
      })


})
}


