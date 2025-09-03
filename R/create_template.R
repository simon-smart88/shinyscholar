#' @title tidy_purl
#' @description Knits and purls an Rmd file into a format which can be written
#' to an R file.
#' @param params vector. Containing file object linking to file to be knitted
#' and a list containing any objects to be knitted into the file.
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @keywords internal

tidy_purl <- function(params){
  rmd <- do.call(knitr::knit_expand, params)
  temp <- tempfile()
  writeLines(rmd, glue::glue("{temp}.Rmd"))
  knitr::purl(glue::glue("{temp}.Rmd"), glue::glue("{temp}.R"), quiet = TRUE)
  lines <- readLines(glue::glue("{temp}.R"))
  lines <- lines[!grepl("^## ----*", lines)]
  return(lines)
}

#' @title Create a skeleton application containing empty modules
#' @description Creates a skeleton app containing empty modules with options
#' controlling objects in `common` and whether to include a map, code and tables
#' @param path character. Path to where the app should be created
#' @param name character. Name of the app which will be used as the package name.
#' Must be only characters and numbers and not start with a number.
#' @param common_objects character vector. Names of objects which will be shared
#' between modules. The objects meta, logger and state are included by default
#' and if include_map is TRUE, the object poly is included to store polygons
#' drawn on the map.
#' @param modules dataframe. Containing one row for each module in the order
#' to be included and with the following column names:
#' \itemize{
#'  \item `component` character. Single word descriptor for the component used to name files
#'  \item `long_component` character. Full component name displayed to the user, formatted appropriately
#'  \item `module` character. Single word descriptor for the module used to name files
#'  \item `long_module` character. Full module name displayed to the user, formatted appropriately
#'  \item `map` logical. Whether or not the module interacts with the map
#'  \item `result` logical. Whether or not the module produces results
#'  \item `rmd` logical. Whether or not the module is included in the markdown
#'  \item `save` logical. Whether or not the input values of the module should be saved
#'  \item `download` logical. Whether or not the module should include a downloadHandler
#'  \item `async` logical. Whether or not the module will run asynchronously
#' }
#' @param author character. Name of the author(s)
#' @param include_map logical. Whether to include a leaflet map. Default `TRUE`
#' @param include_table logical. Whether to include a table tab. Default `TRUE`
#' @param include_code logical. Whether to include a tab for viewing module
#' code. Default `TRUE`
#' @param install logical. Whether to install the package. Default `FALSE`
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default `NULL`
#' @returns No return value, called for side effects
#'
#' @examples
#' td <- tempfile()
#' dir.create(td, recursive = TRUE)
#'
#' modules <- data.frame(
#' "component" = c("data", "data", "plot", "plot"),
#' "long_component" = c("Load data", "Load data", "Plot data", "Plot data"),
#' "module" = c("user", "database", "histogram", "scatter"),
#' "long_module" = c("Upload your own data", "Query a database to obtain data",
#' "Plot the data as a histogram", "Plot the data as a scatterplot"),
#' "map" = c(TRUE, TRUE, FALSE, FALSE),
#' "result" = c(FALSE, FALSE, TRUE, TRUE),
#' "rmd" = c(TRUE, TRUE, TRUE, TRUE),
#' "save" = c(TRUE, TRUE, TRUE, TRUE),
#' "download" = c(FALSE, FALSE, TRUE, TRUE),
#' "async" = c(TRUE, FALSE, FALSE, FALSE))
#'
#' common_objects = c("raster", "histogram", "scatter")
#'
#' create_template(path = td, name = "demo",
#' common_objects = common_objects, modules = modules,
#' author = "Simon E. H. Smart", include_map = TRUE, include_table = TRUE,
#' include_code = TRUE, install = FALSE)
#'
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export

