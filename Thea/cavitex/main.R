library(shiny)
library(jsonlite)
library(tidyverse)
library(reticulate)
library(later)

# source('D:\\Codes\\cavitex\\google_popular_times\\main.R')
source('D:\\Codes\\cavitex\\waze\\main.R')

# source_python('D:\\Codes\\cavitex\\waze\\waze_feeds\\download_waze.py')

ui <- fillPage(
  tags$head(
    tags$style(
      HTML(
        'body { height: 100%; background-color: white; }'
      )
    )
  ),
  navbarPage(
    title = 'CAVITEX',
    tabPanel(
      title = "Google Popular Times",
      uiOutput(
        outputId = 'id_gpt',
        height = 1000
      )
    ),
    tabPanel(
      title = "Waze Data",
      uiOutput(
        outputId = 'id_waze'
      )
    )
  )
)

server <- function(input, output, session) {
  # r_to_py(download_waze())
  
  output$id_gpt <- renderUI({
    gpt
  })

  output$id_waze <- renderUI({
    waze
  })
}

shinyApp(ui = ui, server = server)