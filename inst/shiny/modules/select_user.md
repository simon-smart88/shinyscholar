### **Module: Upload data**

**BACKGROUND**

This module allows the user to upload their own raster image (`.tif`) and plots it on the map.

**IMPLEMENTATION**

The file is uploaded to the shiny server using `shiny::fileInput()` and the path is then passed to `select_user()` which loads the data using `terra::rast()`.



