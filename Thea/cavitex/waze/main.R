# install.packages('shinyTime')
# install.packages('lubridate')

library(shiny)
library(jsonlite)
library(tidyverse)
library(leaflet)
library(shinyTime)
library(lubridate)

# r file
source('D:\\Codes\\cavitex\\waze\\draw_waze.R')

date_now = format(Sys.time(), '%Y-%m-%d')

ui <- fillPage(
  tags$head(
    tags$style(
      HTML(
        '.fill-20 { float: left; width: 20%; height: 100%; }',
        '.fill-80 { float: right; width: 80%; height: 100%;}',
        '#id_search { float: right; background-color: #46923C; color: white; border: 2px solid #46923C; }'
      )
    )
  ),
  # for search of date and time
  div(
    class = 'fill-20',
    style = 'padding: 10px;',
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
      inputId = 'id_type',
      label = 'Choose alert type',
      choices = c('All', 'Jam', 'Road Closed', 'Hazard', 'Accident'),
      width = '100%',
      selected = 'All',
    ),
    actionButton(
      class = 'id_search',
      inputId = 'id_search',
      label = 'Search'
    )
  ),
  div(
    class = 'fill-80',
    uiOutput(
      outputId = 'id_map_waze'
    )
  )
)
  
default <- function(input, output) {
  folder_path <- 'D:\\Codes\\cavitex\\waze\\waze_feeds\\downloaded_waze'
  file_path <- paste(folder_path, date_now, strftime(Sys.time(), '%H%M'), sep = '\\')
  file <- paste(file_path, '.json', sep = '')
  
  if (file.exists(file)) {
    map <- draw_poly_map(file, 'All')
    
    output$id_map_waze <- renderUI({
      div(
        map
      )
    })
  } else {
    # no such file
    showModal(
      modalDialog(
        title = 'No file found',
        'Please choose other date or time.',
        easyClose = TRUE,
        footer = div(
          modalButton('Close')
        )
      )
    )
  }
}

server <- function(input, output, session) {
  # default output, for first load
  default(input, output)
  
  observeEvent(
    input$id_search, {
      input_date <- input$id_date
      input_time <- strftime(input$id_time, '%H%M')
      
      folder_path <- 'D:\\Codes\\cavitex\\waze\\waze_feeds\\downloaded_waze'
      file_path <- paste(folder_path, input_date, input_time, sep = '\\')
      file <- paste(file_path, '.json', sep = '')
      
      if (file.exists(file)) {
        type <- input$id_type
        
        map <- draw_poly_map(file, type)
        
        output$id_map_waze <- renderUI({
          div(
            map,
            height = '100%',
            style = 'background-color: red; height: 100%;'
          )
        })
      } else {
        # no such file
        showModal(
          modalDialog(
            title = 'No file found',
            'Please choose other date or time.',
            easyClose = TRUE,
            footer = div(
              modalButton('Close')
            )
          )
        )
      }
    }
  )
}

waze <- shinyApp(ui = ui, server = server)
waze