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
  graph_file_list <- list()
  
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
      print('end')
      # return(graph_file_list)
      break
    } else {
      street <- gsub('[[:punct:]]', '', street_)
      
      range_min <- seq(time_hour$time[x], time_hour$time[y], '1 min') # range per minute
      time_range <- strftime(range_min, '%H%M') # convert time format
      
      # for creating folder and graph file
      file_name <- paste(street, strftime(time_hour$time[x], '%H%M'), strftime(time_hour$time[y], '%H%M'), sep = '-')
      graph_file <<- paste('D:\\Codes\\cavitex\\waze\\graph', date, city_, file_name, sep = '\\')
      
      graph_file_list <- append(graph_file_list, paste(graph_file, '.png', sep = ''))
      
      # check if folder exist
      if (!file.exists(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\'))) {
        dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, sep = '\\')))
        dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, city_, sep = '\\')))
        
      } else if (!file.exists(paste('D:\\Codes\\cavitex\\waze\\graph', date, city_, sep = '\\'))) {
        dir.create(file.path(paste('D:\\Codes\\cavitex\\waze\\graph', date, city_, sep = '\\')))
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
  
  return(graph_file_list)
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
          dfalerts <- df %>% filter(city %in% c(city_)) %>%
            filter(street %in% c(street_))
          
          # check if with location
          # get coordinates
          if (length(dfalerts$location$x) > 0) {
            lat.y <<- as.double(dfalerts$location$y)
            lng.x <<- as.double(dfalerts$location$x)
          }
          
          # if with report rating
          # create list of be inserted in report_rating data frame
          if (identical(dfalerts$type, 'JAM')) {
            # check if NO report rating on json file
            if (!identical(dfalerts$reportRating, integer(0))) {
              # if with report rating
              # check if reportRating has more than 1 report
              if (length(dfalerts$reportRating) > 1) {
                output_data <- c(dfalerts$reportRating[2], 0, 0, 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              } else {
                output_data <- c(dfalerts$reportRating, 0, 0, 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              }
            } else {
              # if without report rating
              output_data <- c(0, 0, 0, 0, raw_file$time[x])
              
              report_rating <- rbind(report_rating, output_data)
            }

          } else if (identical(dfalerts$type, 'ROAD_CLOSED')) {
            # check if NO report rating on json file
            if (!identical(dfalerts$reportRating, integer(0))) {
              # if with report rating
              # check if reportRating has more than 1 report
              if (length(dfalerts$reportRating) > 1) {
                output_data <- c(0, dfalerts$reportRating[2], 0, 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              } else {
                output_data <- c(0, dfalerts$reportRating, 0, 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              }
            } else {
              # if without report rating
              output_data <- c(0, 0, 0, 0, raw_file$time[x])
              
              report_rating <- rbind(report_rating, output_data)
            }

          } else if (identical(dfalerts$type, 'HAZARD')) {
            # check if NO report rating on json file
            if (!identical(dfalerts$reportRating, integer(0))) {
              # if with report rating
              # check if reportRating has more than 1 report
              if (length(dfalerts$reportRating) > 1) {
                output_data <- c(0, 0, dfalerts$reportRating[2], 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              } else {
                output_data <- c(0, 0, dfalerts$reportRating, 0, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              }
            } else {
              # if without report rating
              output_data <- c(0, 0, 0, 0, raw_file$time[x])
              
              report_rating <- rbind(report_rating, output_data)
            }

          } else if (identical(dfalerts$type, 'ACCIDENT')) {
            # check if NO report rating on json file
            if (!identical(dfalerts$reportRating, integer(0))) {
              # if with report rating
              # check if reportRating has more than 1 report
              if (length(dfalerts$reportRating) > 1) {
                output_data <- c(0, 0, 0, dfalerts$reportRating[2], raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              } else {
                output_data <- c(0, 0, 0, dfalerts$reportRating, raw_file$time[x])

                report_rating <- rbind(report_rating, output_data)
              }
            } else {
              output_data <- c(0, 0, 0, 0, raw_file$time[x])
              
              report_rating <- rbind(report_rating, output_data)
            }
          } else {
            # if without report rating
            output_data <- c(0, 0, 0, 0, raw_file$time[x])
            
            report_rating <- rbind(report_rating, output_data)
          }
          
        } else {
          # filter type  by city and street picked
          dfalerts <- df %>% filter(type %in% c(type_)) %>%
            filter(city %in% c(city_)) %>%
            filter(street %in% c(street_))
          
          # check if with location
          # get coordinates
          if (length(dfalerts$location$x) > 0) {
            lat.y <<- as.double(dfalerts$location$y)
            lng.x <<- as.double(dfalerts$location$x)
          }
          
          # check if NO report rating on json file
          if (!identical(dfalerts$reportRating, integer(0))) {
            # if with report rating
            # check if reportRating has more than 1 report
            if (length(dfalerts$reportRating) > 1) {
              # create list of be inserted in report_rating data frame
              output_data <- c(dfalerts$reportRating[2], raw_file$time[x])
              
              # insert to report_rating data frame
              report_rating <- rbind(report_rating, output_data)
            } else {
              # create list of be inserted in report_rating data frame
              output_data <- c(dfalerts$reportRating, raw_file$time[x])
              
              # insert to report_rating data frame
              report_rating <- rbind(report_rating, output_data)
            }
          } else {
            # if without report rating
            # consider it as 0
            output_data <- c(0, raw_file$time[x])
            
            # insert to report_rating data frame
            report_rating <- rbind(report_rating, output_data)
          }
        }
      }
    }

    x <- x + 1
  }
  
  if (type_ == 'ALL') {
    # name of report_rating
    if (length(report_rating) > 0) {
      colnames(report_rating) <- c('jam', 'road_closed', 'hazard', 'accident', 'time')
      
      # create graph
      create_graph(report_rating, graph_file, type_, city_, street_, output)
    } else {
      print('no data')
    }
  } else {
    print('here custom')
    # name of report_rating
    colnames(report_rating) <- c('data', 'time')

    # create graph
    create_graph(report_rating, graph_file, type_, city_, street_, output)
  }
}

create_graph <- function(report_rating, graph_file, type, city_, street, output) {
  # create folder and file
  # graph_file is created at waze_draw_time()
  png(file = paste(graph_file, '.png', sep = ''), height = 800, width = 1500, units = 'px')
  
  n <- length(report_rating$time) # count rows
  
  tryCatch({
    if (type == 'ALL') {
      plot(
        report_rating$jam,
        type = 'o',
        col = 'green',
        xlab = paste('Time:', report_rating$time[1], '-' , report_rating$time[n], sep = ' '),
        xaxt = 'n',
        ylab = 'Report Rating',
        main = paste(street, ', ', city_, ' - ', type)
      )
      lines(
        report_rating$time,
        report_rating$road_closed,
        type = 'o',
        col = 'blue'
      )
      lines(
        report_rating$time,
        report_rating$hazard,
        type = 'o',
        col = 'orange'
      )
      lines(
        report_rating$time,
        report_rating$accident,
        type = 'o',
        col = 'red'
      )
      legend(
        'topright',
        legend = c(
          'Jam',
          'Road Closed',
          'Hazard',
          'Accident'
        ),
        lty = 1,
        col = c(
          'green',
          'blue',
          'orange',
          'red'
        )
      )
      axis( # change bottom label to time
        1,
        at = seq(1, n, by = 1),
        labels = report_rating$time[1:n],
        tick = -0.01
      )
    } else {
      # create line graph
      plot(
        report_rating$data,
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
        labels = report_rating$time[1:n],
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
  
  output$id_map_time <- renderLeaflet({
    leaflet(
      height = 250
    ) %>%
      addTiles() %>%
      addMarkers(
        lng = lng.x,
        lat = lat.y,
        popup = paste(street, city_, sep = ', ')
      )
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