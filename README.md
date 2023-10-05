# SMART (v1.0.0)
SMART (Shiny Modular Academic Reproducible Template) is a basic application written in R that can be used as a template to create complex applications that are modular and can be reproduced outside of the application. *SMART* was forked from *Wallace*, a modular platform for reproducible modeling of species niches and distributions and we are very grateful to the contributors of that package. The features retained from *Wallace* and the new features added in *SMART* are described in `NEWS`.

*SMART* contains two components (Select, Plot, Reproduce) each of which contain two modules (`select_query`, `select_user`, `plot_hist`, `plot_scatter`, `rep_markdown` and `rep_refPackages`) and their code is found in the `inst/shiny/modules` directory. Each of the modules in the Select and Plot components calls a function with the same name that is found in the `R` directory. The `select_query` module and underlying function is the most complex, containing various components for handling errors, both in the module and in the function. The other modules are very simple but included to demonstrate how multiple components and modules can be used.

Install *SMART* via Github and run the application with the following R code.

```R
install.packages("devtools")
devtools::install_github("simon-smart88/SMART")
library(SMART)
run_smart()
```

An individual module can be run using `module_tester()` e.g. `module_tester("select_query")`

## Using SMART as a template
### Initialisation
The `init` function can be used to create the template for a new app. For example, the following call will produce a folder called `demo` in your Documents folder and create an app containing two components (load and plot) each containing two modules. You can choose whether certain features are included in the overall app by setting the `include_` parameters and also whether each module contains mapping, result, rmarkdown and save functionality by setting the parameters inside `modules`. `common_objects` contains a list of the objects which will be shared between modules and will be available inside all of the modules as e.g. `common$raster`.

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
After installing the initial version, the modules only contain skeleton code. There are four files for each module located in `demo/inst/shiny/modules` and each module calls a function found in `demo/R`:

##### .R

This is the main module file and contain the UI and server components as well as any other functionality specified at initialisation. The `_module_ui` function can be developed just like a normal UI function inside a shiny app, but function only contains input elements and the input ids need encapsulating inside `ns()` to create ids which are unique to the module. By default, all the modules contain an `actionButton` which runs code inside an `observeEvent` in the `_module_server` function, but depending on your use case you may wish to remove this. Inside the `observeEvent` there is a consistent structure to the code:

* In the *warning* block, examine inputs to check that they are as expected and issue warnings if not using `common$logger %>% writeLog()` See the documentation of `SMART::writeLog()` for more details.
* In the *function call* block, pass the inputs to the module function.
* In the *load into common* block, store the result(s) of the function call in the relevant `common` object.
* In the *metadata* block, store any relevant input metadata which is required to reproduce the function call in the `common$meta` object.
* In the *trigger* block, `gargoyle::trigger()` is called can be used to trigger later actions. This should not need editing.
* In the *result* block, use the relevant `input` values or `common` objects to produce `render` objects which will be passed to the `_module_result` function.
* In the *return* block, the current `input` values can be stored as a `list` inside the `save` function e.g. `select_date = input$date` when the app is saved and then retrieved when the app is loaded using various `updateInput` functions inside the `load` function e.g. `updateSelectInput(session, "date", selected = state$select_date`).

The `_module_result` function contains the `Output` functions which would normally be included in the UI function. As in the `_module_ui` function, the object ids need encapsulating inside `ns()`.

The `_module_map` function updates the `leaflet` map. `map` is a `leafletProxy` object created in the server file so leaflet functions can be piped to it e.g. `map &>&` 

The `_module_rmd` function creates a list of objects which are passed to the module .Rmd file in order to reproduce the analysis. The first `_knit` object is used to control whether or not the module has been used and therefore whether the markdown should be included in the user's markdown. If the object to be passed over is a vector, then it should be wrapped in `printVecAsis` which converts it to a string so that it can be knitted into the .Rmd.

##### .Rmd
This is a template for the rmarkdown that can be used to reproduce the module. Objects from `_module_rmd` are passed into this template when the user downloads the rmarkdown. 

##### .md
This is a guidance document to explain the theoretical background behind the module and how it has been implemented. 

##### .yml
This is a configuration file used when the modules are loaded, and the only field which should require editing is  `package` which is used to list any packages which the module uses so that they can be cited. Note that the package names should be included as plain text rather than as strings e.g. `package: [dplyr,shiny]`

##### .R function
This function should contain the actual computation of the module. Creating this function separately to the shiny functionality is advantageous because it is easier to test and because it can be called from inside the .Rmd file.

#### Components
Each component has a skeleton guidance document located in `inst/shiny/Rmd` e.g. `gtext_plot` which you should use to describe the functionality of the component in general and also include any relevant references. 

### Before using *SMART*

#### Update R and RStudio versions
Please make sure you have installed the latest versions of both R (<a href= "https://cran.r-project.org/bin/macosx/" target="_blank">Mac OS</a>, <a href= "https://cran.r-project.org/bin/windows/base/" target="_blank">Windows</a>) and RStudio (<a href= "https://posit.co/download/rstudio-desktop/" target="_blank">Mac OS /  Windows</a>: choose the free version).

#### Problems viewing tables
If for some reason you are unable to view the tables in *SMART*, please install (force if necessary) the development version of `htmlwidgets` by running this code: `devtools::install_github("ramnathv/htmlwidgets")`. You should be able to view tables now.

#### Windows Users: PDF download of session code
If PDF downloading of session code is not working for you, please follow the following instructions, taken from <a href="https://github.com/rstudio/shiny-examples/issues/34" target="_blank">here</a>:
     - Step 1: Download and Install MiKTeX from http://miktex.org/2.9/setup
     - Step 2: Run `Sys.getenv("PATH")` in R studio. This command returns the path where Rstudio is trying to find pdflatex.exe. In Windows (64-bit), it should return "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe". If pdflatex.exe is not located in this location Rstudio gives this error code 41.
     - Step 3: To set this path variable run: `Sys.setenv(PATH=paste(Sys.getenv("PATH"),"C:/Program Files/MiKTeX 2.9/miktex/bin/x64/",sep=";"))`.

#### Windows Users: Only for Github installation
If you are using Windows, please download and install <a href="https://cran.r-project.org/bin/windows/Rtools/" target="_blank">RTools</a> before installing the `devtools` package. After you install RTools, please make sure you add "C:\Rtools\bin" to your PATH variable (instructions <a href="https://stackoverflow.com/questions/29129681/create-zip-file-error-running-command-had-status-127/29480538#29480538" target="_blank">here</a>). Additionally, when using `devtools` on Windows machines, there is a known <a href="https://github.com/r-lib/devtools/issues/1298" target="_blank">bug</a> that sometimes results in the inability to download all package dependencies. If this happens to you, please install the packages and their dependencies directly from CRAN.

#### Any other problems with install_github()
Although the recommended way to install is through CRAN, if you are trying to install the Github version and are having problems, follow these steps.
 1. Download the zip file from the repository page.
 2. Unzip and open the SMART.Rproj file in RStudio.
 3. In the right-hand pane, click Build, then Install & Restart.
 4. Type `run_smart()` in the console and press Enter.
