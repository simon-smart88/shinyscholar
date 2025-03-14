if (suggests){
  test_that("{shinytest2} recording: e2e_markdown", {

    skip_if(Sys.which("pandoc") == "")
    skip_if(is_fedora())

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_markdown")
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_user")
    app$upload_file("select_user-raster" = raster_path)
    app$set_inputs("select_user-name" = "bio")
    app$click("select_user-run")
    app$set_inputs(tabs = "plot")
    app$set_inputs(plotSel = "plot_scatter")
    app$click("plot_scatter-run")
    app$set_inputs(tabs = "rep")
    app$set_inputs(repSel = "rep_markdown")
    sess_file <- app$get_download("rep_markdown-download")
    expect_false(is.null(sess_file))
    lines <- readLines(sess_file)
    chunks <- sum(grepl("```\\{r", lines))
    expect_equal(chunks, 3)
    target_line <- grep("raster_directory <- ", lines)
    lines[target_line] <- paste0('raster_directory <- "',gsub("bio05.tif","",raster_path),'"')
    writeLines(lines,sess_file)
    rmarkdown::render(sess_file)
    html_file <- gsub("Rmd", "html", sess_file)
    expect_gt(file.info(html_file)$size, 100000)
    app$stop()
    })

  test_that("{shinytest2} recording: e2e_ref_packages", {
    skip_if(Sys.which("pandoc") == "")
    skip_if(is_fedora())

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_ref_packages")
    app$set_inputs(tabs = "rep")
    app$set_inputs(repSel = "rep_refPackages")
    app$set_inputs("rep_refPackages-file_type" = "HTML")
    ref_file <- app$get_download("rep_refPackages-download")
    expect_gt(file.info(ref_file)$size, 10000)
    app$stop()
  })


  test_that("{shinytest2} recording: e2e_table_download", {

    skip_if(is_fedora())

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_table_download")
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_user")
    app$upload_file("select_user-raster" = raster_path)
    app$set_inputs("select_user-name" = "bio")
    app$click("select_user-run")
    app$set_inputs(main = "Table")
    common <- app$get_value(export = "common")
    table_file <- app$get_download("dl_table")
    df <- read.csv(table_file)
    expect_equal(nrow(df),100)
    app$stop()
    })

  test_that("{shinytest2} recording: e2e_plot_downloads", {

    skip_if(is_fedora())

    app <- shinytest2::AppDriver$new(app_dir = system.file("shiny", package = "shinyscholar"), name = "e2e_plot_downloads")
    app$set_inputs(tabs = "select")
    app$set_inputs(selectSel = "select_user")
    app$upload_file("select_user-raster" = raster_path)
    app$set_inputs("select_user-name" = "bio")
    app$click("select_user-run")
    app$set_inputs(tabs = "plot")
    app$set_inputs(plotSel = "plot_scatter")
    app$click("plot_scatter-run")
    app$set_inputs(main = "Save")
    scatter_file <- app$get_download("plot_scatter-download")

    app$set_inputs(plotSel = "plot_hist")
    app$set_inputs(`plot_hist-pal` = "YlOrRd")
    app$click("plot_hist-run")
    app$set_inputs(main = "Save")
    hist_file <- app$get_download("plot_hist-download")
    app$stop()
    expect_gt(file.info(scatter_file)$size, 1000)
    expect_gt(file.info(hist_file)$size, 1000)
  })
}
