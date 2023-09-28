Sys.setenv("R_TEST" = "")
library(testthat)
library(SMART)
library(shinytest2)

test_check("SMART")

test_dir('tests/testthat/')