create_template <- function(path, name, common_objects, modules, author,
                            include_map = TRUE, include_table = TRUE,
                            include_code = TRUE, install = FALSE, logger = NULL){

  # Check inputs ====

  if (!is.character(path)){
    logger |> writeLog(type = "error", "path must be a character string")
    return()
  }

  if (!dir.exists(path)){
    logger |> writeLog(type = "error", "The specified path does not exist")
    return()
  }

  if (!is.character(name)){
    logger |> writeLog(type = "error", "name must be a character string")
    return()
  }

  if (grepl("^[A-Za-z0-9]+$", name, perl = TRUE) == FALSE){
    logger |> writeLog(type = "error", "Package names can only contain letters and numbers")
    return()
  }

  if (grepl("^[0-9]+$", substr(name, 1, 1), perl = TRUE) == TRUE){
    logger |> writeLog(type = "error", "Package names cannot start with numbers")
    return()
  }

  online <- curl::has_internet()

  if (online) {
    if (name %in% tools::CRAN_package_db()[, c("Package")]) {
      logger |> writeLog(type = "error", "A package on CRAN already uses that name")
      return()
    }
  } else {
    logger |> writeLog(type = "warning", "You are not online so your package name could
                        not be checked against existing CRAN packages")
  }

  if (dir.exists(file.path(path, name))){
    logger |> writeLog(type = "error", "The specified app directory already exists")
    return()
  }

  if (!is.vector(common_objects) || !is.character(common_objects)){
    logger |> writeLog(type = "error", "common_objects must be a vector of character strings")
    return()
  }

  if (any(common_objects %in% c("meta", "logger", "state", "poly", "tasks"))){
    conflicts <- common_objects[common_objects %in% c("meta", "logger", "state", "poly", "tasks", "reset")]
    conflicts <- paste(conflicts, collapse = ",")
    logger |> writeLog(type = "error", glue::glue("common_objects contains {conflicts} which are included
                                        in common by default. Please choose a different name."))
    return()
  }

  if (!is.data.frame(modules)){
    logger |> writeLog(type = "error", "modules must be a dataframe")
    return()
  }

  module_columns <- c("component", "long_component", "module", "long_module", "map", "result", "rmd", "save", "download", "async")

  if (!all(module_columns %in% colnames(modules))){
    missing_column <- module_columns[!(module_columns %in% colnames(modules))]
    missing_column <- paste(missing_column, collapse = ",")
    if (missing_column == "async"){
      logger |> writeLog(type = "warning", glue::glue("As of v0.2.0 the modules dataframe should also contain an async column"))
      modules <- cbind(modules, data.frame("async" = rep(FALSE, nrow(modules))))
    } else {
      logger |> writeLog(type = "error", glue::glue("The modules dataframe must contain the column(s): {missing_column}"))
      return()
    }
  }

  if (!all(colnames(modules) %in% module_columns)){
    invalid_column <- colnames(modules)[!colnames(modules) %in% module_columns]
    invalid_column <- paste(invalid_column, collapse = ",")
    logger |> writeLog(type = "error", glue::glue("The modules dataframe contains {invalid_column} which is/are not valid column names"))
    return()
  }

  if (any(modules$map) == TRUE && include_map == FALSE){
    logger |> writeLog(type = "info", "Your modules use a map but you had not included it so changing include_map to TRUE")
    include_map <- TRUE
  }

  if (any(modules$map) == FALSE && include_map == TRUE){
    logger |> writeLog(type = "error", "You have included a map but none of your modules use it")
    return()
  }

  if (any(modules$result) == FALSE){
    logger |> writeLog(type = "error", "At least one module must return results")
    return()
  }

  if (any(modules$async)){
    async = TRUE
  } else {
    async = FALSE
  }

  if (!is.character(author)){
    logger |> writeLog(type = "error", "author must be a character string")
    return()
  }

  if (!is.logical(c(include_map, include_table, include_code, install))){
    logger |> writeLog(type = "error", "include_map, include_table,
                        include_code & install must be TRUE or FALSE")
    return()
  }

  # Create directories ====
  # root folder
  dir.create(file.path(path, name))

  # update path to be the root and create folders
  path <- file.path(path, name)
  dir.create(file.path(path, "R"))
  dir.create(file.path(path, "inst", "shiny", "modules"), recursive = TRUE)
  dir.create(file.path(path, "inst", "shiny", "Rmd"))
  dir.create(file.path(path, "inst", "shiny", "www"))
  dir.create(file.path(path, "tests", "testthat"), recursive = TRUE)

  # package DESCRIPTION ====
  description_template <- system.file("app_skeleton", "DESCRIPTION", package = "shinyscholar")
  description_lines <- readLines(description_template)
  description_lines[1] <- glue::glue("Package: {name}")

  if (async){
    import_line <- grep("*Imports*", description_lines)
    description_lines <- append(description_lines, "    mirai,", import_line + 6)
  }

  if (include_map){
    shiny_line <- grep("*shiny (>= 1.8.1)*", description_lines)
    description_lines <- append(description_lines, "    leaflet (>= 2.0.2),", shiny_line - 1)
  }

  if (include_code){
    shinyalert_line <- grep("*shinyalert*", description_lines)
    description_lines <- append(description_lines, "    shinyAce,", shinyalert_line - 1)
  }

  writeLines(description_lines, file.path(path, "DESCRIPTION"))

  # Package info ====

  package_params <- c(
    file = system.file("app_skeleton", "package.Rmd", package = "shinyscholar"),
    list(name = name)
  )

  package_lines <- tidy_purl(package_params)

  if (!include_map){
    package_lines <- gsub("leaflet ", "", package_lines)
  }

  writeLines(package_lines, file.path(path, "R", paste0(name,"-package.R")))

  # Create common list ====
  # add always present objects to common
  common_objects_internal <- c(common_objects, c("meta", "logger", "state"))
  if (include_map){
    common_objects_internal <- c(common_objects_internal, c("poly"))
  }

  if (async){
    common_objects_internal <- c(common_objects_internal, c("tasks"))
  }

  # convert common_objects to list string
  common_objects_list <- paste0("list(", paste(sapply(common_objects_internal, function(a) paste0(a, " = NULL")), collapse = ",\n "))

  # make tasks a list
  if (async){
    common_objects_list <- gsub("tasks = NULL", "tasks = list()", common_objects_list)
  }

  # create reset function
  objects_to_reset <- common_objects_internal[!common_objects_internal %in% c("logger", "tasks")]
  reset_object <- paste(sapply(objects_to_reset, function(a) paste0("self$", a, " <- NULL")), collapse = "\n ")
  common_objects_list <- paste0(common_objects_list, ",\n reset = function(){\n", reset_object, "\n invisible(self)})")

  common_params <- c(
    file = system.file("app_skeleton", "common.Rmd", package = "shinyscholar"),
    list(common_objects = common_objects_list)
    )

  common_lines <- tidy_purl(common_params)
  writeLines(common_lines, file.path(path, "inst", "shiny", "common.R"))

  # Subset components ====
  components <- modules[!duplicated(modules$component),]

  # Create Server ====

  server_params <- c(
    file = system.file("app_skeleton", "server.Rmd", package = "shinyscholar"),
    list(app_library = name,
         include_map = include_map,
         include_table = include_table,
         include_code = include_code,
         async = async
         )
  )
  server_lines <- tidy_purl(server_params)

  writeLines(server_lines, file.path(path, "inst", "shiny", "server.R"))

  # Create UI ====

  ui_params <- c(
    file = system.file("app_skeleton", "ui.Rmd", package = "shinyscholar"),
    list(app_library = name,
         include_map = include_map,
         include_table = include_table,
         include_code = include_code,
         async = async
    )
  )

  ui_lines <- tidy_purl(ui_params)

  component_tab_target <- grep("*value = \"intro\"*", ui_lines)
  for (i in 1:nrow(components)){
    ui_lines <- append(ui_lines, glue::glue('    nav_panel("{components$long_component[i]}", value = "{components$component[i]}"),'), component_tab_target)
    # increment target as order matters in UI
    component_tab_target <- component_tab_target + 1
  }

  component_interface_target <- grep("*Rmd/text_intro_tab.Rmd*", ui_lines) + 1
  for (i in 1:nrow(components)){
    comp_ui <- glue::glue('          insert_modules_ui("{components$component[i]}", "{components$long_component[i]}"),')
    ui_lines <- append(ui_lines, comp_ui, component_interface_target)
    component_interface_target <- component_interface_target + 1
  }
  writeLines(ui_lines, file.path(path, "inst", "shiny", "ui.R"))

  # Create global ====

  full_component_list <- c(components$component, "rep")
  names(full_component_list) <- c(components$long_component, "Reproduce")

  global_params <- c(
    file = system.file("app_skeleton", "global.Rmd", package = "shinyscholar"),
    list(app_library = name,
         component_list = printVecAsis(full_component_list),
         include_map = include_map,
         async = async
    )
  )

  global_lines <- tidy_purl(global_params)

  global_yaml_target <- grep("*base_module_configs <-*", global_lines)
  for (m in nrow(modules):1){
    global_lines <- append(global_lines, glue::glue('  "modules/{modules$component[m]}_{modules$module[m]}.yml",'), global_yaml_target)
  }

  global_lines <- gsub("*and map code *", "", global_lines)

  writeLines(global_lines, file.path(path, "inst", "shiny", "global.R"))

  # Core modules ====

  core_params <- c(
    file = NULL,
    list(app_library = name,
         include_map = include_map,
         include_table = include_table,
         include_code = include_code,
         first_component = components$component[1],
         first_module = glue::glue("{modules$component[1]}_{modules$module[1]}")
    )
  )

  core_modules <- c("intro", "save", "load")
  if (include_map) core_modules <- c(core_modules, "mapping")
  if (include_code) core_modules <- c(core_modules, "code")

  for (c in core_modules){
    core_params$file <- system.file("app_skeleton", paste0(c, ".Rmd"), package = "shinyscholar")
    core_lines <- tidy_purl(core_params)

    if ((c == "load") && !include_map){
      core_lines <- gsub("modules, map, COMPONENT_MODULES", "modules, COMPONENT_MODULES", core_lines)
      core_lines <- gsub("restore map and results for used modules", "restore results for used modules", core_lines)
      map_fx_line <- grep("*map_fx <- COMPONENT_MODULES*", core_lines)
      core_lines <- core_lines[-c(map_fx_line:(map_fx_line + 3))]
    }

    writeLines(core_lines, file.path(path, "inst", "shiny", "modules", paste0("core_",c,".R")))
  }

  # Create modules ====

  for (m in 1:nrow(modules)){
    module_name <- glue::glue("{modules$component[m]}_{modules$module[m]}")

    # create files for each module
    shinyscholar::create_module(id = module_name,
                        dir = path,
                        map = modules$map[m],
                        result = modules$result[m],
                        rmd = modules$rmd[m],
                        save = modules$save[m],
                        download = modules$download[m],
                        async = modules$async[m],
                        init = TRUE)

    # add map parameter if any module is async, but the individual module is not
    if (include_map && async && (!modules$async[m])){
      module_file <- file.path(path, "inst", "shiny", "modules", paste0(module_name, ".R"))
      module_lines <- readLines(module_file)
      module_lines <- gsub("id, common, parent_session", "id, common, parent_session, map", module_lines)
      writeLines(module_lines, module_file)
    }

    # edit yaml configs
    yml_lines <- rep(NA,5)

    # capitalise module name for UI
    short_mod <- modules$module[m]
    substr(short_mod, 1, 1) <- toupper(substr(short_mod, 1, 1))

    yml_lines[1] <- glue::glue('component: "{modules$component[m]}"')
    yml_lines[2] <- glue::glue('short_name: "{short_mod}"')
    yml_lines[3] <- glue::glue('long_name: "{modules$long_module[m]}"')
    yml_lines[4] <- glue::glue('authors: "{author}"')
    yml_lines[5] <- "package: []"

    writeLines(yml_lines,  file.path(path, "inst", "shiny", "modules", paste0(module_name, ".yml")))
  }

  # copy reproduce modules
  rep_files <- list.files(system.file("shiny", "modules", package = "shinyscholar"),
                          pattern = "rep_", full.names = TRUE)
  lapply(rep_files, file.copy, file.path(path, "inst", "shiny", "modules"))

  # remove map from function calls if not async
  if (!async || !include_map){
   for (rep_mod in c("markdown", "refPackages", "renv")){
     rep_path <- file.path(path, "inst", "shiny", "modules", paste0("rep_", rep_mod ,".R"))
     rep_lines <- readLines(rep_path)
     rep_lines <- gsub("id, common, parent_session, map", "id, common, parent_session", rep_lines)
     writeLines(rep_lines, rep_path)
   }
  }

  # fix rep_renv
  renv_path <- file.path(path, "inst", "shiny", "modules", "rep_renv.R")
  renv_lines <- readLines(renv_path)
  renv_lines <- gsub("shinyscholar", name, renv_lines)
  writeLines(renv_lines, renv_path)

  # Rmds ====
  # copy existing rmds
  rmd_files <- list.files(system.file("shiny", "Rmd", package = "shinyscholar"),
                          pattern = ".Rmd", full.names = TRUE)

  # exclude guidance for existing components and intro tab
  rmd_files <- rmd_files[!grepl("gtext_plot|gtext_select|text_intro_tab", rmd_files)]
  lapply(rmd_files, file.copy, file.path(path, "inst", "shiny", "Rmd"))

  # fix library calls in intro
  rmd_intro_lines <- readLines(file.path(path, "inst", "shiny", "Rmd", "userReport_intro.Rmd"))
  terra_line <- grep("*library\\(terra)*", rmd_intro_lines)
  rmd_intro_lines <- rmd_intro_lines[-terra_line]

  rmd_intro_lines <- gsub("shinyscholar", name, rmd_intro_lines)
  rmd_intro_lines <- gsub("v\\d+\\.\\d+\\.\\d+", "v0.0.1", rmd_intro_lines)

  if (!include_map){
    leaflet_line <- grep("*library\\(leaflet)*", rmd_intro_lines)
    rmd_intro_lines <- rmd_intro_lines[-leaflet_line]
  }
  writeLines(rmd_intro_lines, file.path(path, "inst", "shiny", "Rmd", "userReport_intro.Rmd"))

  # Intro tab====
  number_word <- c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten")
  if (nrow(components) <= 10){
    n_components <- number_word[nrow(components)]
  } else {
    n_components <- nrow(components)
  }

  intro_lines <- readLines(system.file("app_skeleton", "text_intro_tab.Rmd", package = "shinyscholar"))
  intro_lines[8] <- glue::glue("*{name}* (v0.0.1) includes {n_components} components, or steps of a possible workflow. Each component includes one or more modules, which are possible analyses for that step.")

  for (c in 1:nrow(components)){
    intro_lines <- append(intro_lines, glue::glue("**{c}.** *{components$long_component[c]}*"))
    component_modules <- modules[modules$long_component == components$long_component[c],]
    for (m in component_modules$long_module){
      intro_lines <- append(intro_lines, glue::glue("- {m}"))
    }
    intro_lines <- append(intro_lines,"")
  }
  intro_lines <- append(intro_lines, glue::glue("**{c+1}.** *Reproduce*"))
  intro_lines <- append(intro_lines, "- Download session code")
  intro_lines <- append(intro_lines, "- Download dependencies")
  intro_lines <- append(intro_lines, "- Download package references")
  writeLines(intro_lines, file.path(path, "inst", "shiny", "Rmd", "text_intro_tab.Rmd"))

  # guidance rmds for components ====
  guidance_template <- system.file("app_skeleton", "gtext.Rmd", package = "shinyscholar")
  for (c in 1:nrow(components)){
  guidance_lines <- readLines(guidance_template)
  guidance_lines[2] <- glue::glue("title: {components$component[c]}")
  guidance_lines[6] <- glue::glue("### **Component: {components$long_component[c]}**")
  writeLines(guidance_lines, file.path(path, "inst", "shiny", "Rmd", paste0("gtext_", components$component[c], ".Rmd")))
  }

  # copy www folder ====
  www_files <- system.file("shiny", "www", package = "shinyscholar")
  file.copy(www_files, file.path(path, "inst", "shiny"), recursive = TRUE)

  # copy helpers ====
  helper_file <- system.file("shiny", "ui_helpers.R", package = "shinyscholar")
  file.copy(helper_file, file.path(path, "inst", "shiny"))

  helper_function_params <- c(
    file = system.file("app_skeleton", "helper_functions.Rmd", package = "shinyscholar"),
    list(include_code = include_code,
         include_map = include_map,
         async = async)
  )
  helper_function_lines <- tidy_purl(helper_function_params)
  writeLines(helper_function_lines, file.path(path, "R", "helper_functions.R"))

  # Create run_app ====
  run_app_params <- c(
    file = system.file("app_skeleton", "run_app.Rmd", package = "shinyscholar"),
    list(app_library = name
    )
  )

  run_app_lines <- tidy_purl(run_app_params)
  writeLines(run_app_lines, file.path(path, "R", paste0("run_", name, ".R")))

  # Create testthat file
  testthat_params <- c(
    file = system.file("app_skeleton", "testthat.Rmd", package = "shinyscholar"),
    list(app_library = name
    )
  )

  testthat_lines <- tidy_purl(testthat_params)
  writeLines(testthat_lines, file.path(path, "tests", "testthat.R"))

  # Install package ====
  if (install){
  devtools::document(path)
  devtools::install(path, force = TRUE)
  }

  invisible()
}


