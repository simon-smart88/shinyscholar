#' @title tidy_purl
#' @description Opens a file, removes any lines starting with "## ----" and
#' returns the other lines
#' @param params vector. Containing file object linking to file to be knitted
#' and a list containing any objects to be knitted into the file.
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @keywords internal
#' @export

tidy_purl <- function(params){
  rmd <- do.call(knitr::knit_expand, params)
  temp <- tempfile()
  writeLines(rmd, glue::glue("{temp}.Rmd"))
  knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{temp}.R"))
  lines <- readLines(glue::glue("{temp}.R"))
  lines <- lines[!grepl("^## ----*", lines)]
  return(lines)
}

#' @title create_template
#' @description This function creates a skeleton app containing empty modules
#' @param path character. The path to where the app should be created
#' @param name character. The name of the app which will be used as the package name
#' @param include_map logical. Whether to include a leaflet map
#' @param include_table logical. Whether to include a table tab
#' @param include_code logical. Whether to include a tab for viewing module code
#' @param common_objects character vector. Names of objects which will be shared
#' between modules. The objects meta, logger and state are included by default
#' and if include_map is TRUE, the object poly is included to store polygons
#' drawn on the map.
#' @param modules A dataframe containing long and short names of components (tabs) and modules
#' in the order to be included and whether they should include mapping, save,
#' markdown and result functionality. The component and module columns are used to generate file
#' names for the modules. The long_component and long_module columns are used to generate UI and
#' so should be formatted appropriately.
#' @param author character. The name of the author(s)
#' @param install logical. Whether to install the package
#'
#' @examples
#' \dontrun{
#' modules <- data.frame(
#' "component" = c("data", "data", "plot", "plot"),
#' "long_component" = c("Load data", "Load data", "Plot data", "Plot data"),
#' "module" = c("user", "database", "histogram", "scatter"),
#' "long_module" = c("Upload your own data", "Query a database to obtain data",
#' "Plot the data as a histogram", "Plot the data as a scatterplot"),
#' "map" = c(TRUE, TRUE, FALSE, FALSE),
#' "result" = c(FALSE, FALSE, TRUE, TRUE),
#' "rmd" = c(TRUE, TRUE, TRUE, TRUE),
#' "save" = c(TRUE, TRUE, TRUE, TRUE))
#' common_objects = c("raster", "histogram", "scatter")
#'
#' create_template(path = "~/Documents", name = "demo",
#' include_map = TRUE, include_table = TRUE, include_code = TRUE,
#' common_objects = common_objects, modules = modules,
#' author = "Simon E. H. Smart",
#' install = TRUE)
#' }
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

