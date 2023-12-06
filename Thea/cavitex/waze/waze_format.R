library(shiny)
library(shinyTime)
library(shinycssloaders)
library(lubridate)
library(plyr)

date_now = format(Sys.time(), '%Y-%m-%d')

input_time = c('00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00')
# end_time = c('12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00', '00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00')

waze_hour <- function() {
  ui <- sidebarLayout(
    sidebarPanel(
      style = 'height: 90vh;',
      width = 3,
      div(
        style = 'z-index: 9999 !important;',
        dateInput(
          inputId = 'id_date',
          label = 'Choose date:',
          min = '2023-01-01',
          max = '2024-12-31',
          value = date_now
        ),
        timeInput(
          inputId = 'id_time',
          label = 'Choose time (hour:minute):',
          value = Sys.time(),
          seconds = FALSE
        ),
        selectInput(
          inputId = 'id_type_hour',
          label = 'Choose type:',
          choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
          selected = 'All',
          width = '100%'
        ),
        actionButton(
          class = 'id_search',
          inputId = 'id_search',
          label = 'Search'
        )
      )
    ),
    mainPanel(
      style = 'height: 100%;',
      width = 9,
      withSpinner(
        color = '#46923C',
        uiOutput(
          outputId = 'id_map_waze_hour'
        )
      )
    )
  )
  
  return (ui)
}

waze_range <- function(r) {
  print(r)
  
  city <- get_city()
  print(city)
  
  if (r == 'Time') {
    ui <<- div(
      style = 'z-index: 9999 !important;',
      dateInput(
        inputId = 'id_date_start',
        label = 'Choose date:',
        min = '2023-01-01',
        max = '2024-12-31',
        value = date_now
      ),
      selectInput(
        inputId = 'id_time_start',
        label = 'Choose start time:',
        choices = input_time,
        selected = '06:00',
        width = '100%'
      ),
      selectInput(
        inputId = 'id_time_end',
        label = 'Choose end time:',
        choices = input_time,
        selected = '12:00',
        width = '100%'
      ),
      selectInput(
        inputId = 'id_city',
        label = 'Choose type:',
        choices = city,
        selected = 'All',
        width = '100%'
      ),
      selectInput(
        inputId = 'id_type_range',
        label = 'Choose type:',
        choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
        selected = 'All',
        width = '100%'
      ),
      actionButton(
        class = 'id_search',
        inputId = 'id_search_range',
        label = 'Search'
      )
    )
  } else {
    ui <<- div(
      style = 'z-index: 9999 !important;',
      dateInput(
        inputId = 'id_date_start',
        label = 'Choose start date:',
        min = '2023-01-01',
        max = '2024-12-31',
        value = date_now
      ),
      dateInput(
        inputId = 'id_date_end',
        label = 'Choose end date:',
        min = '2023-01-01',
        max = '2024-12-31',
        value = date_now
      ),
      selectInput(
        inputId = 'id_type_range',
        label = 'Choose type:',
        choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
        selected = 'All',
        width = '100%'
      ),
      actionButton(
        class = 'id_search',
        inputId = 'id_search_range',
        label = 'Search'
      )
    )
  }
  
  return(ui)
}

get_city <- function() {
  folder_path <- 'D:\\Codes\\cavitex\\waze\\downloaded_waze\\2023-11-30\\0000.json'
  waze_data <- fromJSON(folder_path)
  df <- as.data.frame(waze_data$alerts)
  
  return(unique(df$city))
}

get_street <- function(city_, folder_path, start, end) {
  street_list <- list()
  
  # get range per folder depend in start and end time
  range_min <- seq(start, end, '1 min')
  times <- data.frame(time = paste(folder_path, '\\', strftime(range_min, '%H%M'), '.json', sep = ''))
  
  # get length
  x <- 1
  y <- length(times$time) + 1
  
  # create list of street
  while (x < y) {
    if (x == y) {
      print('end')
      break
    } else {
      # check if folder exists
      if (file.exists(times$time[x])) {
        # get data
        waze_data <- fromJSON(times$time[x])
        df <- as.data.frame(waze_data$alerts)
        
        # get street depending in city
        df.city <- df %>% filter(city %in% c(city_))
        df.street <- df.city$street
        
        # check if null
        if (!identical(df.street, integer(0))) {
          if (!identical(df.street, character(0))) {
            if (!is.null(df.street)) {
              # insert to list
              for (s in df.street) {
                street_list <- append(street_list, s)
              }
            }
          }
        }
      }
    }
    
    x <- x + 1
  }

  return(street_list)
}