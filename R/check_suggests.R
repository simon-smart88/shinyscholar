#' @title Check whether suggested packages are installed
#' @description Checks whether all the packages in Suggests are installed
#' and stops execution if not or returns `FALSE` when example = `TRUE`
#' @author Simon Smart <simon.smart@@cantab.net>
#' @param testing logical. For use in testing.
#' @param example logical. For use in examples.
#' @returns No return value, called for side effects unless example is `TRUE`
#' in which case `FALSE` is returned if the Suggests are not installed or `TRUE`
#' if they are installed.
#' @keywords internal
#' @export
check_suggests <- function(testing = FALSE, example = FALSE){
  desc <- read.dcf(system.file("DESCRIPTION", package = "shinyscholar"))
  suggests <- trimws(
    gsub(
      "\\(.*\\)", "",
      gsub("\\n", "", unlist(strsplit(desc[,"Suggests"], ",")))
    )
  )
  if (testing){
    suggests <- c(suggests, "phantompackage")
  }

  check <- any(!sapply(suggests, requireNamespace, quietly = TRUE))

  if (example){
    return(!check)
  } else {
    if (check){
      stop('Some packages required to run the application are not installed, please reinstall using:
       install.packages("shinyscholar", dependencies = TRUE)')
    }
  }
}
