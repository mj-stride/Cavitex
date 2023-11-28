# # install.packages('shiny')
# # install.packages(c('tidyverse','leaflet'))
# # install.packages(c('httr','jsonlite'))
# # install.packages('remotes')
# # remotes::install_github('JosiahParry/populartimes')
# 
# library(shiny)
# library(tidyverse)
# library(leaflet)
# 
# # r file
# source('D:\\Codes\\cavitex\\google_popular_times\\get_week_of_day.R')
# source('D:\\Codes\\cavitex\\google_popular_times\\google_popular_times.R')
# 
# # html ui
# ui <- fillPage(
#   tags$head(
#     tags$style(
#       HTML(
#         'body { height: 100%; background-color: white; }',
#         '.fill-40 { float: left; width: 40%; height: 100%; }',
#         '.fill-60 { float: right; width: 60%; height: 100%;}',
#         '#id_search { float: right; background-color: #46923C; color: white; border: 2px solid #46923C }'
#       )
#     )
#   ),
#   # left panel
#   div(
#     class = 'fill-40',
#     # search
#     div(
#       style = 'padding: 10px; margin-bottom: 30px',
#       h3('Google Popular Times', style = 'font-weight: bold; color: #46923C;'), # title
#       textInput(inputId = 'id_place_name', label = 'Place name', width = '100%'), # place name
#       textInput(inputId = 'id_address', label = 'Address', width = '100%'), # address
#       actionButton(inputId = 'id_search', label = 'Search'), # button
#     ),
#     # week picker
#     div(
#       style = 'padding: 10px;',
#       uiOutput(outputId = 'id_week'),
#     ),
#     # graph
#     imageOutput(outputId = 'id_graph')
#   ),
#   # right panel
#   # map
#   div(
#     id = 'id_map_default',
#     class = 'fill-60',
#     leafletOutput(outputId = 'id_map', width = '100%', height = '100%')
#   )
# )
# 
# # html function
# server <- function(input, output, session) {
#   # default map view
#   output$id_map <- renderLeaflet({
#     leaflet(height = '100%') %>%
#       addTiles() %>%
#       setView(
#         lng = 121.7740,
#         lat = 12.8797,
#         zoom = 6
#       )
#   })
#   
#   # search place; show map
#   observeEvent(
#     input$id_search, {
#       # get text input
#       place_name <<- input$id_place_name
#       place_address <<- input$id_address
#       
#       # search place information checker
#       if (place_name != '') {
#         if (place_address != '') {
#           
#           # get day of week
#           day_week <- weekdays(Sys.Date())
#           day_number <- get_week_of_day(day_week)
#           
#           # get place information
#           df_place <- popular_times_graph(
#             place_name,
#             place_address,
#             day_week,
#             day_number
#           )
#           
#           if (df_place$status != 500) {
#             # show week picker
#             output$id_week <- renderUI({
#               selectInput(
#                 inputId = 'id_week_of_day',
#                 width = '100%',
#                 label = 'Week of the day',
#                 choices = list('Monday', 'Tuesday', 'Wednesday',
#                                'Thursday', 'Friday', 'Saturday', 'Sunday'),
#                 selected = day_week,
#                 multiple = FALSE
#               )
#             })
#             
#             # delete file
#             # create 2 graph file, remove redundant file
#             if (file.exists(df_place$file)) {
#               file.remove(df_place$file)
#             }
#             
#             # show map
#             output$id_map <- renderLeaflet({
#               leaflet(height = '100%') %>%
#                 addTiles() %>%
#                 addMarkers(
#                   data = df_place,
#                   lng = ~lat,
#                   lat = ~lon,
#                   popup = paste(paste('<b>Name:</b>', df_place$place_name, sep = ' '),
#                                 paste('<b>Address:</b>', df_place$address, sep = ' '),
#                                 sep = '\n')
#                 )
#             })
#             
#           } else {
#             # invalid place name and address
#             showModal(
#               modalDialog(
#                 title = 'Failed to load map',
#                 'Invalid place name and/or address.',
#                 easyClose = TRUE,
#                 footer = div(
#                   modalButton('Close')
#                 )
#               )
#             )
#           }
#           
#         } else {
#           # empty address
#           showModal(
#             modalDialog(
#               title = 'Failed to search place',
#               'Address should not be left blank.',
#               easyClose = TRUE,
#               footer = div(
#                 modalButton('Close')
#               )
#             )
#           )
#         }
#       } else {
#         # empty place name
#         showModal(
#           modalDialog(
#             title = 'Failed to search place',
#             'Place name should not be left blank.',
#             easyClose = TRUE,
#             footer = div(
#               modalButton('Close')
#             )
#           )
#         )
#       }
#     }
#   )
#   
#   # week of the day picker
#   observeEvent(
#     input$id_week_of_day, {
#       # get day of week
#       # day_week <- weekdays(Sys.Date())
#       day_number <- get_week_of_day(input$id_week_of_day)
#       
#       # get place information
#       df_place <- popular_times_graph(
#         place_name,
#         place_address,
#         input$id_week_of_day,
#         day_number
#       )
#       
#       # show bar graph
#       output$id_graph <- renderImage(
#         list(src = df_place$file, width = '100%', height = '300px'),
#         deleteFile = FALSE
#       )
#     }
#   )
# }
# 
# # shinyApp(ui = ui, server = server)
# gpt_shiny <- shinyApp(ui = ui, server = server)