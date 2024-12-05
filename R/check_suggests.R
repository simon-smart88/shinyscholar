#' @title Check suggests
#' @description
#' Checks whether all the packages in Suggests are installed and stops execution
#' if not.
#' @author Simon Smart <simon.smart@@cantab.net>
#' @param testing. logical. For use in testing.
#' @keywords internal
#' @export
check_suggests <- function(testing = FALSE){
  desc <- read.dcf(system.file("DESCRIPTION", package = "shinyscholar"))
  suggests <- desc[,"Suggests"] %>%
    strsplit(",") %>%
    unlist() %>%
    gsub("\\n", "", .) %>%
    gsub("\\(.*\\)", "", .) %>%
    trimws()
  if (testing){
    suggests <- c(suggests, "phantompackage")
  }
  if (any(!sapply(suggests, requireNamespace, quietly = TRUE))){
    stop('Some packages required to run the application are not installed, please reinstall using:
       install.packages("shinyscholar", dependencies = TRUE)')
  }
}
