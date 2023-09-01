#' @title select_query
#' @description
#' This function is called by the select_query module and loads an
#'  FCover raster for the selected area.
#'  @param extent SpatExtent object of the area
#'  @param date character. Date of image to load
#'  @examples
#'  \dontrun{
#'  poly <- matrix(c(0, 0, 0.5, 0.5, 0, 52, 52.5, 52.5, 52, 52), ncol=2)
#'  colnames(poly) <- c("longitude", "latitude")
#'  date <- "2023-06-20"
#'  ras <- select_query(poly, date)
#'  }
#' @return a SpatRaster object
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

select_query <- function(poly, date, logger = NULL) {
  #convert to terra object to calculate area and extent
  terra_poly <- terra::vect(poly, crs = "+init=EPSG:4326", type = "polygons")
  area <- terra::expanse(terra_poly, unit = "km")
  if (area > 3000) {
    logger %>% writeLog(type = "error", glue::glue("Your selected area is too large ({round(area,0)} km2) when the maximum is 3000 km2. Please select a smaller area"))
    return()
  }
  extent <- terra::ext(poly)

  #convert the extent into a bounding box
  bbox <- paste(as.character(extent[3]), as.character(extent[1]),
                as.character(extent[4]), as.character(extent[2]), sep = ",")

  #calculate polygon height and width
  #extract geometry
  top_left <- sf::st_point(c(poly[1,2],poly[1,1]))
  top_right <- sf::st_point(c(poly[2,2],poly[2,1]))
  bottom_left <- sf::st_point(c(poly[4,2],poly[4,1]))

  #create sf object
  geom <- sf::st_sf(geometry = sf::st_sfc(top_left, top_right, bottom_left))
  #set crs and transform to metres
  sf::st_crs(geom) <- 4326
  geom <- sf::st_transform(geom, crs=32632)
  #calculate distances
  width <- sf::st_distance(geom$geometry[1], geom$geometry[3])
  height <- sf::st_distance(geom$geometry[1], geom$geometry[2])
  #convert to 333 m pixels
  height <- as.numeric(round(height / 333, 0))
  width <- as.numeric(round(width / 333, 0))

  #add date, width, height and bbox to the url
  url <- glue::glue("/vsicurl/https://viewer.globalland.vgt.vito.be/geoserver/wms?SERVICE=WMS&SERVICE=WMS&VERSION=1.3.0&REQUEST=GetMap&FORMAT=image/geotiff&LAYERS=CGLS:fcover300_v1_333m&TILED=true&TIME={date}T00:00:00.000Z&WIDTH={width}&HEIGHT={height}&CRS=EPSG:4326&BBOX={bbox}")

  #request the data
  raster_image <- terra::rast(url)

  #count missing values and log accordingly
  missing_values <- length(values(raster_image)[values(raster_image) == 254])
  if (missing_values == length(values(raster_image))) {
    logger %>% writeLog(type = "error", glue::glue("No data was found for your selected area. This could be due to cloud coverage or because the area is not over land."))
    return()
  }
  logger %>% writeLog(glue::glue("{missing_values} pixels were removed due to cloud coverage."))

  #remove missing values and rescale data to 0 - 100 %
  raster_image <- terra::clamp(raster_image, upper = 250, value = FALSE) / 2.5
  return(raster_image)
}
