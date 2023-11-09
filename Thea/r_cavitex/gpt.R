# install.packages("remotes")
# remotes::install_github("JosiahParry/populartimes")

library(populartimes)
library()
library(tidyverse)

place_id <- "ChIJY96HXyFTQDIRV9opeu-QR3g"
key <- Sys.setenv("GOOGLE_KEY" = "AIzaSyCgYGrWpFQgggGV4XieZsdYy8OfrN8xR5k")

gpt <- get_place_details(place_id, key)

print(gpt)