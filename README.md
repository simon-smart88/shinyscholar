# SMART (v1.0.0)
SMART (Shiny Modular Academic Reproducible Template) is a basic application written in R that can be used as a template to create complex applications that are modular and reproducible outside of the application. *SMART* was forked from [*Wallace*](https://github.com/wallaceEcoMod/wallace), a modular platform for reproducible modeling of species distributions and we are very grateful to the contributors of that package. The features retained from *Wallace* and the new features added in *SMART* are described in `NEWS`.

*SMART* contains two components (Select, Plot, Reproduce) each of which contain two modules (`select_query`, `select_user`, `plot_hist`, `plot_scatter`, `rep_markdown` and `rep_refPackages`) and their code is found in the `inst/shiny/modules` directory. Each of the modules in the Select and Plot components calls a function with the same name that is found in the `R` directory. The `select_query` module and underlying function is the most complex, containing various components for handling errors, both in the module and in the function. The other modules are very simple but included to demonstrate how multiple components and modules can be used.

Install *SMART* via Github and run the application with the following R code.

```R
install.packages("devtools")
devtools::install_github("simon-smart88/SMART")
library(SMART)
run_smart()
```

An individual module can be run using `module_tester()` e.g. `module_tester("select_query")`

## Justification
Shiny apps are a great way to lower the barrier for entry for users to complete complex analyses, but often apps produced by academics do not follow best practices in software development or open science. If apps become popular, more features are requested and developers move onto new roles, it may become difficult to maintain their codebase. If users cannot reproduce their analyses outside of the application, it prevents them from modifying analyses to suit their particular use-case, makes it harder to understand the analysis and limits their ability to use the results in publications. Additionally, it may not be possible to determine which R packages are being used in the application, making it more onerous to cite the packages in publications. Other packages exist for creating templates of shiny apps, e.g. `golem` and `rhino` but these are not geared towards use by academics.

*Wallace* addressed these shortcomings and the attributes of *SMART* are built open those of Wallace. Apps built using *SMART* should maintain these characteristics:

* **accessible**: lowers barriers to implementing complex modular `shiny` apps for scientific analysis
* **open**: the code is free to use and modify (GPL 3.0)
* **expandable**: users can author and contribute modules that enable new methodological options
* **flexible**: options for user uploads and downloads of results
* **interactive**: includes an embedded zoomable `leaflet` map, sortable `DF` data tables, and visualizations of results
* **instructive**: features guidance text that educates users about theoretical and analytical aspects of each step in the workflow
* **reproducible**: users can download an `rmarkdown` .Rmd file that when run reproduces the analysis, ability to save sessions and load later
* **robust**: modules and their underlying functions are tested using `testthat` and `shinytest2`

## Use cases
SMART is aimed towards creating applications for complex analyses that have several steps and where there may be multiple options for each step e.g. where the data is sourced from, which model is used or how the results are plotted. It is probably not suitable for use if you have never developed a shiny app before, but if you have developed a simple app which is growing in complexity, it should be fairly straightforward to migrate your code across. 

## Using SMART as a template

### License
SMART is licensed under the GPLv3 license and consequently any apps made using SMART must be licensed under the same license. 

### Initialisation
The `init` function can be used to create the template for a new app. For example, the following call will produce a folder called `demo` in your Documents folder and create an app containing two components (load and plot) each containing two modules. You can choose whether certain features are included in the overall app by setting the `include_` parameters and also whether each module contains mapping, result, rmarkdown and save functionality by setting the parameters inside the `modules` dataframe. `common_objects` contains a list of the objects which will be shared between modules and will be available inside all of the modules as e.g. `common$raster`.

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

SMART::init(path = "~/Documents", name = "demo", author = "Simon E. H. Smart",
include_map = TRUE, include_table = TRUE, include_code = TRUE, common_objects = common_objects, modules = modules)
```

### Installation
`init` creates the file structure of a package and to install it, run `devtools::install_local(path = "~/Documents/demo", force=TRUE)` (assuming as in the example above the app was initiated in `~/Documents/demo`). You need to repeat this process after making changes to the app. Now you can run the app using `shiny::runApp(system.file('shiny',package='demo'))`.

### Development
#### Modules
After installing the initial version, the modules only contain skeleton code. There are four files for each module located in `/inst/shiny/modules` and each module calls a function found in `/R`. It may be helpful to familiarise yourself with the code for the existing application either by viewing the files in `/inst/shiny/modules` or by using the Code tab in the app.

##### .R

This is the main module file and contains the UI and server components as well as any other functionality specified at initialisation. 

The `_module_ui` function can be developed just like a normal UI function inside a shiny app, but only contains *Input elements and the input ids need wrapping inside `ns()` to create ids that are unique to the module. The template contains an `actionButton` which when clicked runs the code inside the `_module_server` function. If the computations performed by the module are simple, then you could choose to remove the `actionButton` in the UI and the `observeEvent` so that the server runs reactively whenever the inputs are changed.

The `_module_server` function contains an `observeEvent` which is run when the `actionButton` in the UI is clicked. Inside the `observeEvent` there is a consistent structure to the code:

* In the *warning* block, examine inputs to check that they are as expected and issue warnings if not using `common$logger %>% writeLog()` See the documentation of `SMART::writeLog()` for more details.
* In the *function call* block, pass the inputs to the module function.
* In the *load into common* block, store the result(s) of the function call in the relevant `common` object.
* In the *metadata* block, store any relevant input metadata which is required to reproduce the function call in the `common$meta` object.
* In the *trigger* block, `gargoyle::trigger()` is called which can be used to trigger actions elsewhere in the module or app using `gargoyle::watch()`. This should not need editing.
* In the *result* block, use the relevant `input` values or `common` objects to produce `render*` objects which will be passed to the `_module_result` function.
* In the *return* block, the current `input` values can be stored as a `list` inside the `save` function e.g. `select_date = input$date` when the app is saved and then retrieved when the app is loaded using various `updateInput` functions inside the `load` function e.g. `updateSelectInput(session, "date", selected = state$select_date`).

The `_module_result` function contains the `*Output` functions which would normally be included in the UI function. As in the `_module_ui` function, the object ids need wrapping inside `ns()`.

The `_module_map` function updates the `leaflet` map. `map` is a `leafletProxy` object created in the main server function so leaflet functions can be piped to it e.g. `map &>& addRasterImage()` 

The `_module_rmd` function creates a list of objects which are passed to the module's .Rmd file to reproduce the analysis. The first `_knit` object is a boolean used to control whether or not the module has been used and therefore whether the markdown should be included in the user's markdown. If the object to be passed over is a vector, then it should be wrapped in `printVecAsis()` which converts it to a string so that it can be knitted into the .Rmd.

##### .Rmd
This is a template for the rmarkdown that can be used to reproduce the module. Objects from `_module_rmd` are passed into this template when the user downloads the rmarkdown. Objects from the `_module_rmd` function are passed into the template when the document is knitted. If `module_setting` is added to the list in `_module_rmd` then the value will be substituted for `{{module_setting}}` inside the .Rmd. If `module_setting` is a string, then you need to use `"{{module_setting}}"` inside the .Rmd.

##### .md
This is a guidance document to explain the theoretical background behind the module and how it has been implemented. 

##### .yml
This is a configuration file used when the modules are loaded. Add any R packages used inside the module or the function that it calls to `package` so that they can be cited. Package names should be included as plain text rather than as strings e.g. `package: [dplyr,shiny]`. The `short_name` field is used to generate the UI for selecting which module to use. By default it uses the `module` column of the `modules` dataframe but you may wish to edit this for clarity.

##### .R function
This function performs the computation of the module. Creating this function separately to the shiny functionality is advantageous because it is easier to test and because it can be called from inside the .Rmd file. Messages can be posted to the log from inside these functions if it is passed `common$logger` - see `/R/select_query.R` for an example.

#### Components
Each component has a skeleton guidance document located in `inst/shiny/Rmd` e.g. `gtext_plot.Rmd` which you should use to describe the functionality of the component in general and also include any relevant references. 

#### server.R and ui.R
These should not require substantial editing unless you wish to change the layout/appearance of the app. One exception is the block of code in `server.R` that creates the table because this is shared between modules. If your app uses `terra` objects, they need to be wrapped and unwrapped using `terra::wrap()` and `terra::unwrap()` when they are saved and loaded (see the `server.R` file of this repository for an example).  

### Notes for Windows users

#### PDF download of session code
If PDF downloading of session code is not working for you, please follow the following instructions, taken from <a href="https://github.com/rstudio/shiny-examples/issues/34" target="_blank">here</a>:
     - Step 1: Download and Install MiKTeX from http://miktex.org/2.9/setup
     - Step 2: Run `Sys.getenv("PATH")` in R studio. This command returns the path where Rstudio is trying to find pdflatex.exe. In Windows (64-bit), it should return "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe". If pdflatex.exe is not located in this location Rstudio gives this error code 41.
     - Step 3: To set this path variable run: `Sys.setenv(PATH=paste(Sys.getenv("PATH"),"C:/Program Files/MiKTeX 2.9/miktex/bin/x64/",sep=";"))`.

#### Only for Github installation
If you are using Windows, please download and install <a href="https://cran.r-project.org/bin/windows/Rtools/" target="_blank">RTools</a> before installing the `devtools` package. After you install RTools, please make sure you add "C:\Rtools\bin" to your PATH variable (instructions <a href="https://stackoverflow.com/questions/29129681/create-zip-file-error-running-command-had-status-127/29480538#29480538" target="_blank">here</a>). Additionally, when using `devtools` on Windows machines, there is a known <a href="https://github.com/r-lib/devtools/issues/1298" target="_blank">bug</a> that sometimes results in the inability to download all package dependencies. If this happens to you, please install the packages and their dependencies directly from CRAN.
