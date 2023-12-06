library(shiny)
library(shinyTime)
library(shinycssloaders)
library(lubridate)

date_now = format(Sys.time(), '%Y-%m-%d')

start_time = c('06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00', '01:00', '02:00', '03:00', '04:00', '05:00')
end_time = c('12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00')

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
        choices = start_time,
        selected = '06:00',
        width = '100%'
      ),
      selectInput(
        inputId = 'id_time_end',
        label = 'Choose end time:',
        choices = start_time,
        selected = '12:00',
        width = '100%'
      ),
      # timeInput(
      #   inputId = 'id_time_start',
      #   label = 'Choose start time (hour:minute):',
      #   value = strptime('06:00:00', '%R'),
      #   seconds = FALSE
      # ),
      # timeInput(
      #   inputId = 'id_time_end',
      #   label = 'Choose end time (hour:minute):',
      #   value = Sys.time(),
      #   seconds = FALSE
      # ),
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
  
  # if (format == 'Per hour') {
  #   ui <<- div(
  #     dateInput(
  #       inputId = 'id_date',
  #       label = 'Choose date:',
  #       min = '2023-01-01',
  #       max = '2024-12-31',
  #       value = date_now
  #     ),
  #     timeInput(
  #       inputId = 'id_time',
  #       label = 'Choose time (hour:minute):',
  #       value = Sys.time(),
  #       seconds = FALSE
  #     ),
  #     selectInput(
  #       inputId = 'id_type',
  #       label = 'Choose type:',
  #       choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
  #       selected = 'All',
  #       width = '100%'
  #     ),
  #     actionButton(
  #       class = 'id_search',
  #       inputId = 'id_search',
  #       label = 'Search'
  #     )
  #   )
  # } else if (format == 'Per day') {
  #   ui <<- div(
  #     dateInput(
  #       inputId = 'id_date',
  #       label = 'Choose date:',
  #       min = '2023-01-01',
  #       max = '2024-12-31',
  #       value = date_now
  #     ),
  #     selectInput(
  #       inputId = 'id_type',
  #       label = 'Choose type:',
  #       choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
  #       selected = 'All',
  #       width = '100%'
  #     ),
  #     actionButton(
  #       class = 'id_search',
  #       inputId = 'id_search',
  #       label = 'Search'
  #     )
  #   )
  # } else {
  #   ui <<- div(
  #     dateInput(
  #       inputId = 'id_date',
  #       label = 'Choose start date:',
  #       min = '2023-01-01',
  #       max = '2024-12-31',
  #       value = date_now
  #     ),
  #     dateInput(
  #       inputId = 'id_date_end',
  #       label = 'Choose end date:',
  #       min = '2023-01-01',
  #       max = '2024-12-31',
  #       value = date_now
  #     ),
  #     selectInput(
  #       inputId = 'id_type',
  #       label = 'Choose type:',
  #       choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
  #       selected = 'All',
  #       width = '100%'
  #     ),
  #     actionButton(
  #       class = 'id_search',
  #       inputId = 'id_search',
  #       label = 'Search'
  #     )
  #   )
  # }
  
  return(ui)
}

get_city <- function(folder_path, start, end) {
  
}