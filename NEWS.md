shinyscholar 1.0.0
=============
- The template has been created mainly through the removal of functionality from `Wallace` and the addition of basic functionality to demonstrate how modules can be used. 
- These are the key features which have been retained:
1. Automatic loading of modules
2. Saving and loading of the current app state
3. Creating Rmarkdown files for reproducing the workflow outside of the application
4. Logging errors 

- These changes have been made:
1. `common` - the data structure passed between modules - has been changed from a `list()` containing `spp <- reactiveValues()` to an `R6::R6Class()`.
2. Due to objects inside `common` not being inherently reactive, event triggers have been added using `{gargoyle}`
3. A Code tab has been added to the Visualization panel to allow the code for each module and the function that each module calls to be viewed.
4. Unit tests for each module have been created using `{shinytest2}` in addition to unit tests for the function that the module calls.
5. Added a new function `run_module()` which can be used to run a single module.
6. Added a new function `create_template()` which can be used to create a skeleton app.
7. Added a Dockerfile which can be used to run the app on a shiny-server.
8. Added `show_loading_modal()` which uses `{shinybusy}` to display a modal whilst slow functions are running.
