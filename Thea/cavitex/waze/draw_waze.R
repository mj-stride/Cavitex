library(jsonlite)
library(tidyverse)
library(leaflet)
library(dplyr)
library(lubridate)

waze_draw_hour <- function(file_name, type) {
  type_ <- gsub(' ', '_', toupper(type))
  
  waze_data <- fromJSON(file_name)
  
  if (type_ == 'ALL') { # ========== ALL DATA
    # extract alerts data
    dfalerts <- as.data.frame(waze_data$alerts)
    
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
    map_combined <<- leaflet(
      height = 695
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
        data = map_dfcolor,
        lng = ~location$x,
        lat = ~location$y,
        popup = ~subtype,
        color = ~color,
        opacity = 1,
        fillOpacity = 1,
        weight = 2,
        radius = 4
      )
    
    # add polyline (jam/traffic)
    for (i in 1:dfjams_length) {
      map_combined <<- addPolylines(
        map = map_combined,
        data = dfjams,
        lng = ~line[[i]]$x,
        lat = ~line[[i]]$y,
        weight = 2,
        opacity = 1,
        color = "green"
      )
    }
    
  } else if (type_ == 'JAM') { # ========== JAM ONLY
    # extract jams data
    dfjams <- as.data.frame(waze_data$jams)
    dfjams_length <- length(waze_data$jams$line) # get jam line count
    
    # create leaflet map
    # add markers (alert); legend
    map_combined <<- leaflet(
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
      )
    
    # add polyline (jam/traffic)
    for (i in 1:dfjams_length) {
      map_combined <<- addPolylines(
        map = map_combined,
        data = dfjams,
        lng = ~line[[i]]$x,
        lat = ~line[[i]]$y,
        weight = 2,
        opacity = 1,
        color = "green"
      )
    }
    
  } else {
    # extract alerts data
    dfalerts <- as.data.frame(waze_data$alerts)
    df <- dfalerts %>% filter(type %in% c(type_)) # get data depend on type
    
    # check alert type and set marker color
    map_dfcolor <- df %>%
      mutate(color = case_when(str_detect(type, "JAM") ~ "green",
                               str_detect(type, "ROAD_CLOSED") ~ "blue",
                               str_detect(type, "HAZARD") ~ "orange",
                               str_detect(type, "ACCIDENT") ~ "red",
                               TRUE ~ "a default")
      )
    
    # create leaflet map
    # add markers (alert); legend
    map_combined <<- leaflet(
      height = '100%'
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
        data = map_dfcolor,
        lng = ~location$x,
        lat = ~location$y,
        popup = ~subtype,
        color = ~color,
        opacity = 1,
        fillOpacity = 1,
        weight = 2,
        radius = 4
      )
  }
  
  # display map and legend
  return(map_combined)
}

waze_draw_time <- function(folder_path, start, end, type, city_, output) {
  type_ <- gsub(' ', '_', toupper(type))
  
  time_range <- seq(start, end, '1 min')
  times <- strftime(time_range, '%H%M')
  
  raw_file <- data.frame(
    filepath = paste(folder_path, '\\', times, '.json', sep = '')
  )
  
  x <- 1
  y <- length(raw_file$filepath) + 1

  while (x < y) {
    print(x)
    
    if (x == y) {
      break
    } else {
      if (file.exists(raw_file$filepath[x])) {
        # print('exist')
        
        waze_data <- fromJSON(raw_file$filepath[x])
        
        dfalerts <- as.data.frame(waze_data$alerts)
        
        jams <- dfalerts %>% filter(type %in% c('JAM'))
        dfjams <- jams %>% filter(city %in% c(city_))
        
        n <- length(dfjams$reportRating)

        tryCatch({
          # file name
          png(file = paste(x, city_, '-', 'line_graph.png', sep = ''), height = 900, width = 1800, units = 'px')

          # create line graph
          plot(
            dfjams$reportRating,
            type = 'o',
            col = 'green',
            xlab = 'Street',
            ylab = 'Report Rating',
            main = city_
          )
          axis(
            1,
            at = seq(1, n, by = 1),
            labels = FALSE,
            tick = -0.01
          )
          text(
            seq(1, n, by = 1),
            par("usr")[3] - 0.2,
            labels = dfjams$street[1:n],
            srt = 45,
            pos = 1,
            offset = 0.5,
            xpd = TRUE
          )

          # create file
          dev.off()
        },
        error = function(cond) {
          status <- c(500)
          err <- data.frame(status)
          return(err)
        },
        warning = function(cond) {
          status <- c(500)
          err <- data.frame(status)
          return(err)
        },
        finally = {
          message('Finally')
        })
      }
    }
    
    x <- x + 1
  }
  
  # for (file in files) {
  #   if (file.exists(file)) {
  #     # D:\\Codes\\cavitex\\waze\\downloaded_waze\\2023-11-30\\1340.json
  #     
  #     waze_data <- fromJSON(file)
  #     # print(waze_data)
  #     
  #     if (type_ == 'ALL') {
  #       dfalerts <- as.data.frame(waze_data$alerts)
  #       
  #       dfjam <- dfalerts %>% filter(type %in% c('JAM'))
  #       df_jam <- dfjam %>% filter(city %in% c(city))
  #       # df_road <- dfalerts %>% filter(type %in% c('ROAD_CLOSED'))
  #       # df_hazard <- dfalerts %>% filter(type %in% c('HAZARD'))
  #       # df_accident <- dfalerts %>% filter(type %in% c('ACCIDENT'))
  #       
  #       n <- length(df_jam$reportRating)
  #       print(n)
  #       
  #       tryCatch({
  #         
  #         line_graph <<- plot(
  #           df_jam$reportRating,
  #           # names.arg = df_jam$street,
  #           type = 'o',
  #           col = 'green',
  #           xlab = 'Street',
  #           ylab = 'Report Rating',
  #           main = city
  #         )
  #         axis(
  #           1,
  #           at = seq(1, n, by = 1),
  #           labels = FALSE,
  #           tick = -0.01
  #         )
  #         text(
  #           seq(1, n, by = 1),
  #           par("usr")[3] - 0.2,
  #           labels = df_jam$street[1:n],
  #           srt = 45,
  #           pos = 1,
  #           xpd = TRUE
  #         )
  #       },
  #       error = function(cond) {
  #         status <- c(500)
  #         err <- data.frame(status)
  #         return(err)
  #       },
  #       finally = {
  #         message('Finally')
  #       })
  #       
  #       # create file
  #       dev.off()
  #     }
  #   }
  #   # else {
  #   #   print(paste('file not exist:', file, sep = ' '))
  #   # }
  # }
}

waze_draw_date <- function(folder_path, start, end, type) {
  type_ <- gsub(' ', '_', toupper(type))
  
  date_range <- seq(start, end, 'days')
  file_folder <- paste(folder_path, date_range, sep = '\\')
  
  for (folder in file_folder) {
    
    if (file.exists(folder)) {
      file_name <- list.files(path = folder, pattern = '.json', all.files = TRUE, full.names = FALSE)
      file_path <- paste(folder, file_name, sep = '\\')

      # waze_data <- fromJSON(file_path)
      # print(file_path)
    }
    # else {
    #   print(paste('folder not exist:', folder, sep = ' '))
    # }
  }
}