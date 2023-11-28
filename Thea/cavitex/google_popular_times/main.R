library(shiny)
library(tidyverse)
library(leaflet)
library(jsonlite)
library(reticulate)
library(lares)

# r file
source('D:\\Codes\\cavitex\\google_popular_times\\get_week_of_day.R')
source('D:\\Codes\\cavitex\\google_popular_times\\google_popular_times.R')
source('D:\\Codes\\cavitex\\google_popular_times\\api\\api.R')

# python file
source_python('D:\\Codes\\cavitex\\google_popular_times\\api\\api.py')

# html ui
ui <- fillPage(
  tags$head(
    tags$style(
      HTML(
        '.fill-30 { float: left; width: 30%; height: 100%; }',
        '.fill-70 { float: right; width: 70%; height: 100%;}',
      )
    )
  ),
  # left panel
  div(
    class = 'fill-30',
    # search
    div(
      style = 'padding: 10px; margin-bottom: 30px',
      h3('Google Popular Times', style = 'font-weight: bold; color: #46923C;'), # title
      uiOutput(outputId = 'id_location')
    ),
    # week picker
    div(
      style = 'padding: 10px;',
      uiOutput(outputId = 'id_week'),
    ),
    # graph
    imageOutput(outputId = 'id_graph')
  ),
  # right panel
  # map
  div(
    class = 'fill-70',
    leafletOutput(outputId = 'id_map', width = '100%', height = '100%')
  )
)

# html function
server <- function(input, output, session) {location <- get_location()
  
  if (location$status == 200) {
    output$id_location <- renderUI({
      selectInput(
        inputId = 'id_toll_plaza',
        width = '100%',
        label = 'Location',
        choices = location$location$name,
        multiple = FALSE
      )
    })
  } else {
    # empty place name
    showModal(
      modalDialog(
        title = 'Server connection',
        'No fetched location.',
        easyClose = TRUE,
        footer = div(
          modalButton('Close')
        )
      )
    )
  }
  
  # search place; show map
  observeEvent(
    input$id_toll_plaza, {
      # get location info
      json_address <- r_to_py(get_address(input$id_toll_plaza))
      address <<- json2vector(json_address)
      
      # get day of week
      day_week <<- weekdays(Sys.Date())
      day_number <- get_week_of_day(day_week)
      
      # get place information
      df_place <- popular_times_graph(
        input$id_toll_plaza,
        address$coordinates.address,
        day_week,
        day_number
      )
      
      # render map
      output$id_map <- renderLeaflet({
        leaflet(height = '100%') %>%
          addTiles() %>%
          addMarkers(
            lng = as.double(address$coordinates.lng),
            lat = as.double(address$coordinates.lat),
            popup = paste(paste('<b>Name:</b>', input$id_toll_plaza, sep = ' '),
                          paste('<b>Address:</b>', address$coordinates.address, sep = ' '),
                          sep = '\n')
          )
      })
      
      # show week picker
      output$id_week <- renderUI({
        selectInput(
          inputId = 'id_week_of_day',
          width = '100%',
          label = 'Week of the day',
          choices = list('Monday', 'Tuesday', 'Wednesday',
                         'Thursday', 'Friday', 'Saturday', 'Sunday'),
          selected = day_week,
          multiple = FALSE
        )
      })
      
      # show bar graph
      output$id_graph <- renderImage(
        list(src = df_place$file, width = '100%', height = '300px'),
        deleteFile = FALSE
      )
    }
  )
  
  # week of the day picker
  observeEvent(
    input$id_week_of_day, {
      # get day of week
      # day_week <- weekdays(Sys.Date())
      if (input$id_week_of_day != day_week) {
        day_number <- get_week_of_day(input$id_week_of_day)
        
        # get place information
        df_place <- popular_times_graph(
          input$id_toll_plaza,
          address$coordinates.address,
          input$id_week_of_day,
          day_number
        )
        
        # show bar graph
        output$id_graph <- renderImage(
          list(src = df_place$file, width = '100%', height = '300px'),
          deleteFile = FALSE
        )
      } else {
        # clear day_week
        day_week <<- ''
      }
    }
  )
}

# shinyApp(ui = ui, server = server)
gpt <- shinyApp(ui = ui, server = server)