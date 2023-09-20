# SMART (v1.0.0)
SMART (Shiny Modular Academic Reproducible Template) is a basic application written in R that can be used as a template to create complex applications that are modular and can be reproduced outside of the application. *SMART* was forked from *Wallace*, a modular platform for reproducible modeling of species niches and distributions and we are very grateful to the contributors of that package. The features retained from *Wallace* and the new features added in *SMART* are described in `NEWS`.

*SMART* contains two components (Select, Plot, Reproduce) each of which contain two modules (`select_query`, `select_user`, `plot_hist`, `plot_scatter`, `rep_markdown` and `rep_refPackages`) and their code is found in the `inst/shiny/modules` directory. Each of the modules in the Select and Plot components calls a function with the same name that is found in the `R` directory. The `select_query` module and underlying function is the most complex, containing various components for handling errors, both in the module and in the function. The other modules are very simple but added to demonstrate how multiple components and modules can be used.

Install *SMART* via Github and run the application with the following R code.

```R
install.packages("devtools")
devtools::install_github("simon-smart88/SMART")
library(SMART)
run_smart()
```

An individual module can be run using `module_tester()` e.g. `module_tester("select_query")`

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
