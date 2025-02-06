core_save_module_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    br(),
    h5(em("Note: To save your session code or metadata, use the Reproduce component")),
    wellPanel(
      h4(strong("Save Session")),
      p(paste0("By saving your session into an RDS file, you can resume ",
               "working on it at a later time or you can share the file",
               " with a collaborator.")),
      shinyjs::hidden(p(
        id = "save_warning",
        icon("triangle-exclamation"),
        paste0("The current session data is large, which means the ",
               "downloaded file may be large and the download might",
               " take a long time.")
      )),
      downloadButton(ns("save_session"), "Save Session"),
      br()
  )
  )
}

core_save_module_server <- function(id, common, modules, COMPONENTS, main_input) {
  moduleServer(id, function(input, output, session) {

    observe({
      common_size <- as.numeric(utils::object.size(common))
      shinyjs::toggle("save_warning", condition = (common_size >= SAVE_SESSION_SIZE_MB_WARNING * MB))
    })

    output$save_session <- downloadHandler(
      filename = function() {
        paste0("shinyscholar-session-", Sys.Date(), ".rds")
      },
      content = function(file) {
        common$state$main <- list(
          selected_module = sapply(COMPONENTS, function(x) main_input[[glue("{x}Sel")]], simplify = FALSE)
        )

        # Store app version and name
        common$state$main$version <- as.character(packageVersion("shinyscholar"))
        common$state$main$app <- "shinyscholar"

        # Ask each module to save whatever data it wants
        for (module_id in names(modules)) {
          common$state[[module_id]] <- modules[[module_id]]$save()
        }

        # wrap and unwrap required due to terra objects being pointers to c++ objects
        if (!is.null(common$raster)){
          common$raster <- terra::wrap(common$raster)
        }

        saveRDS(common, file)

        if (!is.null(common$raster)){
          common$raster <- terra::unwrap(common$raster)
        }
      }
    )
  })
}
