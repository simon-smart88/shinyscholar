#' @title Create a skeleton app
#' @description This function creates a skeleton app containing empty modules
#' @param path The path to where the app should be created
#' @param name The name of the app which will be used as the package name
#' @param include_map Whether to include a leaflet map
#' @param include_table Whether to include a table tab
#' @param include_code Whether to include a tab for viewing module code
#' @param common_objects A list of the objects which will be shared between modules
#' @param modules A data frame containing names of components, modules and whether
#' they should include mapping, save, markdown and result functionality.
#'
#' @examples
#' if(interactive()) {
#' test_module("select_query")
#' }
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

init <- function(path,name,include_map,include_table,include_code,common_objects,modules){

#add always present objects to common
common_objects <- append(common_objects, list(meta = NULL, logger = NULL, state = NULL))
if (include_map == TRUE){
  common_objects <- append(common_objects, list(poly = NULL))
}

help_component_list <- unique(modules$component)

server_params <- c(
  file = system.file('app_skeleton/server.Rmd', package="SMART"),
  list(path = path,
       name = name,
       include_map = include_map,
       include_table = include_table,
       include_code = include_code,
       common_objects = common_objects,
       modules = modules,
       help_component_list = help_component_list
       )
)
server_rmd <- do.call(knitr::knit_expand, server_params)
temp <- tempfile()
writeLines(module_rmd, glue::glue("{temp}.Rmd"))

knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{path}/server.R"))

server_lines <- readLines(glue::glue("{path}/server.R"))
server_lines <- server_lines[!grepl('^## --------*', server_lines)]

help_target <- grep("test2 <- 'hello2'*", rl)

for (m in modules$module){
server_lines <- append(server_lines, list(glue::glue('observeEvent(input${m}Help, updateTabsetPanel(session, "main", "Module Guidance"))'), help_target))
}

writeLines(server_lines, glue::glue("{path}/server.R"))

}
