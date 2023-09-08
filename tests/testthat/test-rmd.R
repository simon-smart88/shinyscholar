path <- list.files(system.file("extdata/wc", package = "SMART"),
                   pattern = ".tif$", full.names = TRUE)

test_that("{shinytest2} recording: e2e_markdown", {
  app <- shinytest2::AppDriver$new(app_dir = '../../inst/shiny', name = "e2e_markdown")
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
  save_file <- app$get_download("dlRMD")
  expect_false(is.null(save_file))
  lines <- readLines(save_file)
  lines[42] <- paste0('raster_directory <- "',gsub("bio05.tif","",path),'"')
  writeLines(lines,save_file)
  rmarkdown::render(save_file)
  #ras is internal to the Rmd so checks that the code runs
  expect_is(ras,"SpatRaster")
  html_file <- gsub("Rmd","html",save_file)
  expect_gt(file.info(html_file)$size, 100000)
  })




