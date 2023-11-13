# # install.packages("remotes")
# # remotes::install_github("JosiahParry/populartimes")
# 
# # to convert week to number
# source("D:\\Codes\\r_cavitex\\google_popular_times\\get_week_of_day.R")
# 
# library(populartimes)
# library(tidyverse)
# library(leaflet)
# 
# # GPT - start
# # get popular times and save to png file
# popular_times_graph <- function(place_name, address, day_week, day_num) {
#   # get place details
#   get_place <- poptimes_from_address(place_name, address)
#   
#   df_get_place <- as.data.frame(get_place)
#   # print(df_get_place)
#   
#   # get popular times
#   popular_times <- as.data.frame(get_place$popular_times)
#   day_popularity <- subset(popular_times, day_of_week == day_num, select = c(hour, popularity))
#   # print(day_popularity)
#   
#   popularity <- day_popularity %>%
#     select(popularity) # select popularity
#   # print(popularity)
#   
#   hour <- day_popularity %>%
#     select(hour) # select popularity time
# 
#   # graph name (popularity_date_time)
#   dt=format(Sys.time(), "popularity_%Y%m%d_%H%M%S")
#   # paste directory; file_name; extension
#   file_name <- paste("D:\\Codes\\r_cavitex\\google_popular_times\\bar_graphs\\",
#                      dt, ".png", sep = "")
# 
#   # graph png file
#   png(file = file_name,
#       height = 700, width = 1000, units = "px")
# 
#   # create bar graph
#   barplot.default(popularity$popularity,
#           names.arg = hour$hour,
#           ylab = "Popularity",
#           xlab = "Hour",
#           main = paste(place_name, " - ", day_week),
#           col = "blue")
# 
#   # save as png file
#   while (!is.null(dev.list()))  dev.off()
#   
#   return(df_get_place)
# }
# 
# # get day of week
# day_of_week <- get_week_of_day(weekdays(Sys.Date()))
# 
# df_place <- popular_times_graph(
#   "CAVITEX C5 Link Customer Service Center",
#   "Moonwalk Access Rd, Pasay, Metro Manila",
#   weekdays(Sys.Date()),
#   day_of_week
# )
# 
# # # show map
# # map_combined <- leaflet() %>%
# #   addTiles() %>%
# #   addMarkers(
# #     data = df_place,
# #     lng = ~lat,
# #     lat = ~lon
# #   )
# # GPT - end
# 
# # html ui - start
# ui <- fluidPage(
#   # header
#   tags$head(
#     tags$style(HTML(
#       "code {
#         display:block;
#         padding:9.5px;
#         margin:0 0 10px;
#         margin-top:10px;
#         font-size:13px;
#         line-height:20px;
#         word-break:break-all;
#         word-wrap:break-word;
#         white-space:pre-wrap;
#         background-color:#F5F5F5;
#         border:1px solid rgba(0,0,0,0.15);
#         border-radius:4px; 
#         font-family:monospace;
#       }"
#     ))
#   ),
#   titlePanel("Google Popular Times"),
#   sidebarLayout(
#     sidebarPanel(),
#     mainPanel(
#       # show map
#       map_combined <- leaflet() %>%
#         addTiles() %>%
#         addMarkers(
#           data = df_place,
#           lng = ~lat,
#           lat = ~lon
#         )
#     )
#   )
# )
# 
# server <- function(input, output) {}
# # html ui - end
# 
# shinyApp(ui = ui, server = server)
# # map_combined