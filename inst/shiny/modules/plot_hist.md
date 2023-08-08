### **Module: Plot histogram**

**BACKGROUND**

This module plots the values of the raster image as a histogram.

**IMPLEMENTATION**

The raster image is passed to `plot_hist()` which extracts the values using `terra::values()` and returns them to be plotted with `hist()`. The number of bins in the histogram can be selected by the user.
