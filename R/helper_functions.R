####################### #
# MISC #
####################### #
#' @title printVecAsis
#' @description For internal use. Print vector as character string
#' @param x vector
#' @param asChar exclude c notation at the beginning of string
#' @keywords internal
#' @export
printVecAsis <- function(x, asChar = FALSE) {
  if (is.null(x)){
    return("NULL")
  }
  if (is.character(x)) {
    if (length(x) == 1) {
      return(paste0("\"", x, "\""))
    } else {
      if (asChar == FALSE) {
        return(paste0("c(", paste(sapply(x, function(a) paste0("\"", a, "\"")),
                                  collapse = ", "), ")"))
      } else {
        return(paste0("(", paste(sapply(x, function(a) paste0("\"", a, "\"")),
                                 collapse = ", "), ")"))
      }
    }
  } else if ("Date" %in% class(x)){
    if (length(x) == 1) {
      return(paste0("as.Date(\"", x ,"\")"))
    } else {
      return(paste0("c(", paste(paste0("as.Date(\"", x ,"\")"), collapse = ", "), ")"))
    }
  } else {
    if (length(x) == 1) {
      return(x)
    } else {
      if (asChar == FALSE) {
        return(paste0("c(", paste(x, collapse = ", "), ")"))
      } else {
        return(paste0("(", paste(x, collapse = ", "), ")"))
      }
    }
  }
}

#' @title check_url
#' @description For internal use. Checks whether a URL is live
#' @param url character. The URL to check
#' @return An httr2 response if the URL is live or NULL if it is not
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
#' @keywords internal
#' @export
spurious <- function(x) {
  bslib::accordion(x)
  DT::renderDataTable(x)
  dplyr::add_count(x)
  future::as.cluster(x)
  httr2::curl_help(x)
  leafem::addMouseCoordinates(x)
  leaflet.extras::removeDrawToolbar(x)
  markdown::html_format(x)
  promises::as.promise(x)
  R6::R6Class(x)
  RColorBrewer::brewer.pal(x)
  rintrojs::introjs(x)
  renv::activate(x)
  rlang::abort(x)
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
# SHINY LOG #
####################### #

#' @title writeLog
#' @description For internal use. Add text to a logger
#' @param logger The logger to write the text to. Can be NULL or a function
#' @param ... Messages to write to the logger
#' @param type One of "default", "info", "error", "warning"
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

        pre <- paste0(icon("triangle-exclamation", class = "log_warn"), " ")
      }
    }
    newEntries <- paste0("<br>", pre, ..., collapse = "")
    logger(paste0(logger(), newEntries))
  } else {
    warning("Invalid logger type")
  }
  invisible()
}


####################### #
# LOADING MODAL #
####################### #

#' @title show_loading_modal
#' @description For internal use. Show a modal when something is loading
#' @param message The message to be displayed to the user
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
#' @keywords internal
#' @export
show_map <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Map")
}

#' @title show_results
#' @description For internal use. Switches the view to the Results tab
#' @param parent_session Session object of the main server function
#' @keywords internal
#' @export
show_results <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Results")
}

#' @title show_table
#' @description For internal use. Switches the view to the Table panel
#' @param parent_session Session object of the main server function
#' @keywords internal
#' @export
show_table <- function(parent_session){
  updateTabsetPanel(parent_session, "main", selected = "Table")
}
