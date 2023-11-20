# shinyscholar (v1.0.0)
Shinyscholar is a basic application written in R that can be used as a template to create complex applications that are modular, meet academic standards of attribution and are reproducible outside of the application. *shinyscholar* was [forked](https://github.com/wallaceEcoMod/wallace/tree/51a3ebe10ffd797fc36ad2d2cf8245b014d11b41) from `{wallace}` v2.0.5 ([CRAN](https://cran.r-project.org/package=wallace), [website](https://wallaceecomod.github.io/wallace/index.html)) a modular platform for reproducible modeling of species distributions. Specifically, it harnesses the higher-level structure and core attributes of Wallace but removes its discipline-specific features, yielding a generic template for developers to make their own applications. We are very grateful to the contributors to `{wallace}`  and the features retained from and the new features added in *shinyscholar* are described in `NEWS`.

*Shinyscholar* contains four components (Select, Plot, Reproduce, Template) each of which contain one or two modules (`select_query`, `select_user`, `plot_hist`, `plot_scatter`, `rep_markdown` and `rep_refPackages`, `template_create`) and their code is found in the `inst/shiny/modules` directory. Each of the modules in the Select and Plot components calls a function with the same name that is found in the `R` directory. The `select_query` module and underlying function is the most complex, containing various components for handling errors, both in the module and in the function. The other modules are very simple but included to demonstrate how multiple components and modules can be used. The Reproduce component is used to generate an rmarkdown document that reproduces the analysis conducted in the application. The Template component can be used to produce and download a template version of an app with the same features.

Install *shinyscholar* via Github and run the application with the following R code.

```R
install.packages("devtools")
devtools::install_github("simon-smart88/shinyscholar")
library(shinyscholar)
run_shinyscholar()
```

An individual module can be run for development purposes using `run_module()` e.g. `run_module("select_query")` but this requires the most recent version of the module to be installed.

## Justification
Shiny apps are a great way to lower the barrier for entry for users to complete complex analyses, by enabling online access to the rich ecosystem of R packages through a graphical user interface. However, often apps produced by academics do not follow best practices in software development or open science. If apps become popular, more features are requested and developers move onto new roles, it may become difficult to maintain their codebase. If users cannot reproduce their analyses outside of the application, it prevents them from modifying analyses to suit their particular use-case, makes it harder to understand the analysis and limits their ability to use the results in publications. Additionally, it may not be possible to determine which R packages are being used in the application, making it more onerous to cite the packages in publications. Other packages exist for creating templates of shiny apps, e.g. `{golem}` and `{rhino}` but these are not geared towards use by academics.

`{wallace}` addressed these shortcomings and the attributes of *shinyscholar* are built upon those of `{wallace}`. Apps built using *shinyscholar* should maintain these characteristics:

* **accessible**: lowers barriers to implementing complex modular `{shiny}` apps for scientific analysis
* **open**: the code is free to use and modify (GPL 3.0) and can be viewed from inside the application
* **expandable**: users can author and contribute modules that enable new methodological options
* **flexible**: options for user uploads and downloads of results
* **interactive**: includes an embedded zoomable `{leaflet}` map, sortable `{DF}` data tables, and visualizations of results
* **instructive**: features guidance text that educates users about theoretical and analytical aspects of each step in the workflow
* **reproducible**: users can download an `{rmarkdown}` .Rmd file that when run reproduces the analysis, and also save sessions and load them later
* **robust**: modules and their underlying functions are tested using `{testthat}` and `{shinytest2}`

## Use cases
Shinyscholar is aimed towards creating applications for complex analyses that have several steps and where there may be multiple options for each step e.g. where the data is sourced from, which model is used or how the results are plotted. It is probably not suitable for use if you have never developed a shiny app before, but if you have developed a simple app which is growing in complexity, it should be fairly straightforward to migrate your code across. 

## Using shinyscholar as a template

### License
Shinyscholar is licensed under the GPLv3 license and consequently any apps made using shinyscholar must be licensed under the same license. 

### Initialisation
The `create_template()` function can be used to create the template for a new app. For example, the following call will produce a folder called `demo` in your Documents folder and create an app containing two components (load and plot) each containing two modules. You can choose whether certain features are included in the overall app by setting the `include_*` parameters and also whether each module contains mapping, result, rmarkdown and save functionality by setting the parameters inside the `modules` dataframe. `common_objects` contains a list of the objects which will be shared between modules and will be available inside all of the modules as e.g. `common$raster`.

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
"save" = c(TRUE, TRUE, TRUE, TRUE))

