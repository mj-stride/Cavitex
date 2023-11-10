# install.packages("remotes")
# remotes::install_github("JosiahParry/populartimes")

library(populartimes)
library(tidyverse)
library(leaflet)

# show map
# map <- leaflet() %>%
#   addTiles() %>%
#   setView(lat = 12.8797,
#           lng = 121.7740,
#           zoom = 6)

# get popular times and save to png file
popular_times_graph <- function(place_name, address, x) {
  # get place details
  get_place = poptimes_from_address(place_name, address)
  
  # get popular times
  popular_times <- as.data.frame(get_place$popular_times)
  day_popularity <- subset(popular_times, day_of_week == x, select = c(hour, popularity))
  # print(day_popularity)
  
  popularity <- day_popularity %>%
    select(popularity) # select popularity
  # print(popularity)
  
  hour <- day_popularity %>%
    select(hour) # select popularity time

  # graph name (popularity_date_time)
  dt=format(Sys.time(), "popularity_%Y%m%d_%H%M%S")
  # paste directory; file_name; extension
  file_name <- paste("D:\\Codes\\r_cavitex\\bar_graphs\\",
                     dt, ".png", sep = "")

  # graph png file
  png(file = file_name,
      height = 700, width = 1000, units = "px")

  # create bar graph
  barplot.default(popularity$popularity,
          names.arg = hour$hour,
          ylab = "Popularity",
          xlab = "Hour",
          main = place_name,
          col = "blue")

  # save as png file
  while (!is.null(dev.list()))  dev.off()
}

# get day of week
day_of_week <- weekdays(Sys.Date())

if (day_of_week == "Monday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    1
  )
} else if (day_of_week == "Tuesday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    2
  )
} else if (day_of_week == "Wednesday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    3
  )
} else if (day_of_week == "Thursday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    4
  )
} else if (day_of_week == "Friday") {
  popular_times_graph(
    "Kawit Toll Plaza",
    "E3, Kawit, 4104 Cavite",
    5
  )
} else if (day_of_week == "Saturday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    6
  )
} else if (day_of_week == "Sunday") {
  popular_times_graph(
    "CAVITEX C5 Link Customer Service Center",
    "Moonwalk Access Rd, Pasay, Metro Manila",
    7
  )
}

# map
