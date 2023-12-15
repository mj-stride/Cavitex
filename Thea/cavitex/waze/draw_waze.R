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

waze_draw_time <- function(folder_path, date, start, end, time.type, time.city, time.street, output) {
  df.rating <- data.frame()
  type_ <- gsub(' ', '-', toupper(time.type))
  
  # check if folder exist
  if (!file.exists(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\'))) {
    dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\')))
    dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, time.city, sep = '\\')))
    
  } else if (!file.exists(paste('D:\\Codes\\cavitex\\waze\\graph', date, time.city, sep = '\\'))) {
    dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, time.city, sep = '\\')))
  }
  
  # get range per hour
  range_hour <- seq(start, end, 'hour')
  time_hour <- data.frame(time = range_hour)
  
  n.rating <- 0 # for rating change
  x <- 1 # start of hour
  y <- 2 # end of hour
  z <- length(range_hour) # number of range_hour
  
  # for creating folde and graph file
  street <- gsub('[[:punct:]]', '', time.street)
  file_name <- paste(street, strftime(time_hour$time[1], '%H%M'), strftime(time_hour$time[z], '%H%M'), sep = '-')
  graph_file <- paste('D:\\Codes\\cavitex\\waze\\graph', date, time.city, file_name, sep = '\\')
  
  while (x <= z) {
    if (x == z) {
      # end of while
      # print('yey')
      colnames(df.rating) <- c('type', 'rate', 'time')
      
      res <- create_graph_time(df.rating, graph_file, type_, time.city, time.street, output)
      
      if (res == TRUE) {
        # show graph
        output$id_graph_time <- renderImage(
          list(src = paste(graph_file, '.png', sep = ''), width = '700px', height = '300px'),
          deleteFile = FALSE
        )
        
        # create map
        output$id_map_time <- renderLeaflet({
          leaflet(
            height = 250
          ) %>%
            addTiles() %>%
            addMarkers(
              lng = lng.x,
              lat = lat.y,
              popup = paste(time.street, time.city, sep = ', ')
            )
        })
      }
      # break
    } else {
      range_min <- seq(time_hour$time[x], time_hour$time[y], '1 min') # range per minute
      time_range <- strftime(range_min, '%H%M') # convert time format
      
      n.time_hour <- time_hour$time[x]
      print(n.time_hour)
      
      for (time in time_range) {
        
        filepath = paste(folder_path, '\\', time, '.json', sep = '')
        
        # check if filepath exist
        if (file.exists(filepath)) {
          waze_data <- fromJSON(filepath)
          dfalerts <- as.data.frame(waze_data$alerts)

          if (type_ != 'ALL') {
            # filter alert by type, city, and street
            df <- dfalerts %>% filter(type %in% c(type_)) %>%
              filter(city %in% c(time.city)) %>%
              filter(street %in% c(time.street))
            
            if (length(df$location$x) > 0) {
              lat.y <<- as.double(df$location$y)
              lng.x <<- as.double(df$location$x)
            }
            
            # check if reportRating is blank
            if (identical(df$reportRating, integer(0))) {
              # check reportRating
              if (!identical(n.rating, 0)) {
                n.rating <- 0
                
                # create list of data to be inserted in df.rating
                n.output <- c(type_, n.rating, time)
                # insert n.output to df.rating
                df.rating <- rbind(df.rating, n.output)
              }
            } else {
              # check if more than 1 reportRating and get the highest data
              if (length(df$reportRating) > 1) {
                reportRating <- max(df$reportRating)
                
                if (!identical(n.rating, reportRating)) {
                  n.rating <- reportRating
                  
                  # create list of data to be inserted in df.rating
                  n.output <- c(type_, n.rating, time)
                  # insert n.output to df.rating
                  df.rating <- rbind(df.rating, n.output)
                }
              } else {
                if (!identical(n.rating, df$reportRating)) {
                  n.rating <- df$reportRating
                  
                  # create list of data to be inserted in df.rating
                  n.output <- c(type_, n.rating, time)
                  # insert n.output to df.rating
                  df.rating <- rbind(df.rating, n.output)
                }
              }
            }
          } else {
            # ALL
            # filter alert by city, and street
            df <- dfalerts %>% filter(city %in% c(time.city)) %>%
              filter(street %in% c(time.street))
            
            # check if reportRating is blank
            if (!identical(df$reportRating, integer(0))) {
              if (!identical(df$reportRating, character(0))) {
                # check if more than 1 reportRating and get the highest data
                if (length(df$reportRating) > 1) {
                  reportRating <- max(df$reportRating)
                  
                  if (!identical(n.rating, reportRating)) {
                    n.rating <- reportRating
                    
                    # create list of data to be inserted in df.rating
                    n.output <- c(df$type[1], n.rating, time)
                    print(paste('1', n.output, sep = ' '))
                    # insert n.output to df.rating
                    df.rating <- rbind(df.rating, n.output)
                  }
                } else {
                  if (!identical(n.rating, df$reportRating)) {
                    n.rating <- df$reportRating
                    
                    # create list of data to be inserted in df.rating
                    n.output <- c(df$type, n.rating, time)
                    print(paste('2', n.output, sep = ' '))
                    # insert n.output to df.rating
                    df.rating <- rbind(df.rating, n.output)
                  }
                }
              }
            }
          }
          
        }
      }
    }
    
    x <- x + 1
    y <- y + 1
  }
  
  
}

create_graph_time <- function(df.rating, graph_file, time.type, time.city, time.street, output) {
  print(graph_file)
  # create folder and file
  # graph_file is created at waze_draw_time()
  png(file = paste(graph_file, '.png', sep = ''), height = 800, width = 1500, units = 'px')
  
  n <- length(df.rating$time)
  
  tryCatch({
    if (time.type != 'ALL') {
      plot(
        df.rating$rate,
        type = 'o',
        col = 'blue',
        lwd = 3,
        font.axis = 2,
        font.lab = 2,
        xlab = paste('Time:', df.rating$time[1], '-' , df.rating$time[n], sep = ' '),
        xaxt = 'n',
        ylab = 'Report Rating',
        main = paste(time.street, ',', time.city, '-', time.type, sep = ' ')
      )
      axis( # change bottom label to time
        1,
        at = seq(1, n, by = 1),
        labels = df.rating$time[1:n],
        font.axis = 2,
        font.lab = 2,
        tick = -0.01
      )
      
      # create file
      dev.off()
      
      return(TRUE)
    } else {
      # create file
      dev.off()
      
      return(TRUE)
    }
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