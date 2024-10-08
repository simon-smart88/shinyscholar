% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metadata.R
\name{metadata}
\alias{metadata}
\title{metadata}
\usage{
metadata(folder_path, module = NULL)
}
\arguments{
\item{folder_path}{character. Path to the parent directory containing the application}

\item{module}{character. (optional) Name of a single module to edit}
}
\description{
Adds lines to modules and their associated rmarkdown files to
semi-automate reproducibility. By default all the modules in the application
are edited or you can specify a single module. If metadata lines are already
present, the file will not be edited. This function is currently experimental
and only semi-automates the process. To ensure that the code is functional
complete the following steps:
\itemize{
\item Check that any inputs created by packages other than \code{{shiny}} are included
\item Add any inputs created dynamically i.e. those without an explicit
line of code to generate them, for example those created inside a loop in a
\code{renderUI} or from a \code{{leaflet}} or \code{{DT}} object.
\item Use the objects in each \code{.Rmd} file to call the module's function.
}
}
\author{
Simon E. H. Smart \href{mailto:simon.smart@cantab.net}{simon.smart@cantab.net}
}
