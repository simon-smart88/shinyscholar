#' @title Create a skeleton app
#' @description This function creates a skeleton app containing empty modules
#' @param path The path to where the app should be created
#' @param name The name of the app which will be used as the package name
#' @param include_map Whether to include a leaflet map
#' @param include_table Whether to include a table tab
#' @param include_code Whether to include a tab for viewing module code
#' @param common_objects A list of the objects which will be shared between modules
#' @param modules A dataframe containing names of components, modules and whether
#' they should include mapping, save, markdown and result functionality.
#'
#' @examples
#' init("select_query")
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

init <- function(path,name,include_map,include_table,include_code,common_objects,modules){

#add always present objects to common
common_objects <- append(common_objects, list(meta = NULL, logger = NULL, state = NULL))
if (include_map == TRUE){
  common_objects <- append(common_objects, list(poly = NULL))
}

components <- modules[duplicated(modules$component),]
help_component_list <- components$component

server_params <- c(
  file = system.file('app_skeleton/server.Rmd', package="SMART"),
  list(app_library = name,
       include_map = include_map,
       include_table = include_table,
       include_code = include_code,
       common_objects = common_objects,
       help_component_list = printVecAsis(help_component_list)
       )
)
server_rmd <- do.call(knitr::knit_expand, server_params)
temp <- tempfile()
writeLines(server_rmd, glue::glue("{temp}.Rmd"))

knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/server.R"))

server_lines <- readLines(glue::glue("{path}/server.R"))
server_lines <- server_lines[!grepl('^## --------*', server_lines)]

help_target <- grep("  # Help Module*", server_lines)

for (m in modules$module){
server_lines <- append(server_lines, list(glue::glue('observeEvent(input${m}Help, updateTabsetPanel(session, "main", "Module Guidance"))'), help_target))
}

writeLines(server_lines, glue::glue("{path}/server.R"))

ui_params <- c(
  file = system.file('app_skeleton/ui.Rmd', package="SMART"),
  list(app_library = name,
       include_map = include_map,
       include_table = include_table,
       include_code = include_code
  )
)

ui_rmd <- do.call(knitr::knit_expand, ui_params)
temp <- tempfile()
writeLines(ui_rmd, glue::glue("{temp}.Rmd"))

knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/ui.R"))

ui_lines <- readLines(glue::glue("{path}/ui.R"))
ui_lines <- ui_lines[!grepl('^## --------*', ui_lines)]

component_tab_target <- grep('    tabPanel("Intro", value = "intro"),*', ui_lines)
for (i in 1:nrow(components)){
  ui_lines <- append(ui_lines, list(glue::glue('tabPanel("{components$component_long[i]}", value = "{components$component[i]}"),'), component_tab_target))
  #increment target as order matters in UI
  component_tab_target <- component_tab_target + 1
}

component_interface_target <- grep('            includeMarkdown("Rmd/text_intro_tab.Rmd")*', ui_lines) + 1
for (i in 1:nrow(components)){
  ui_lines <- append(ui_lines, list(glue::glue('          # {to_upper(components$component_long[i])} ####'),
                                               '           conditionalPanel(',
                                    glue::glue('          "input.tabs == \'{components$component[i]}\'"'),
                                    glue::glue('          div("Component: {components$component_long[i]}", class = "componentName"),'),
                                    glue::glue('          help_comp_ui("{components$component[i]}Help"),'),
                                               '          radioButtons(',
                                    glue::glue('          "{components$component[i]}Sel", "Modules Available:",'),
                                    glue::glue('          choices = insert_modules_options("{components$component[i]}"),'),
                                               '          selected = character(0)',
                                               '          ),',
                                               '          tags$hr(),',
                                    glue::glue('          insert_modules_ui("{components$component[i]}")'),
                                               '          ),'),
                                               component_interface_target)
  component_interface_target <- component_interface_target + 13
}
writeLines(ui_lines, glue::glue("{path}/ui.R"))


}
