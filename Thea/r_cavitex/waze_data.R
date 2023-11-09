# install.packages("jsonlite")

library(jsonlite)
library(tidyverse)
library(leaflet)

# download waze data feeds
waze_data <- fromJSON("https://www.waze.com/row-partnerhub-api/partners/11262491165/waze-feeds/8d2cefb6-9636-402c-adb1-be2977117f2d?format=1", flatten = TRUE)


# extract alerts data
dfalerts <- as.data.frame(waze_data$alerts)

# check alert type and set marker color
map_dfcolor <- dfalerts %>%
  mutate(color = case_when(str_detect(type, "JAM") ~ "green",
                           str_detect(type, "ROAD_CLOSED") ~ "blue",
                           str_detect(type, "HAZARD") ~ "orange",
                           str_detect(type, "ACCIDENT") ~ "red",
                           TRUE ~ "a default"))

# create leaflet map and add marker
# add legend
map_combined <- leaflet() %>%
  addTiles() %>%
  addLegend(
    "topright",
    title = "Map Legend",
    colors = c("green", "blue", "orange", "red"),
    label = c("Jam", "Road Closed", "Hazard", "Accident"),
    opacity = 1
  ) %>%
  addCircleMarkers(
    data = dfalerts,
    lng = ~location.x,
    lat = ~location.y,
    popup = ~subtype,
    color = map_dfcolor$color,
    radius = 6
  )

# display map and legend
map_combined