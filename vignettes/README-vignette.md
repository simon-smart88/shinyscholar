---
title: "A guide to developing applications with Shinyscholar"
author: "Simon Smart"
date: "
2024-12-04
"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{A guide to developing applications with Shinyscholar}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

# shinyscholar (v0.2.2)

<img src="https://raw.githubusercontent.com/simon-smart88/shinyscholar/master/inst/shiny/www/logo.png" width="259" height="300" align="right" style="border:10px solid white;">

Shinyscholar creates a skeleton R Shiny application that can be used to create complex applications that are modular, meet academic standards of attribution and are reproducible outside of the application. By using *shinyscholar*, to create a template application, developers will be encouraged to produce applications that are maintainable and run reliably without having to learn software development best-practices from scratch. *shinyscholar* was [forked](https://github.com/wallaceEcoMod/wallace/tree/51a3ebe10ffd797fc36ad2d2cf8245b014d11b41) from `{wallace}` v2.0.5 ([CRAN](https://cran.r-project.org/package=wallace), [website](https://wallaceecomod.github.io/wallace/index.html)) a modular platform for reproducible modelling of species distributions. Specifically, it harnesses the higher-level structure and core attributes of Wallace but removes its discipline-specific features, yielding a generic template for developers to make their own applications. We are very grateful to the contributors to `{wallace}` and the features retained from it and the new features added in *shinyscholar* are described in `NEWS`. 

*Shinyscholar* also contains an example application with four components (Select, Plot, Reproduce, Template) each of which contain one or two modules (`select_query`, `select_async`, `select_user`, `plot_hist`, `plot_scatter`, `rep_markdown`, `rep_renv`, `rep_refPackages` and `template_create`) and their code is found in the `inst/shiny/modules` directory. Each of the modules in the Select and Plot components calls a function with the same name that is found in the `R` directory. The `select_query` module and underlying function is the most complex, containing various components for handling errors, both in the module and in the function. The other modules are very simple but included to demonstrate how multiple components and modules can be used. The Reproduce component is used to generate an rmarkdown document that reproduces the analysis conducted in the application. The Template component can be used to produce and download a template version of an app with the same features.

To use *shinyscholar* to create new applications you can install with the following R code:

```R
install.packages("shinyscholar")
```

Or via Github with:

```R
install.packages("remotes")
remotes::install_github("simon-smart88/shinyscholar")
```

To run the example application requires additional packages and this can be achieved with:

```R
install.packages("shinyscholar", dependencies = TRUE)
library(shinyscholar)
run_shinyscholar()
```

## Justification
Shiny apps lower the barrier for entry for users to complete complex analyses, by enabling online access to the rich ecosystem of R packages through a graphical user interface. However, often apps produced by academics do not follow best practices in software development or open science. If apps become popular, more features are requested and developers move onto new roles, it may become difficult to maintain their codebase. If users cannot reproduce their analyses outside of the application, it prevents them from modifying analyses to suit their particular use-case, makes it harder to understand the analysis and limits their ability to use the results in publications. Additionally, it may not be possible to determine which R packages are being used in the application, making it more onerous to cite the packages in publications. Other packages exist for creating templates of shiny apps, e.g. `{golem}` and `{rhino}` but these are more generic and do not contain features specifically for use by academics.

`{wallace}` addressed these shortcomings and the attributes of *shinyscholar* are built upon those of `{wallace}`. Apps built using *shinyscholar* should maintain these characteristics:

* **accessible**: lowers barriers to implementing complex modular `{shiny}` apps for scientific analysis by providing an intuitive graphical user interface
* **open**: the code is free to use and modify (GPL 3.0) and can be viewed from inside the application
* **expandable**: users can author and contribute modules that enable new methodological options
* **flexible**: options for user uploads and downloads of results
* **interactive**: includes an embedded zoomable `{leaflet}` map, sortable `{DF}` data tables, and visualizations of results
* **instructive**: features guidance text that educates users about theoretical and analytical aspects of each step in the workflow
* **reproducible**: users can download an `{rmarkdown}` .Rmd file that when run reproduces the analysis, and also save sessions and load them later
* **reliable**: modules and their underlying functions are tested using `{testthat}` and `{shinytest2}`

## Use cases
Shinyscholar is aimed towards creating applications for complex analyses that have several steps and where there may be multiple options for each step e.g. where the data is sourced from, which model is used or how the results are plotted. It is probably not suitable for use if you have never developed a shiny app before, but if you have developed a simple app which is growing in complexity, it should be fairly straightforward to migrate your code across. 

## Using shinyscholar as a template

### License
Shinyscholar is licensed under the GPLv3 license and consequently any apps made using shinyscholar must be licensed under the same license. 

### Initialisation
The `create_template()` function can be used to create the template for a new app. For example, the following call will produce a folder called `demo` in your Documents folder and create an app containing two components (load and plot) each containing two modules. You can choose whether certain features are included in the overall app by setting the `include_*` parameters and also whether each module contains mapping, result, rmarkdown and save functionality by setting the parameters inside the `modules` dataframe. `common_objects` contains the name of objects shared between modules and will be available inside all of the modules as e.g. `common$raster`. See [this section](#common.R) for more details on the `common` data structure.

You can also generate a template app using the Template component of the app either run locally with `run_shinyscholar()` or at https://simonsmart.shinyapps.io/shinyscholar/ 

```
modules <- data.frame(
"component" = c("load", "load", "plot", "plot"),
"long_component" = c("Load data", "Load data", "Plot data", "Plot data"),
"module" = c("user", "database", "histogram", "scatter"),
"long_module" = c("Upload your own data", "Query a database to obtain data", "Plot the data as a histogram", "Plot the data as a scatterplot"),
"map" = c(TRUE, TRUE, FALSE, FALSE),
"result" = c(FALSE, FALSE, TRUE, TRUE),
"rmd" = c(TRUE, TRUE, TRUE, TRUE),
"save" = c(TRUE, TRUE, TRUE, TRUE),
"async" = c(FALSE, TRUE, FALSE, FALSE))

common_objects = c("raster", "histogram", "scatter")

shinyscholar::create_template(path = file.path("~", "Documents"), name = "demo", author = "Simon E. H. Smart",
include_map = TRUE, include_table = TRUE, include_code = TRUE, common_objects = common_objects, modules = modules, install = TRUE)
```

### Installation
`create_template()` creates the file structure of a package and if `install` is set to `TRUE` it will be installed automatically. If you prefer to install manually, run `devtools::install_local(path = "~/Documents/demo", force=TRUE)` (assuming as in the example above the app was initiated in `~/Documents/demo`). You need to repeat this process after making changes to the app, or if using Rstudio, use Ctrl+Shift+B or Command+Shift+B. Now you can run the app using `shiny::runApp(system.file('shiny', package='demo'))` or `demo::run_demo()`.

### Development
#### Modules
After installing the initial version, the modules only contain skeleton code. There are four files for each module located in `/inst/shiny/modules` and each module calls a function found in `/R`. It may be helpful to familiarise yourself with the code for the existing application either by viewing the files in `/inst/shiny/modules` or by using the Code tab in the app.

##### .R

This is the main module file and contains the UI and server components as well as any other functionality specified at initialisation. `<identifier>` is used as a placeholder for the identifier of the module e.g. load_user.

The `<identifier>_module_ui` function can be developed just like a normal UI function inside a shiny app, but only contains \*Input elements and the input ids need wrapping inside `ns()` to create ids that are unique to the module. The template contains an `actionButton` which when clicked runs the code inside the `*_module_server` function. If the computations performed by the module are simple, then you could choose to remove the `actionButton()` in the UI and the `observeEvent()` so that the server runs reactively whenever the inputs are changed.

The `<identifier>_module_server` function contains an `observeEvent()` which is run when the `actionButton()` in the UI is clicked. Inside the `observeEvent()` there is a consistent structure to the code:

* In the *warning* block, examine inputs to check that they are as expected and issue warnings if not using `common$logger %>% writeLog()` See the documentation of `shinyscholar::writeLog()` for more details.
* In the *function call* block, pass the inputs to the module function.
* In the *load into common* block, store the result(s) of the function call in the relevant `common` object.
* In the *metadata* block, store any relevant input metadata which is required to reproduce the function call, or is used in the mapping function, in the `common$meta$<identifier>` object. This can be semi-automated using the `metadata()` function once you have finished developing the module.
* In the *trigger* block, `gargoyle::trigger()` is called which can be used to trigger actions elsewhere in the module or app using `gargoyle::watch()`. This should not need editing.
* In the *result* block, use the relevant `input` values or `common` objects to produce `render*` objects which will be passed to the `_module_result` function.
* In the *return* block, the current `input` values can be stored as a `list` inside the `save` function e.g. `select_date = input$date` when the app is saved and then retrieved when the app is loaded using various `updateInput` functions inside the `load` function e.g. `updateSelectInput(session, "date", selected = state$select_date`). This can be done automatically by calling `save_and_load()` either for all the modules or a single module.

The `<identifier>_module_result` function contains the `*Output()` functions which would normally be included in the UI function. As in the `*_module_ui` function, the object ids need wrapping inside `ns()`.

The `<identifier>_module_map` function updates the `{leaflet}` map. `map` is a `leafletProxy()` object created in the main server function so leaflet functions can be piped to it e.g. `map &>& addRasterImage()` 

The `*_module_rmd` function creates a list of objects which are passed to the module's .Rmd file to reproduce the analysis. The first `*_knit` object is a boolean used to control whether or not the module has been used and therefore whether the markdown should be included in the user's markdown. Writing this code can be semi-automated using the `metadata()` function once you have finished developing the module.

##### .Rmd
This is a template for the rmarkdown that can be used to reproduce the module. Objects from `*_module_rmd` are passed into this template when the user downloads the rmarkdown. Objects from the `*_module_rmd` function are passed into the template when the document is knitted. If `module_setting` is added to the list in `*_module_rmd` then the value will be substituted for `{{module_setting}}` inside the .Rmd. If `module_setting` is a character string, then you need to use `"{{module_setting}}"` inside the .Rmd.

##### .md
This is a guidance document to explain the theoretical background behind the module and how it has been implemented. 

##### .yml
This is a configuration file used when the modules are loaded. Add any R packages used inside the module or the function that it calls to `package` so that they can be cited. Package names should be included as plain text rather than as strings e.g. `package: [dplyr,shiny]`. The `short_name` field is used to generate the UI for selecting which module to use. By default it uses the `module` column of the `modules` dataframe but you may wish to edit this for clarity.

##### .R function
This function performs the computation of the module. Creating this function separately to the shiny functionality is advantageous because it is easier to test, separates reactivity from computation, is easier to document, and because it can be called from inside the .Rmd file. Messages can be posted to the log from inside these functions if it is passed `common$logger` but this should set to `NULL` by default so that message are printed to the console when the function is used outside of the application. See `/R/select_query_f.R` for an example.

#### Components
Each component has a skeleton guidance document located in `inst/shiny/Rmd` e.g. `gtext_plot.Rmd` which you should use to describe the functionality of the component in general and also include any relevant references. 

#### server.R and ui.R
These should not require substantial editing unless you wish to change the layout or appearance of the app. One exception is the block of code in `server.R` that creates the table because this is shared between modules. 

#### Theme
The colour of elements in the app are controlled by the theme present in the `bslib::bs_theme()` function inside `ui.R`. The default theme used is `spacelab`, but you can choose your own from https://bootswatch.com/.

#### common.R
This file contains the data structure that is shared between modules and you can add extra objects as you wish. `common` is an [R6 class](https://r6.r-lib.org/) which is similar to a `list()` but items in it must be declared in this file before you use them in the app. Any type of object can be stored in `common`, i.e. dataframes, plots, strings etc. By default, all the objects in `common` are created as `NULL` but you may wish to change these to load a default value. Objects inside `common` are not reactive by default, but you can make them `reactiveVal` or `reactiveValues`, for example like `common$logger`. Objects in `common` can also be functions, for example in the demonstration app, `common$add_map_layer()` is used to add a layer to `common$map_layers`.

#### Testing
One test file for each module is created by `create_template()` and placed in `tests/testthat/`. It contains one unit test for the function which checks that it returns `NULL` and one end-to-end test which runs the app runs and that one of the objects in `common` remains set as `NULL`. During development of the modules, you should add tests to check the function runs as expected, returns errors when it cannot run and that the function runs when called from the app.

##### Unit tests
Unit tests should be added for each function called by each module to ensure that it produces the intended output and returns errors appropriately. These tests are run in the conventional manner by `{testthat}`. 

##### End-to-end testing
End-to-end testing is used to validate that the app itself functions and uses `{shinytest2}`. Tests can be recorded using `shinytest2::record_test()` but the snapshot functionality of the package does not work well with the architecture of this package. Recording tests is still a useful way to record the input names required to navigate through the app though. `common` is made available for use inside tests by using `common <- app$get_value(export = "common")` so you can check that objects are in the expected state after running a module. This method is quite flaky however and if it does not work, alternatively `common` can be accessed by using the save functionality:

```
app$set_inputs(main = "Save")
save_file <- app$get_download("core_save-save_session", filename = save_path)
common <- readRDS(save_file)
```

#### Adding extra modules
Further modules can be added using `create_module()` which creates the four files for the module. The module configuration file then needs to be added to `base_module_configs` in `global.R` and should be placed in the relevant position for the analysis since this vector controls the order of chunks within the Rmarkdown output. Any extra data objects that the modules creates must be added to `common.R`. This does not currently create the testing files or function file so these must be added manually.

#### Asynchronous modules
Support for asynchronous operations was added in v0.2.0 using the new `ExtendedTask` feature added in `{shiny}` v1.8.1. This has the advantage of allowing long-running operations to run in the background whilst the app remains responsive to the user and any other users connected to the same instance. Running modules asynchronously increases complexity however and requires several changes to structure of modules and the app itself. The `select_async` module contains an implementation that is functionally identical to `select_query` but runs asynchronously. 

##### Running tasks
`common$tasks` is a list that stores details of all the asynchronous tasks. Each task is added to the list above the `observeEvent()` in the `<identifier>_module_server` function as `common$tasks$<identifier>`. The task contains the module's function wrapped by `promises::future_promise()` and bound to a `bslib::bind_task_button()` which disables the button when the task is running:

```
common$tasks$<identifier> <- ExtendedTask$new(function(...) {
    promises::future_promise({
      <identifer>(...)
    })
  }) |> bslib::bind_task_button("run")
```

The task is invoked inside the `observeEvent()` by calling `common$tasks$<identifier>$invoke()` with the arguments of the module's function. As in the default implementation, metadata should be stored at this point when the function is called.

##### Logging
Because the asynchronous tasks are run in a different R session, `common$logger` is no longer accessible from inside the module's function and therefore cannot be used to send messages to the logger directly. Instead, an `async` parameter needs to be added to the function and error messages are returned by the function when `async` is `TRUE` or transferred to `stop` or `warning` if `async` is `FALSE` e.g. when being used in the .Rmd.

##### Receiving results
A separate `observe()` named `results` is required to listen for the result of the task available at `common$tasks$<identifier>$result()` but to prevent endless loops, we must stop the observer from functioning once the results are calculated by calling `results$suspend()` and reactivate it prior to the task being invoked using `results$resume()`. Inside `results`, the class of the object returned by the function should be checked and either passed to `common$logger` if it is an error message or stored in `common` as in the default implementation. 

##### Mapping
In the default implementation, only the mapping function of the currently selected module can be called, which prevents the result of an asynchronous task being added to the map. Instead `map` is passed as an argument to the module server function and then called once the result has been produced using `do.call("<identifier>_module_map", list(map, common))`.

##### End-to-end testing
The task needs to started using `app$click(selector = "#<identifier>-run")`. `{shinytest2}` cannot detect that an asynchronous task is running and so the `timeout` parameter of `shinytest2::AppDriver()` must be set to allow sufficient time for the function to run. An `input` value should be set inside `results` using `shinyjs::runjs("Shiny.setInputValue('<identifier>-complete', 'complete');")` which can then be detected inside the test using `app$wait_for_value(input = "<identifier>-complete")` to indicate that the task has completed.

## Acknowledgments
shinyscholar was developed as part of a project to develop digital tools for modelling infectious diseases [funded by Wellcome](https://wellcome.org/news/digital-tools-climate-sensitive-infectious-disease) at the [University of Leicester](https://le.ac.uk/). The version of Wallace that shinyscholar was derived from was funded by the [Global Biodiversity Information Facility](https://www.gbif.org/), [National Science Foundation](https://www.nsf.gov/) and [NASA](https://www.nasa.gov/).

## Notes for Windows users

### PDF download of session code
If PDF downloading of session code is not working for you, please follow the following instructions, taken from <a href="https://github.com/rstudio/shiny-examples/issues/34" target="_blank">here</a>:
     - Step 1: Download and Install MiKTeX from http://miktex.org/2.9/setup
     - Step 2: Run `Sys.getenv("PATH")` in R studio. This command returns the path where Rstudio is trying to find pdflatex.exe. In Windows (64-bit), it should return "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe". If pdflatex.exe is not located in this location Rstudio gives this error code 41.
     - Step 3: To set this path variable run: `Sys.setenv(PATH=paste(Sys.getenv("PATH"),"C:/Program Files/MiKTeX 2.9/miktex/bin/x64/",sep=";"))`.

### Only for Github installation
If you are using Windows, please download and install <a href="https://cran.r-project.org/bin/windows/Rtools/" target="_blank">RTools</a> before installing the `devtools` package. After you install RTools, please make sure you add "C:\Rtools\bin" to your PATH variable (instructions <a href="https://stackoverflow.com/questions/29129681/create-zip-file-error-running-command-had-status-127/29480538#29480538" target="_blank">here</a>). Additionally, when using `devtools` on Windows machines, there is a known <a href="https://github.com/r-lib/devtools/issues/1298" target="_blank">bug</a> that sometimes results in the inability to download all package dependencies. If this happens to you, please install the packages and their dependencies directly from CRAN.
