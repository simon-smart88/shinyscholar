#' @title select_query
#' @description
#' This function is called by the select_query module and loads an
#'  FCover raster for the selected area.
#'  @param extent SpatExtent object of the area
#'  @param date character. Date of image to load
#'  @examples
#'  \dontrun{
#'  extent <- c(43,50,-26,-12)
#'  date <- '2023-06-20'
#'  ras <- select_query(extent,date)
#'  }
#' @return a SpatRaster object
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

select_query <- function(poly,date,logger) {

poly <- terra::vect(poly,crs="+init=EPSG:4326",type='polygons')
area <- terra::expanse(poly,unit='km')
if (area > 3000) {
  logger %>% writeLog(type = 'error', glue::glue("Your selected area is too large ({round(area,0)} km2) when the maximum is 3000 km2. Please select a smaller area"))
  return()
}
extent <- terra::ext(poly)

#convert the extent into a bounding box
bbox <- paste(as.character(extent[3]),as.character(extent[1]),as.character(extent[4]),as.character(extent[2]),sep=',')

#add date and bbox to the url
url <- glue::glue('/vsicurl/https://viewer.globalland.vgt.vito.be/geoserver/wms?SERVICE=WMS&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image/geotiff&LAYERS=CGLS:fcover300_v1_333m&TILED=true&TIME={date}T00:00:00.000Z&WIDTH=1000&HEIGHT=1000&CRS=EPSG:4326&BBOX={bbox}')

#request the data
raster_image <- terra::rast(url)

#remove missing values and rescale data to 0-100%
raster_image <- terra::clamp(raster_image, upper=250, value=FALSE)/2.5
return(raster_image)
}
