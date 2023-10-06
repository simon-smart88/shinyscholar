### **Query raster:**

**BACKGROUND**

Fraction of Vegetation Cover (FCover) is a biophysical measurement corresponding to the percentage of land covered by green vegetation. The data is obtained from the Copernicus Global Land Service and is measured by the OLCI instrument on [Sentinel-3](https://en.wikipedia.org/wiki/Sentinel-3#OLCI) satellites and the [PROBA-V](https://en.wikipedia.org/wiki/PROBA-V) satellite, both operated by the European Space Agency. The image resolution is 333m but the resolution returned by this module will vary depending on the selected area. Images are a composite of data collected over a 10 day period.

**IMPLEMENTATION**

Draw a polygon on the map over land, select a date and click run and the data will become visible on the map. The maximum permitted area of the polygon is set to 10000 km<sup>2</sup> and selecting a larger polygon will return an error.

Data are obtained from Copernicus via a GeoServer Web Map Service e.g. https://viewer.globalland.vgt.vito.be/geoserver/wms?SERVICE=WMS&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image/geotiff&LAYERS=CGLS:fcover300_v1_333m&TILED=true&TIME=2023-01-10T00:00:00.000Z&WIDTH=2560&HEIGHT=2560&CRS=EPSG:4326&BBOX=-26,43,-11,51'

**REFERENCES**

* https://land.copernicus.eu/global/products/fcover
