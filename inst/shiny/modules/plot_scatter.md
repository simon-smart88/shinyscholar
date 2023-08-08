### **Module: Plot scatterplot**

**BACKGROUND**

This module plots a sample of the values of the raster image as a scatterplot against either latitude or longitude.

**IMPLEMENTATION**

The raster image is passed to `plot_scatter()` which extracts a sample of values using `terra::spatSample(method='random)` and returns them to be plotted with `plot()`. The number of points sampled and whether the data is plotted against latitude or longitude can be selected by the user.

