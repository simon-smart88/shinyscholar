
select_query <- function(extent,date) {
bbox <- c(as.character(extent[3]),as.character(extent[1]),as.character(extent[4]),as.character(extent[2]))
#bbox <- '-26,43,-11,51'

url <- glue('/vsicurl/https://viewer.globalland.vgt.vito.be/geoserver/wms?SERVICE=WMS&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image/geotiff&LAYERS=CGLS:fcover300_v1_333m&TILED=true&TIME={date}T00:00:00.000Z&WIDTH=2560&HEIGHT=2560&CRS=EPSG:4326&BBOX={bbox}')
ras <- rast(globalland_url)
return(ras)
}
