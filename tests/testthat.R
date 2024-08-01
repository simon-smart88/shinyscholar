Sys.setenv("R_TEST" = "")
library(testthat)
library(shinyscholar)
library(shinytest2)

test_check("shinyscholar")

if (.Platform$OS.type == "windows" && Sys.getenv("GITHUB_ACTIONS") == "true") {
  system('taskkill /F /IM "chrome.exe" /T')
}
