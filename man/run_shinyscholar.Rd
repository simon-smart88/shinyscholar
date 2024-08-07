% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_shinyscholar.R
\name{run_shinyscholar}
\alias{run_shinyscholar}
\title{Run \emph{shinyscholar} Application}
\usage{
run_shinyscholar(launch.browser = TRUE, port = getOption("shiny.port"))
}
\arguments{
\item{launch.browser}{Whether or not to launch a new browser window.}

\item{port}{The port for the shiny server to listen on. Defaults to a
random available port.}
}
\description{
This function runs the \emph{shinyscholar} application in the user's
default web browser.
}
\examples{
if(interactive()) {
run_shinyscholar()
}
}
\author{
Jamie Kass \href{mailto:jkass@gradcenter.cuny.edu}{jkass@gradcenter.cuny.edu}

Gonzalo E. Pinilla-Buitrago \href{mailto:gpinillabuitrago@gradcenter.cuny.edu}{gpinillabuitrago@gradcenter.cuny.edu}

Simon E. H. Smart \href{mailto:simon.smart@cantab.net}{simon.smart@cantab.net}
}
