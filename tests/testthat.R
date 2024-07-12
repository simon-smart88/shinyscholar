Sys.setenv("R_TEST" = "")
library(testthat)
library(shinyscholar)
library(shinytest2)

test_check("shinyscholar")
