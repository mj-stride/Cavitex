library(jsonlite)
library(tidyverse)
library(leaflet)

draw_poly_map <- function(file_name) {
  waze_data <- fromJSON(file_name)
  # print(waze_data)
  
  # extract alerts data
  df_alerts <- as.data.frame(waze_data$alerts)
  
  # check alert type and set marker color
  map_dfcolor <- dfalerts %>%
    mutate(color = case_when(str_detect(type, "JAM") ~ "green",
                             str_detect(type, "ROAD_CLOSED") ~ "blue",
                             str_detect(type, "HAZARD") ~ "orange",
                             str_detect(type, "ACCIDENT") ~ "red",
                             TRUE ~ "a default")
    )
  
  # extract jams data
  dfjams <- as.data.frame(waze_data$jams)
  dfjams_length <- length(waze_data$jams$line) # get jam line count
  
  # create leaflet map
  # add markers (alert); legend
  map_combined <- leaflet(
    height = 775
  ) %>%
    addTiles() %>%
    addLegend( # for circle markers
      "topright",
      title = "Map Marker Legend",
      colors = c("green", "blue", "orange", "red"),
      label = c("Jam", "Road Closed", "Hazard", "Accident"),
      opacity = 1
    ) %>%
    addLegend( # for polylines
      "bottomright",
      title = "Map Polyine Legend",
      colors = c("green"),
      label = c("Jam"),
      opacity = 1
    ) %>%
    addCircleMarkers(
      data = dfalerts,
      lng = ~location.x,
      lat = ~location.y,
      popup = ~subtype,
      color = map_dfcolor$color,
      opacity = 1,
      fillOpacity = 1,
      weight = 2,
      radius = 4
    )
  
  # add polyline (jam/traffic)
  for (i in 1:dfjams_length) {
    map_combined <- addPolylines(
      map = map_combined,
      data = dfjams,
      lng = ~line[[i]]$x,
      lat = ~line[[i]]$y,
      weight = 2,
      opacity = 1,
      color = "green"
    )
  }
  
  # display map and legend
  return(map_combined)
}