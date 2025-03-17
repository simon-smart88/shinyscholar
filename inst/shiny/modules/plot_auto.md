### **Module: Plot histogram automatically**

**BACKGROUND**

This module plots the values of the raster image as a histogram, but unlike for the **Plot histogram** module, this module runs automatically 
after any of the select component modules is run or when the input values are updated. To be included in the reproducible markdown, the 
plot produced by the module must be viewed by the user.

**IMPLEMENTATION**

The raster image is passed to `plot_hist()` which extracts the values using `terra::values()` and returns them to be plotted with `hist()`. 
The number of bins in the histogram can be selected by the user. 


