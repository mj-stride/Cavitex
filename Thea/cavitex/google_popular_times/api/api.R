library(httr)
library(jsonlite)

get_location <- function() {
  res <- POST('http://localhost:8000/location')
  data <- fromJSON(rawToChar(res$content))
  
  return(Vectorize(data))
}