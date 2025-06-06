% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/custom_modules.R
\name{register_module}
\alias{register_module}
\title{Register a shinyscholar module}
\usage{
register_module(config_file)
}
\arguments{
\item{config_file}{The path to a YAML file that contains the information about
one or more modules.}
}
\value{
No return value, called for side effects
}
\description{
Currently disabled as cannot be used with apps created by shinyscholar.
Before running the shinyscholar application with
\code{run_shinyscholar()}, you can register your own modules to be used in
shinyscholar.
}
\seealso{
\code{\link[shinyscholar]{create_module}}
}
