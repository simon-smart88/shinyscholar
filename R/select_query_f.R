#' @title Fetch a token from the NASA Earthdata API
#' @description Uses the Earthdata API to fetch a token using the user's
#' username and password
#' @param username character. NASA Earthdata username
#' @param password character. NASA Earthdata password
#' @return A character string containing the token
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

get_nasa_token <- function(username, password) {

  stopifnot("username must be a character string" = inherits(username, "character"))
  stopifnot("password must be a character string" = inherits(password, "character"))

  token_url <- "https://urs.earthdata.nasa.gov/api/users/find_or_create_token"
  req <- httr2::request(token_url)

  response <- tryCatch(
    req %>%
      httr2::req_auth_basic(username, password) %>%
      httr2::req_method("POST") %>%
      httr2::req_perform(),
    httr2_http_401 = function(cnd){stop("Incorrect username or password", call. = FALSE)}
  )

  if (httr2::resp_status(response) == 200){
    body <- response %>% httr2::resp_body_json()
    token <- body$access_token
    return(token)
  } else {
    stop("Something went wrong when trying to retrieve the token")
  }
}

#' @title Load FAPAR data from NASA
#' @description Called by the select_query module in the example app and loads an
#'  FAPAR raster for the selected area via the Earthdata API.
#' @param poly matrix. Coordinates of area to load
#' @param date character.  Date of image to load in `YYYY-MM-DD` format.
#' @param token character. NASA Earthdata API token.
#' \href{https://urs.earthdata.nasa.gov/}{Click here}
#' to register and then
#' \href{https://wiki.earthdata.nasa.gov/pages/viewpage.action?pageId=204802786}{follow these instructions}
#' to obtain one. Alternatively supply your username and password to
#' `get_nasa_token()`
#' @param logger Stores all notification messages to be displayed in the Log
#'   Window. Insert the logger reactive list here for running in
#'   shiny, otherwise leave the default NULL
#' @examples
#' \dontrun{
#'  if (check_suggests(example = TRUE)) {
#'    poly <- matrix(c(0.5, 0.5, 1, 1, 0.5, 52, 52.5, 52.5, 52, 52), ncol = 2)
#'    colnames(poly) <- c("longitude", "latitude")
#'    date <- "2023-06-20"
#'    token <- get_nasa_token(username = "<username>", password = "<password>")
#'    ras <- select_query(poly, date, token)
#'  } else {
#'    message('reinstall with install.packages("shinyscholar", dependencies = TRUE)
#'    to run this example')
#'  }
#'  }
#' @return a SpatRaster object
#' @author Simon Smart <simon.smart@@cantab.net>
#' @export

select_query <- function(poly, date, token, logger = NULL) {

  check_suggests()

  if (!("matrix" %in% class(poly))){
    logger %>% writeLog(type = "error","poly must be a matrix")
    return()
  }

  if (!is.character(date) || is.na(as.Date(date, format = "%Y-%m-%d"))) {
    logger %>% writeLog(type = "error","date must be a string with the format YYYY-MM-DD")
    return()
  }

  if (nchar(token) < 200 || is.null(token)){
    logger %>% writeLog(type = "error", "This function requires a NASA token - see the documentation")
    return()
  }

  # convert to terra object to calculate area and extent
  terra_poly <- terra::vect(poly, crs = "EPSG:4326", type = "polygons")
  area <- terra::expanse(terra_poly, unit = "km")
  if (area > 1000000) {
    logger %>% writeLog(type = "error", paste0("Your selected area is too large (",round(area,0)," km2)",
                                              " when the maximum is 1m km2. Please select a smaller area"))
    return()
  }

  bbox <- c(min(poly[,1]), max(poly[,2]), max(poly[,1]), min(poly[,2]))

  search_url <- glue::glue("https://ladsweb.modaps.eosdis.nasa.gov/api/v2/content/archives?products=MCD15A2H&temporalRanges={date}&regions=[BBOX]W{bbox[1]}%20N{bbox[2]}%20E{bbox[3]}%20S{bbox[4]}")
  check <- check_url(search_url)

  if (!is.null(check)){
    image_req <- httr2::request(search_url ) %>%
                  httr2::req_auth_bearer_token(token) %>%
                  httr2::req_perform()

    image_resp <- image_req %>% httr2::resp_body_html()

    image_links <- xml2::xml_find_all(image_resp, "//a")
    image_urls <- xml2::xml_attr(image_links, "href")
  } else {
    logger %>% writeLog(type = "error", "The FAPAR API is currently offline")
    return()
  }

  # download and stitch together tiles
  raster <- NULL
  for (file in image_urls){
    if (tools::file_ext(file) == "hdf"){
      req <- httr2::request(file) %>%
        httr2::req_auth_bearer_token(token) %>%
        httr2::req_perform()

      temp <- tempfile(fileext = ".hdf")
      writeBin(httr2::resp_body_raw(req), temp)

      tile <- terra::rast(temp)$Fpar_500m
      if (is.null(raster)){
        raster <- tile
      } else {
        raster <- terra::merge(raster, tile)
      }
    }
  }

  if (is.null(raster)){
    logger %>% writeLog(type = "error", paste0("No data was found for your selected area. ",
                                               "This could be due to cloud coverage or because the area is not over land."))
    return()
  }

  # reproject and crop
  raster <- terra::project(raster, "EPSG:4326")
  raster <- terra::crop(raster, terra_poly)

  # count missing values and log accordingly
  missing_values <- length(terra::values(raster)[terra::values(raster) > 1])
  urban <- length(terra::values(raster)[terra::values(raster) == 2.5])
  water <- length(terra::values(raster)[terra::values(raster) == 2.54])

  if (missing_values == terra::ncell(raster)) {
    logger %>% writeLog(type = "error", paste0("No data was found for your selected area. ",
                                               "This could be due to cloud coverage or because the area is not over land."))
    return()
  }
  if (missing_values > 0) {
    message <- glue::glue("{missing_values} pixels were removed.")
    if (urban > 0) {
      message <- paste(message, glue::glue("{urban} pixels were removed due to urban land use."), sep = " ")
    }
    if (water > 0) {
      message <- paste(message, glue::glue("{water} pixels were removed due to water coverage."), sep = " ")
    }
    logger %>% writeLog(message)
  }

  # remove missing values and rescale data to 0 - 100 %
  raster <- terra::clamp(raster, upper = 1, value = FALSE) * 100

  raster
}
