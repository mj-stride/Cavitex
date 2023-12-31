library(populartimes)

# get google popular times
popular_times_graph <- function(place_name, address, day_week, day_number) {
  out <- tryCatch(
    {
      # get place details
      get_place <- poptimes_from_address(place_name, address)
      df_place <- as.data.frame(get_place) %>%
        mutate(place_name = place_name) %>%
        mutate(address = address) %>%
        mutate(status = 200) # add place name and address for marker popup
      
      # get popular times
      popular_times <- as.data.frame(get_place$popular_times)
      day_popularity <- subset(popular_times,
                               day_of_week == day_number,
                               select = c(hour, popularity))
      
      # convert hour to 12 hour time
      df_popularity <- day_popularity %>%
        mutate(time = format(strptime(paste(hour, ':00:00', sep = ''), format = '%H:%M:%S'), '%I %p'))
      
      # select popularity
      popularity <- df_popularity %>% select(popularity)
      # popularity <- day_popularity %>% select(popularity)
      
      # select popularity time
      time <- df_popularity %>% select(time)
      # hour <- day_popularity %>% select(hour)
      
      # graph name (popularity_date_time)
      file_name <- format(Sys.time(), 'popularity_%Y%m%d_%H%M%S')
      file_path <- 'D:\\Codes\\cavitex\\google_popular_times\\bar_graphs\\'
      # paste directory; file_name; extension
      graph_file <- paste(file_path, file_name, '.png', sep = '')
      
      # graph png file; png size
      png(file = graph_file, height = 800, width = 1500, units = 'px')
      
      # create bar graph
      barplot.default(
        popularity$popularity,
        names.arg = time$time,
        # names.arg = hour$hour,
        ylab = 'Popularity',
        xlab = 'Hour',
        main = paste(place_name, ' - ', day_week),
        col = '#46923C'
      )
      
      # save as png file
      while (!is.null(dev.list())) dev.off()
      
      # add file
      return(df_place %>% mutate(
        file = graph_file
      ))
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
    }
  )
  
  return(out)
}