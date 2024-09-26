### **Query raster:**

**BACKGROUND**

Fraction of Absorbed Photosynthetically Active Radiation (FAPAR) is a biophysical measurement corresponding to the percentage of sunlight that is absorbed green vegetation. The data is measured by the <a href="https://en.wikipedia.org/wiki/Moderate_Resolution_Imaging_Spectroradiometer" target="_blank">MODIS sensors</a> on NASA’s <a href="https://en.wikipedia.org/wiki/Terra_(satellite)" target="_blank">Terra</a> and <a href="https://en.wikipedia.org/wiki/Aqua_(satellite)" target="_blank">Aqua</a> satellites. The image resolution is 500m it is a composite of data collected by both satellites over an 8 day period.

**IMPLEMENTATION**

Draw a polygon on the map over land, select a date and click *Load imagery* and the data will become visible on the map. You can chose a random location to draw the polygon by clicking the *Pick a random location* button. The maximum permitted area of the polygon is set to 1 million km<sup>2</sup> and selecting a larger polygon will return an error.

Data are obtained from NASA via the Level-1 and Atmosphere Archive & Distribution System (LAADS) Distributed Active Archive Center (DAAC) via an API call to retrieve available imagery as `.hdf` files e.g. https://ladsweb.modaps.eosdis.nasa.gov/api/v2/content/archives?products=MCD15A2H&temporalRanges=2023-06-20&regions=[BBOX]W10%20N55%20E5%20S50 and these are downloaded and the `Fpar_500m` layer is extracted, merged and cropped to the selected area by `{terra}` functions.

Areas that are permanent water, urban areas are returned as missing values and other reasons also result in missing values. Information on the missing values present in the selected area are logged in the logger.

If you are running *shinyscholar* locally, a NASA bearer token is required to download the data. <a href = "https://urs.earthdata.nasa.gov/" target="_blank">Register for free here</a> and then <a href = "https://wiki.earthdata.nasa.gov/pages/viewpage.action?pageId=204802786" target="_blank">follow these instructions</a> to obtain one. You can then enter it in the box or create environmental variables called 'NASA_username' and 'NASA_password' to enable the app to fetch a token automatically.

**REFERENCES**

* <a href="https://lpdaac.usgs.gov/products/mcd15a2hv061/" target="_blank">MCD15A2H product guide</a>
* <a href="https://ladsweb.modaps.eosdis.nasa.gov/tools-and-services/api-v2/specs/content" target="_blank">LAADS DAAC API documentation</a>
