#' @title Run \emph{shinyscholar} Application
#' @description This function runs the \emph{shinyscholar} application in the user's
#' default web browser.
#' @param launch.browser Whether or not to launch a new browser window.
#' @param port The port for the shiny server to listen on. Defaults to a
#' random available port.
#'
#' @examples
#' if(interactive()) {
#' run_shinyscholar()
#' }
#' @author Jamie Kass <jkass@@gradcenter.cuny.edu>
#' @author Gonzalo E. Pinilla-Buitrago <gpinillabuitrago@@gradcenter.cuny.edu>
#' @author Simon E. H. Smart <simon.smart@@cantab.net>
#' @export
run_shinyscholar <- function(launch.browser = TRUE, port = getOption("shiny.port")) {
  app_path <- system.file("shiny", package = "shinyscholar")
  knitcitations::cleanbib()
  options("citation_format" = "pandoc")
  preexisting_objects <- ls(envir = .GlobalEnv)
  on.exit(rm(list = setdiff(ls(envir = .GlobalEnv), preexisting_objects), envir = .GlobalEnv))
  return(shiny::runApp(app_path, launch.browser = launch.browser, port = port))
}


