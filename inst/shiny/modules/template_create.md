### **Module: Create template app**

#### License
Shinyscholar is licensed under the GPLv3 license and consequently any apps made using the template must be licensed under the same license. 

**INSTRUCTIONS**

This module allows you to create and download a template for your own application using the `create_template` function. 

* Name - this is the name of the application and of the package. It should only contain letters and be careful that you don't choose a name for a package that you have already installed.
* Components - these are names of the tabs at the top of the application. They should be single words separated by commas. The Intro and Reproduce tabs will be added automatically.
* Long components - these are longer descriptive names of the components used to generate some of the user interface. 
* Modules for each component - these boxes appear once you have completed the components. These are the options available inside each component. Enter a list of modules for each component, separated by commas.
* Long modules for each component - As for the long components, these are longer descriptions of the modules and used to generate the user interface.
* Include map tab? - Whether to include the map tab in the results panel.
* Include table tab? - Whether to include the table tab in the results panel.
* Include code tab? - Whether to include the code tab in the results panel.
* Options for each module - Whether each module should have map, results, rmarkdown and save functionality and whether the module should run asynchronously.
* Common objects - These are the names of data structures that are shared between modules. The structures: meta, logger, state, and poly and used internally and an error will be returned if you try to use these again
* Author - your name.

The app checks that the lengths of the components and long components and the lengths of the modules and long modules match and prints errors if they do not. Other errors are caught by the function and reported in the logger. 

Once all the fields are filled in and validated, the Download! button will appear below the boxes and clicking it will generate a .zip file. After extracting that file, navigate into the folder, and run `devtools::install_local()` to install the package and then you can run the app using `<name>::run_<name>`.

Information on how to develop the app can be found in the <a href="https://github.com/simon-smart88/shinyscholar/blob/master/README.md" target="_blank">project's README</a>