common_objects = c("raster", "histogram", "scatter")

shinyscholar::create_template(path = "~/Documents", name = "demo", author = "Simon E. H. Smart",
include_map = TRUE, include_table = TRUE, include_code = TRUE, common_objects = common_objects, modules = modules, install = TRUE)
```

### Installation
`create_template()` creates the file structure of a package and if `install` is set to `TRUE` it will be installed automatically. If you prefer to install manually, run `devtools::install_local(path = "~/Documents/demo", force=TRUE)` (assuming as in the example above the app was initiated in `~/Documents/demo`). You need to repeat this process after making changes to the app, or if using Rstudio, use Ctrl+Shift+B or Command+Shift+B. Now you can run the app using `shiny::runApp(system.file('shiny', package='demo'))` or `demo::run_demo()`.

### Development
#### Modules
After installing the initial version, the modules only contain skeleton code. There are four files for each module located in `/inst/shiny/modules` and each module calls a function found in `/R`. It may be helpful to familiarise yourself with the code for the existing application either by viewing the files in `/inst/shiny/modules` or by using the Code tab in the app.

##### .R

This is the main module file and contains the UI and server components as well as any other functionality specified at initialisation. 

The `*_module_ui` function can be developed just like a normal UI function inside a shiny app, but only contains \*Input elements and the input ids need wrapping inside `ns()` to create ids that are unique to the module. The template contains an `actionButton` which when clicked runs the code inside the `*_module_server` function. If the computations performed by the module are simple, then you could choose to remove the `actionButton()` in the UI and the `observeEvent()` so that the server runs reactively whenever the inputs are changed.

The `*_module_server` function contains an `observeEvent()` which is run when the `actionButton()` in the UI is clicked. Inside the `observeEvent()` there is a consistent structure to the code:

* In the *warning* block, examine inputs to check that they are as expected and issue warnings if not using `common$logger %>% writeLog()` See the documentation of `shinyscholar::writeLog()` for more details.
* In the *function call* block, pass the inputs to the module function.
* In the *load into common* block, store the result(s) of the function call in the relevant `common` object.
* In the *metadata* block, store any relevant input metadata which is required to reproduce the function call in the `common$meta` object.
* In the *trigger* block, `gargoyle::trigger()` is called which can be used to trigger actions elsewhere in the module or app using `gargoyle::watch()`. This should not need editing.
* In the *result* block, use the relevant `input` values or `common` objects to produce `render*` objects which will be passed to the `_module_result` function.
* In the *return* block, the current `input` values can be stored as a `list` inside the `save` function e.g. `select_date = input$date` when the app is saved and then retrieved when the app is loaded using various `updateInput` functions inside the `load` function e.g. `updateSelectInput(session, "date", selected = state$select_date`).

The `*_module_result` function contains the `*Output()` functions which would normally be included in the UI function. As in the `*_module_ui` function, the object ids need wrapping inside `ns()`.

The `*_module_map` function updates the `{leaflet}` map. `map` is a `leafletProxy()` object created in the main server function so leaflet functions can be piped to it e.g. `map &>& addRasterImage()` 

The `*_module_rmd` function creates a list of objects which are passed to the module's .Rmd file to reproduce the analysis. The first `*_knit` object is a boolean used to control whether or not the module has been used and therefore whether the markdown should be included in the user's markdown. If the object to be passed over is a vector, then it should be wrapped in `printVecAsis()` which converts it to a string so that it can be knitted into the .Rmd.

##### .Rmd
This is a template for the rmarkdown that can be used to reproduce the module. Objects from `*_module_rmd` are passed into this template when the user downloads the rmarkdown. Objects from the `*_module_rmd` function are passed into the template when the document is knitted. If `module_setting` is added to the list in `*_module_rmd` then the value will be substituted for `{{module_setting}}` inside the .Rmd. If `module_setting` is a string, then you need to use `"{{module_setting}}"` inside the .Rmd.

##### .md
This is a guidance document to explain the theoretical background behind the module and how it has been implemented. 

##### .yml
This is a configuration file used when the modules are loaded. Add any R packages used inside the module or the function that it calls to `package` so that they can be cited. Package names should be included as plain text rather than as strings e.g. `package: [dplyr,shiny]`. The `short_name` field is used to generate the UI for selecting which module to use. By default it uses the `module` column of the `modules` dataframe but you may wish to edit this for clarity.

##### .R function
This function performs the computation of the module. Creating this function separately to the shiny functionality is advantageous because it is easier to test and because it can be called from inside the .Rmd file. Messages can be posted to the log from inside these functions if it is passed `common$logger` - see `/R/select_query.R` for an example.

#### Components
Each component has a skeleton guidance document located in `inst/shiny/Rmd` e.g. `gtext_plot.Rmd` which you should use to describe the functionality of the component in general and also include any relevant references. 

#### server.R and ui.R
These should not require substantial editing unless you wish to change the layout or appearance of the app. One exception is the block of code in `server.R` that creates the table because this is shared between modules. If your app uses `{terra}` objects, they need to be wrapped and unwrapped using `terra::wrap()` and `terra::unwrap()` when they are saved and loaded (see the `server.R` file of this repository for an example).

#### Theme
The colour of elements in the app are controlled by the theme present in the `bslib::bs_theme()` function inside `ui.R`. The default theme used is spacelab, but you can choose your own from https://bootswatch.com/.

#### common.R
This file contains the data structure that is shared between modules and you can add extra objects as you wish. `common` is an R6 class object. By default, all the objects in `common` are created as `NULL` but you may wish to Objects in `common` can be functions, for example in the demonstration app, `common$add_map_layer()` is used to add a layer to `common$map_layers`.

#### R/run_module.R
This function is designed to make it easier to develop modules by being able to run a single module in isolation. If your module requires objects from previous steps in an analysis, you can modify this function to modify the state of `common` so that the objects a module is dependent on are available immediately. For example, in the demonstration app, the function loads a raster image from a file when the module being run is from the plot component.

#### Testing
##### Unit tests
Unit tests should be added for each function called by each module to ensure that it produces the intended output. These tests are run in the conventional manner by `{testthat}`. 

##### End-to-end testing
End-to-end testing is used to validate that the app itself is functions and uses {shinytest2}. Tests can be recorded using `shinytest2::record_test()` but the snapshot functionality of the package does not work well with the architecture of this package. Recording tests is still a useful way to record the input names required to navigate through the app. `common` is made available for use inside tests by using `common <- app$get_value(export = "common")` so you can check that objects are in the expected state after running a module.

### Notes for Windows users

#### PDF download of session code
If PDF downloading of session code is not working for you, please follow the following instructions, taken from <a href="https://github.com/rstudio/shiny-examples/issues/34" target="_blank">here</a>:
     - Step 1: Download and Install MiKTeX from http://miktex.org/2.9/setup
     - Step 2: Run `Sys.getenv("PATH")` in R studio. This command returns the path where Rstudio is trying to find pdflatex.exe. In Windows (64-bit), it should return "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe". If pdflatex.exe is not located in this location Rstudio gives this error code 41.
     - Step 3: To set this path variable run: `Sys.setenv(PATH=paste(Sys.getenv("PATH"),"C:/Program Files/MiKTeX 2.9/miktex/bin/x64/",sep=";"))`.

#### Only for Github installation
If you are using Windows, please download and install <a href="https://cran.r-project.org/bin/windows/Rtools/" target="_blank">RTools</a> before installing the `devtools` package. After you install RTools, please make sure you add "C:\Rtools\bin" to your PATH variable (instructions <a href="https://stackoverflow.com/questions/29129681/create-zip-file-error-running-command-had-status-127/29480538#29480538" target="_blank">here</a>). Additionally, when using `devtools` on Windows machines, there is a known <a href="https://github.com/r-lib/devtools/issues/1298" target="_blank">bug</a> that sometimes results in the inability to download all package dependencies. If this happens to you, please install the packages and their dependencies directly from CRAN.
