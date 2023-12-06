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

waze_draw_time <- function(folder_path, date, start, end, type, city_, street_, output) {
  type_ <- gsub(' ', '_', toupper(type))
  
  # get range per hour
  # to know the start and end time of each graph will be made
  range_hour <- seq(start, end, 'hour')
  time_hour <- data.frame(time = range_hour)
  
  x <- 1 # start of hour
  y <- 2 # end of hour
  z <- length(range_hour) # number of range_hour
  
  while(x < z) {
    if (x > z) {
      # end of loop
      break
    } else {
      range_min <- seq(time_hour$time[x], time_hour$time[y], '1 min') # range per minute
      time_range <- strftime(range_min, '%H%M') # convert time format
      
      # for creating folder and graph file
      
      # print(graph_file)
      
      file_name <- paste(strftime(time_hour$time[x], '%H%M'), strftime(time_hour$time[y], '%H%M'), city_, sep = '-')
      graph_file <<- paste('D:\\Codes\\cavitex\\waze\\graph\\', date, '\\', file_name, sep = '')
      
      if (!file.exists(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\'))) {
        dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\')))
      }
      
      # create data.frame of folder path
      raw_file <- data.frame(
        time = time_range,
        filepath = paste(folder_path, '\\', time_range, '.json', sep = '')
      )
      
      # create new data.frame of data to be plot in graph
      create_df(raw_file, graph_file, type_, city_, street_, output)
    }
    
    x <- x + 1
    y <- y + 1
  }
}

create_df <- function(raw_file, graph_file, type_, city_, street_, output) {
  report_rating <- data.frame()
  
  x <- 1 # start number
  y <- length(raw_file$filepath) + 1 # number of file

  while (x < y) {
    
    if (x == y) {
      # end loop
      break
    } else {
      # check if file exist
      if (file.exists(raw_file$filepath[x])) {
        waze_data <- fromJSON(raw_file$filepath[x]) # open json file

        # create raw data frame
        df <- as.data.frame(waze_data$alerts)
        
        if (type_ == 'ALL') {
          
        } else {
          # filter jam by city and street picked
          dfalerts <- df %>% filter(type %in% c(type_)) %>%
            filter(city %in% c(city_)) %>%
            filter(street %in% c(street_))
          
          # check if NO report rating on json file
          if (!identical(dfalerts$reportRating, integer(0))) {
            # if with report rating
            # create list of be inserted in report_rating data frame
            output <- c(dfalerts$reportRating, raw_file$time[x])
            
            # insert to report_rating data frame
            report_rating <- rbind(report_rating, output)
          } else {
            # if without report rating
            # consider it as 0
            output <- c(0, raw_file$time[x])
            
            # insert to report_rating data frame
            report_rating <- rbind(report_rating, output)
          }
        }
        
      }
    }

    x <- x + 1
  }
  
  if (type_ == 'ALL') {
    # name of report_rating
    colnames(report_rating) <- c('JAM', 'ROAD_CLOSED', 'HAZARD', 'ACCIDENT', 'TIME')
    
    # create graph
    create_graph(report_rating, graph_file, type_, city_, street_, output)
  } else {
    # name of report_rating
    colnames(report_rating) <- c('TYPE', 'TIME')
    
    # create graph
    create_graph(report_rating, graph_file, type_, city_, street_, output)
  }
}

create_graph <- function(report_rating, graph_file, type, city_, street, output) {
  print(report_rating)
  
  # create folder and file
  # graph_file is created at waze_draw_time()
  png(file = paste(graph_file, '.png', sep = ''), height = 800, width = 1500, units = 'px')
  
  n <- length(report_rating$TIME) # count rows
  
  tryCatch({
    if (type == 'ALL') {
      
    } else {
      # create line graph
      plot(
        report_rating$TYPE,
        type = 'o',
        col = 'green',
        xlab = 'Time',
        xaxt = 'n',
        ylab = 'Report Rating',
        main = paste(street, ', ', city_, ' - ', type)
      )
      axis( # change bottom label to time
        1,
        at = seq(1, n, by = 1),
        labels = report_rating$TIME[1:n],
        tick = -0.01
      )
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
  
  # create file
  dev.off()
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