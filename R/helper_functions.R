####################### #
# MISC #
####################### #
#' @title printVecAsis
#' @description For internal use. Print objects as character string
#' @param x object to print
#' @return A character string to reproduce the object
#' @keywords internal
#' @export
printVecAsis <- function(x) {
  if (is.numeric(x) && length(x) == 1){
    return(x)
  } else {
    utils::capture.output(dput(x))
  }
}

#' @title check_url
#' @description For internal use. Checks whether a URL is live
#' @param url character. The URL to check
#' @returns An httr2 response if the URL is live
#' @keywords internal
#' @export
check_url <- function(url){
  req <- httr2::request(url)
  resp <- tryCatch(
    req |> httr2::req_perform(),
    httr2_http_404 = function(cnd){NULL},
    httr2_failure = function(cnd){NULL},
    httr2_error = function(cnd){NULL}
  )
  if (is.null(resp)){
    warning(paste0(url, " is offline"))
  }
  return(resp)
}


#' @title Spurious package call to avoid note of functions outside R folder
#' @description For internal use.
#' @param x x
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
spurious <- function(x) {
  bslib::accordion(x)
  DT::renderDataTable(x)
  dplyr::add_count(x)
  httr2::curl_help(x)
  leaflet.extras::removeDrawToolbar(x)
  mirai::mirai(x)
  markdown::html_format(x)
  R6::R6Class(x)
  RColorBrewer::brewer.pal(x)
  rintrojs::introjs(x)
  renv::activate(x)
  rmarkdown::github_document(x)
  shinyAce::is.empty(x)
  shinybusy::add_busy_bar(x)
  shinyWidgets::pickerInput(x)
  shinyjs::disable(x)
  terra::rast(x)
  xml2::as_list(x)
  zip::zipr(x)
  return()
}

####################### #
# RESET DATA #
####################### #

#' @title reset_data
#' @description For internal use. Clears the common structure of data, resets the map and any plots
#' @keywords internal
#' @param common The common data structure
#' @export
reset_data <- function(common){
  modules <- names(common$meta)
  common$reset()
  trigger("clear_map")
  for (module in modules){
    trigger(module)
    shinyjs::hide(paste0(module, "-download"), asis = TRUE)
  }
}

####################### #
# SHINY LOG #
####################### #

#' @title writeLog
#' @description For internal use. Add text to a logger
#' @param logger The logger to write the text to. Can be `NULL` or a function
#' @param ... Messages to write to the logger
#' @param type One of `default`, `info`, `error`, `warning`
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
writeLog <- function(logger, ..., type = "default") {
  if (is.null(logger)) {
    if (type == "error") {
      stop(paste0(..., collapse = ""), call. = FALSE)
    } else if (type == "warning") {
      warning(paste0(..., collapse = ""), call. = FALSE)
    } else {
      message(paste0(..., collapse = ""))
    }
  } else if (is.function(logger)) {
    if (type == "default") {
      pre <- "> "
    } else if (type == "starting") {
      pre <- paste0(icon("clock", class = "log_start"), " ")
    } else if (type == "complete") {
      pre <- paste0(icon("check", class = "log_end"), " ")
    } else if (type == "info") {
      if (nchar(...) < 80){
        shinyalert::shinyalert(..., type = "info")
      } else {
        shinyalert::shinyalert("Please, check Log window for more information ",
                               type = "info")
      }
      pre <- paste0(icon("info", class = "log_info"), " ")
    } else if (type == "error") {
      if (nchar(...) < 80){
        shinyalert::shinyalert(...,
                               type = "error")
      } else {
        shinyalert::shinyalert("Please, check Log window for more information ",
                               type = "error")
      }
      pre <- paste0(icon("xmark", class = "log_error"), " ")
    } else if (type == "warning") {
      if (nchar(...) < 80){
        shinyalert::shinyalert(...,
                               type = "warning")
      } else {
        shinyalert::shinyalert("Please, check Log window for more information ",
                               type = "warning")

      }
      pre <- paste0(icon("triangle-exclamation", class = "log_warn"), " ")
    }
    newEntries <- paste0("<br>", pre, ..., collapse = "")
    logger(paste0(logger(), newEntries))
  } else {
    warning("Invalid logger type")
  }
  invisible()
}

#' @title asyncLog
#' @description For internal use. Similar to writeLog but for use inside async
#' functions
#' @param async Whether the function is being used asynchronously
#' @param ... Messages to write to the logger
#' @param type One of `default`, `info`, `error`, `warning`
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
asyncLog <- function(async, ..., type = "default"){
  if (!async) {
    if (type == "error") {
      stop(paste0(..., collapse = ""), call. = FALSE)
    } else if (type == "warning") {
      warning(paste0(..., collapse = ""), call. = FALSE)
    } else {
      message(paste0(..., collapse = ""))
    }
  } else {
    return(as.character(...))
  }
}

####################### #
# LOADING MODAL #
####################### #

#' @title show_loading_modal
#' @description For internal use. Show a modal when something is loading
#' @param message The message to be displayed to the user
#' @returns No return value, called for side effects
#' @keywords internal
#' @export

show_loading_modal <- function(message){
  shinybusy::show_modal_spinner(
    spin = "self-building-square",
    color = "#446e9b",
    text = message
  )
}
#' @title close_loading_modal
#' @description For internal use. Close the modal once loading is complete
#' @param session The session object passed to function given to shinyServer.
#' @returns No return value, called for side effects
#' @keywords internal
#' @export

close_loading_modal <- function (session = getDefaultReactiveDomain())
{
  session$sendModal("remove", NULL)
}

####################### #
# CHANGING TABS #
####################### #

#' @title show_map
#' @description For internal use. Switches the view to the Map tab
#' @param parent_session Session object of the main server function
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
show_map <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Map")
}

#' @title show_results
#' @description For internal use. Switches the view to the Results tab
#' @param parent_session Session object of the main server function
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
show_results <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Results")
}

#' @title show_table
#' @description For internal use. Switches the view to the Table panel
#' @param parent_session Session object of the main server function
#' @returns No return value, called for side effects
#' @keywords internal
#' @export
show_table <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Table")
}
