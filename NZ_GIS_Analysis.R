library(leaflet)
library(sf)
library(ggplot2)
library(dplyr)
library(leaflet.extras)
library(plotly)
library(viridis)
library(leaflet)

# Create a basic map centered on New Zealand
nz_map <- leaflet() %>%
  addTiles() %>%
  setView(lng = 174.885971, lat = -40.900557, zoom = 5)  # Adjust the zoom as needed

# Display the map
nz_map

# Create a dataset for major New Zealand cities
nz_pop <- data.frame(
  city = c("Auckland", "Wellington", "Christchurch"),
  lat = c(-36.8485, -41.2865, -43.5321),
  lng = c(174.7633, 174.7762, 172.6362),
  population = c(1628900, 215100, 381800)
)

# Create a map with markers
nz_map_pop <- leaflet(nz_pop) %>%
  addTiles() %>%
  setView(lng = 174.885971, lat = -40.900557, zoom = 5) %>%
  addMarkers(~lng, ~lat, popup = ~paste(city, "<br>Population:", population))

# Display the map with markers
nz_map_pop
