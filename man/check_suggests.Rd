% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_suggests.R
\name{check_suggests}
\alias{check_suggests}
\title{Check whether suggested packages are installed}
\usage{
check_suggests(testing = FALSE, example = FALSE)
}
\arguments{
\item{testing}{logical. For use in testing.}

\item{example}{logical. For use in examples.}
}
\value{
No return value, called for side effects unless example is \code{TRUE}
in which case \code{FALSE} is returned if the Suggests are not installed or \code{TRUE}
if they are installed.
}
\description{
Checks whether all the packages in Suggests are installed
and stops execution if not or returns \code{FALSE} when example = \code{TRUE}
}
\author{
Simon Smart \href{mailto:simon.smart@cantab.net}{simon.smart@cantab.net}
}
\keyword{internal}
