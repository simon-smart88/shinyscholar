path <- list.files(system.file("extdata/wc", package = "shinyscholar"),
                   pattern = ".tif$", full.names = TRUE)

test_that("{shinytest2} recording: e2e_markdown", {
  testthat::skip_on_ci()

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_markdown")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(tabs = "rep")
  app$set_inputs(repSel = "rep_markdown")
  sess_file <- app$get_download("dlRMD")
  expect_false(is.null(sess_file))
  lines <- readLines(sess_file)
  lines[45] <- paste0('raster_directory <- "',gsub("bio05.tif","",path),'"')
  writeLines(lines,sess_file)
  rmarkdown::render(sess_file)
  #ras is internal to the Rmd so checks that the code runs
  expect_is(ras,"SpatRaster")
  html_file <- gsub("Rmd","html",sess_file)
  expect_gt(file.info(html_file)$size, 100000)

  app$set_inputs(repSel = "rep_refPackages")
  app$set_inputs(refFileType = "HTML")
  ref_file <- app$get_download("dlrefPackages")
  expect_gt(file.info(ref_file)$size, 10000)
  })

test_that("{shinytest2} recording: e2e_table_download", {
  testthat::skip_on_ci()

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_table_download")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(main = "Table")
  table_file <- app$get_download("dl_table")
  df <- read.csv(table_file)
  expect_equal(nrow(df),100)
  })

test_that("{shinytest2} recording: e2e_plot_downloads", {
  testthat::skip_on_ci()

  app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_downloads")
  app$set_inputs(tabs = "select")
  app$set_inputs(selectSel = "select_user")
  app$upload_file(`select_user-ras` = path)
  app$set_inputs(`select_user-name` = "bio")
  app$click("select_user-run")
  app$set_inputs(tabs = "plot")
  app$set_inputs(plotSel = "plot_scatter")
  app$click("plot_scatter-run")
  app$set_inputs(main = "Save")
  scatter_file <- app$get_download("dl_scatter")

  app$set_inputs(plotSel = "plot_hist")
  app$set_inputs(`plot_hist-pal` = "YlOrRd")
  app$click("plot_hist-run")
  app$set_inputs(main = "Save")
  hist_file <- app$get_download("dl_hist")

  expect_gt(file.info(scatter_file)$size, 1000)
  expect_gt(file.info(hist_file)$size, 1000)

})

