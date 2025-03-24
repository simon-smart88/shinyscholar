shinyscholar 0.1.0
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
5. ~~Added a new function `run_module()` which can be used to run a single module.~~ Removed in 0.2.2 use `run_<app name>()` or `load_file_path`
6. Added a new function `create_template()` which can be used to create a skeleton app.
7. Added a Dockerfile which can be used to run the app on a shiny-server.
8. Added `show_loading_modal()` which uses `{shinybusy}` to display a modal whilst slow functions are running.

shinyscholar 0.1.1
=============
- Added `save_and_load()` to automate adding the lines to modules which facilitate saving and loading of input values.
- Added an introduction using `{rintrojs}` which is only shown to users on their first visit.

shinyscholar 0.1.2
=============
- Moved mapping, introduction, code, save and load functionality out of server into `core_` modules.
- Passed `parent_session` to the modules enabling switching to the results, map and table tab from within modules and added `show_table()`, `show_results()` and `show_table()` to simplify code.
- Added `rep_renv` module to enable capturing dependencies.

shinyscholar 0.2.0
=============
- Added ability to run functions asynchronously using `shiny::ExtendedTask()`.
- Modules that do not produce results now have a placeholder informing the user.
- Updated `writeLog()` to use icons for different events.
- Updated `save_and_load()` to ignore manually added lines and fix indenting.
- Added `metadata()` to semi-automate adding code for reproducibility.
- Module function file names now take the form of `<identifier>_f.R` to prevent confusion between the function and module file.
- Objects are all passed to `printVecAsis()` when generating the Rmarkdown, removing the need to manually wrap strings in the `.Rmd` files.
- Use `{shinyAce}` to display formatted code in `core_code` module.

shinyscholar 0.2.1
=============
- The `select_query` and `select_async` modules in the demonstration app have been re-written to use a different API.

shinyscholar 0.2.2
=============
- Removed `run_module()` as it was not maintainable.
- Moved all packages to Suggests unless they are required for development of new applications.
- Added `asyncLog()` to improve logging from inside async functions.
- Updated `run_<app name>()` to take a load file as an argument which is loaded automatically.
- Creating `load_file_path` containing the path to a save file will attempt to load it on app start up.
- Made `create_template()`, `metadata()` and `save_and_load()` more robust.

shinyscholar 0.2.3
=============
- Fixed bug caused by being on CRAN
- Fixed bug in module ordering in `global.R`

shinyscholar 0.2.4
=============
- Simplified and improved `printVecAsis()` by using `dput` to support improved reproducibility e.g. by including dataframes directly
- Removed all remnants of map when `include_map` is `FALSE` in `create_template()`
- Install packages created by `create_template()` in tests
- Only run markdown tests when pandoc is installed

shinyscholar 0.2.5
=============
- Fix bug in writeLog when `type = warning`
- Skip tests that download files on Fedora systems
- Module `run` buttons can be pressed using the Enter key

shinyscholar 0.3.0
=============

### Bug fixes
- Fixed `core_code` module when no function exists
- Break up very long lines in the markdown so that they can be read in again
- Disabled `register_module()` as it has not been refactored to work for created apps 
- Made loading process more robust by adding the app name 
- Made loading fault-tolerant if deprecated `common` objects exist

### Changes
- Tidied up `library()` calls
- Removed unnecessary `gargoyle::` and `leaflet::` scoping 

### New features
- Entries in the logger are now restored on load and made available in testing
- Added `plot_auto` and `plot_semi` modules to the example app that run automatically and semi-automatically respectively
- Added ability to control generated markdown chunks using `asis` chunks and example to `plot_hist.Rmd`
- Added `common$reset()` and `reset_data()` to reset the `common` object and remove all outputs
- Added an area to the UI for including global options available inside all modules
- Added an options to `create_template()` and `create_module()` to include a `downloadButton` and `downloadHandler` to modules that is only visible once the module runs successfully
- Rewrote `create_template()` and `create_module()` so that `create_module()` creates the module function and tests
- Switched to use `shinyWidgets::radioGroupButtons()` for module selection menu
- Added a description of the package structure to the README