create_template <- function(path, name, include_map, include_table, include_code, common_objects, modules, author, install){

# Check inputs ====
if (any(modules$map) == TRUE & include_map == FALSE){
  message("Your modules use a map but you had not included it so changing include_map to TRUE")
  include_map <- TRUE
}

if (any(modules$map) == FALSE & include_map == TRUE){
  stop("You have included a map but none of your modules use it")
}

if (any(common_objects %in% c("meta", "logger", "state", "poly"))){
  conflicts <- common_objects[common_objects %in% c("meta", "logger", "state", "poly")]
  conflicts <- paste(conflicts, collapse=',')

  stop(glue::glue("common_objects contains {conflicts} which are included
        in common by default. Please choose a different name."))
}

# Create directories ====
#root folder
if (dir.exists(file.path(path, name))){
  stop("The specified app directory already exists")
} else {
  dir.create(file.path(path, name))
}

#update path to be the root and create folders
path <- glue::glue("{path}/{name}")
dir.create(file.path(path, "R"))
dir.create(file.path(path, "inst/shiny/modules"), recursive = TRUE)
dir.create(file.path(path, "inst/shiny/Rmd"))
dir.create(file.path(path, "inst/shiny/www"))

# Create common list ====
#add always present objects to common
common_objects <- c(common_objects, c("meta", "logger", "state"))
if (include_map == TRUE){
  common_objects <- c(common_objects, c("poly"))
}

#convert common_objects to list string
common_objects <- paste0("list(", paste(sapply(common_objects, function(a) paste0(a, " = NULL")), collapse = ",\n "), ")")

common_params <- c(
  file = system.file("app_skeleton/common.Rmd", package="SMART"),
  list(common_objects = common_objects)
  )

common_lines <- tidy_purl(common_params)

#write final file
writeLines(common_lines, glue::glue("{path}/inst/shiny/common.R"))

# Subset components ====
components <- modules[duplicated(modules$component),]
added_component_list <- components$component

# Create Server ====

server_params <- c(
  file = system.file("app_skeleton/server.Rmd", package="SMART"),
  list(app_library = name,
       include_map = include_map,
       include_table = include_table,
       include_code = include_code,
       added_component_list = printVecAsis(added_component_list)
       )
)
server_lines <- tidy_purl(server_params)

#insert help observers for each module
help_target <- grep("  # Help Module*", server_lines)
for (m in 1:nrow(modules)){
server_lines <- append(server_lines, glue::glue('observeEvent(input${modules$component[m]}_{modules$module[m]}Help, updateTabsetPanel(session, "main", "Module Guidance"))'), help_target)
}

#create plot observers
results <- modules[modules$result == TRUE,]
for (r in 1:nrow(results)){
observer_target <- grep("*switch to the results tab*", server_lines)
server_lines <- append(server_lines, glue::glue('observeEvent(gargoyle::watch("{results$component[r]}_{results$module[r]}"), updateTabsetPanel(session, "main", selected = "Results"), ignoreInit = TRUE)'), observer_target)
}

#write final file
writeLines(server_lines, glue::glue("{path}/inst/shiny/server.R"))

# Create UI ====

ui_params <- c(
  file = system.file("app_skeleton/ui.Rmd", package="SMART"),
  list(app_library = name,
       include_map = include_map,
       include_table = include_table,
       include_code = include_code
  )
)

ui_lines <- tidy_purl(ui_params)

component_tab_target <- grep("*value = 'intro'*", ui_lines)
for (i in 1:nrow(components)){
  ui_lines <- append(ui_lines, glue::glue('tabPanel("{components$long_component[i]}", value = "{components$component[i]}"),'), component_tab_target)
  #increment target as order matters in UI
  component_tab_target <- component_tab_target + 1
}

component_interface_target <- grep("*Rmd/text_intro_tab.Rmd*", ui_lines) + 1
for (i in 1:nrow(components)){
  ui_lines <- append(ui_lines, c(glue::glue('          # {toupper(components$long_component[i])} ####'),
                                               '           conditionalPanel(',
                                    glue::glue('          "input.tabs == \'{components$component[i]}\'",'),
                                    glue::glue('          div("Component: {components$long_component[i]}", class = "componentName"),'),
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

full_component_list <- c(components$component, "rep")

global_params <- c(
  file = system.file("app_skeleton/global.Rmd", package="SMART"),
  list(app_library = name,
       component_list = printVecAsis(full_component_list)
  )
)

global_lines <- tidy_purl(global_params)

global_yaml_target <- grep("*base_module_configs <-*", global_lines)
for (m in 1:nrow(modules)){
  global_lines <- append(global_lines, glue::glue('"modules/{modules$component[m]}_{modules$module[m]}.yml",'), global_yaml_target)
}

writeLines(global_lines, glue::glue("{path}/inst/shiny/global.R"))

# Create modules ====

for (m in 1:nrow(modules)){
  module_name <- glue::glue("{modules$component[m]}_{modules$module[m]}")

  #create files for each module
  SMART::create_module(id = module_name,
                      dir = glue::glue("{path}/inst/shiny/modules"),
                      map = modules$map[m],
                      result = modules$result[m],
                      rmd = modules$rmd[m],
                      save = modules$save[m],
                      init = TRUE)

  #create function for each module
  writeLines(glue::glue("{module_name} <- function(){}"),  glue::glue("{path}/R/{module_name}.R"))

  #edit yaml configs
  yml_lines <- rep(NA,5)

  #Capitalise module name for UI
  short_mod <- modules$module[m]
  substr(short_mod, 1, 1) <- toupper(substr(short_mod, 1, 1))

  yml_lines[1] <- glue::glue('component: "{modules$component[m]}"')
  yml_lines[2] <- glue::glue('short_name: "{short_mod}"')
  yml_lines[3] <- glue::glue('long_name: "{modules$long_module[m]}"')
  yml_lines[4] <- glue::glue('authors: "{author}"')
  yml_lines[5] <- "package: []"

  writeLines(yml_lines,  glue::glue("{path}/inst/shiny/modules/{module_name}.yml"))

}

#copy reproduce modules
rep_files <- list.files(system.file("shiny/modules", package = "SMART"),
                        pattern = "rep_", full.names = TRUE)
lapply(rep_files,file.copy,glue::glue("{path}/inst/shiny/modules/"))

#copy intro rmds
rmd_files <- list.files(system.file("shiny/Rmd", package = "SMART"),
                        pattern = ".Rmd", full.names = TRUE)
#exclude guidance for existing components
rmd_files <- rmd_files[!grepl("gtext_plot|gtext_select", rmd_files)]
lapply(rmd_files,file.copy,glue::glue("{path}/inst/shiny/Rmd/"))

#create guidance rmds for components
guidance_template <- system.file("app_skeleton/gtext.Rmd", package = "SMART")
for (c in 1:nrow(components)){
guidance_lines <- readLines(guidance_template)
guidance_lines[2] <- glue::glue("title: {components$component[c]}")
guidance_lines[6] <- glue::glue("### **Component: {components$long_component[c]}**")
writeLines(guidance_lines, glue::glue("{path}/inst/shiny/Rmd/gtext_{components$component[c]}.Rmd"))
}

#copy www folder
www_files <- system.file("shiny/www", package = "SMART")
file.copy(www_files, glue::glue("{path}/inst/shiny/"), recursive = TRUE)

#copy helpers
helper_file <- system.file("shiny/helpers.R", package = "SMART")
file.copy(helper_file, glue::glue("{path}/inst/shiny/"), recursive = TRUE)

#create package description
description_template <- system.file("app_skeleton/DESCRIPTION", package = "SMART")
description_lines <- readLines(description_template)
description_lines[1] <- glue::glue("Package: {name}")
writeLines(description_lines, glue::glue("{path}/DESCRIPTION"))

# Create run_module ====

run_mod_params <- c(
  file = system.file("app_skeleton/run_module.Rmd", package="SMART"),
  list(include_map = include_map,
       app_library = name
       )
)

run_mod_lines <- tidy_purl(run_mod_params)

#write final file
writeLines(run_mod_lines, glue::glue("{path}/R/run_module.R"))

# Create run_app ====

run_app_params <- c(
  file = system.file("app_skeleton/run_app.Rmd", package="SMART"),
  list(app_library = name
  )
)

run_app_lines <- tidy_purl(run_app_params)

#write final file
writeLines(run_app_lines, glue::glue("{path}/R/run_{name}.R"))

# Install package ====
if (install){
devtools::install_local(path = path, force = TRUE)
}

}


