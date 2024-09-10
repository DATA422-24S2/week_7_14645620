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

