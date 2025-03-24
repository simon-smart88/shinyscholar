### **Module: Plot histogram semi-automatically**

**BACKGROUND**

This module plots the values of the raster image as a histogram, but unlike for the **Plot histogram** module, once the module has been run once, 
changes to the inputs automatically rerun the module rather than requiring the button to be pressed again.

**IMPLEMENTATION**

The raster image is passed to `plot_hist()` which extracts the values using `terra::values()` and returns them to be plotted with `hist()`. 
The number of bins in the histogram can be selected by the user. 


