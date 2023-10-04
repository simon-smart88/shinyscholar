#' @title Create a skeleton app
#' @description This function creates a skeleton app containing empty modules
#' @param path The path to where the app should be created
#' @param name The name of the app which will be used as the package name
#' @param include_map Whether to include a leaflet map
#' @param include_table Whether to include a table tab
#' @param include_code Whether to include a tab for viewing module code
#' @param common_objects A list of the objects which will be shared between modules
#' @param modules A dataframe containing long and short names of components (tabs), names of modules
#' in the order to be included and whether they should include mapping, save,
#' markdown and result functionality.
#'
#' @examples
#' modules <- data.frame("module" = c("a","b","c","d"),
#' "component" = c("m","m","n","n"),
#' "long_component" = c("mmmm","mmmm","nnnn","nnnn"),
#' "map" = c(TRUE,TRUE,FALSE,FALSE),
#' "result" = c(TRUE,TRUE,FALSE,FALSE),
#' "rmd" = c(TRUE,TRUE,TRUE,TRUE),
#' "save" = c(TRUE,TRUE,TRUE,TRUE))
#' init("select_query")
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

init <- function(path, name, include_map, include_table, include_code, common_objects, modules){

if (any(modules$map) == TRUE & include_map == FALSE){
  message("Your modules use a map but you had not included it so changing include_map to TRUE")
  include_map <- TRUE
}

if (any(modules$map) == FALSE & include_map == TRUE){
  stop("You have included a map but none of your modules use it")
}

#add always present objects to common
common_objects <- append(common_objects, list(meta = NULL, logger = NULL, state = NULL))
if (include_map == TRUE){
  common_objects <- append(common_objects, list(poly = NULL))
}

components <- modules[duplicated(modules$component),]
help_component_list <- components$component

# Create Server ====

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

# knit to include custom parameters
server_rmd <- do.call(knitr::knit_expand, server_params)
temp <- tempfile()
writeLines(server_rmd, glue::glue("{temp}.Rmd"))

# purl to only include the R code and the relevant sections requested
knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/inst/shiny/server.R"))

#tidy up purl mess
server_lines <- readLines(glue::glue("{path}/inst/shiny/server.R"))
server_lines <- server_lines[!grepl('^## --------*', server_lines)]

#insert help observers for each module
help_target <- grep("  # Help Module*", server_lines)
for (m in modules$module){
server_lines <- append(server_lines, list(glue::glue('observeEvent(input${m}Help, updateTabsetPanel(session, "main", "Module Guidance"))'), help_target))
}

#write final file
writeLines(server_lines, glue::glue("{path}/inst/shiny/server.R"))

# Create UI ====

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

knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/inst/shiny/ui.R"))

ui_lines <- readLines(glue::glue("{path}/inst/shiny/ui.R"))
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
writeLines(ui_lines, glue::glue("{path}/inst/shiny/ui.R"))

# Create global ====

component_list <- c(components$component,'rep')

global_params <- c(
  file = system.file('app_skeleton/global.Rmd', package="SMART"),
  list(app_library = name,
       component_list = printVecAsis(component_list)
  )
)

global_rmd <- do.call(knitr::knit_expand, global_params)
temp <- tempfile()
writeLines(global_rmd, glue::glue("{temp}.Rmd"))

knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/inst/shiny/global.R"))

global_lines <- readLines(glue::glue("{path}/inst/shiny/global.R"))
global_lines <- global_lines[!grepl('^## --------*', global_lines)]

global_yaml_target <- grep("base_module_configs <- c(", global_lines)
for (m in 1:nrow(modules)){
  global_lines <- append(global_lines, list(glue::glue("modules/{modules$component[m]}_{modules$module[m]}.yml,"), global_yaml_target))
}

# Create modules ====

for (m in 1:nrow(modules)){
  module_name <- glue::glue("{modules$component[m]}_{modules$module[m]}")

  #create files for each module
  SMART::create_module(id = module_name,
                      dir = glue::glue("{path}/inst/shiny/modules"),
                      map = modules$map[m],
                      result = modules$result[m],
                      rmd = modules$rmd[m],
                      save = modules$save[m])

  #create function for each module
  writeLines(glue::glue("{module_name} <- function()"),  glue::glue("{path}/R/{module_name}.R"))

  #edit yaml configs
}

#copy rep modules

#copy into rmds

}
