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

# Create a heatmap based on population density
nz_heatmap <- leaflet(nz_pop) %>%
  addTiles() %>%
  setView(lng = 174.885971, lat = -40.900557, zoom = 5) %>%
  addHeatmap(lng = ~lng, lat = ~lat, intensity = ~population, blur = 20, max = 0.5)

# Display the heatmap
nz_heatmap

# Print column names to verify
print(names(nz_geo))
print(names(nz_population))

# Rename columns in the population data to match the geospatial data
nz_population <- nz_population %>%
  rename(TA2016 = TA2016, population = population) # Adjust these names if needed

# Merge the geospatial and population data
nz_geo <- nz_geo %>%
  left_join(nz_population, by = "TA2016")

# Basic choropleth map
nz_choropleth <- ggplot(nz_geo) +
  geom_sf(aes(fill = population), color = "white") +
  theme_void() +
  labs(title = "Population Distribution in New Zealand Territories", fill = "Population") +
  scale_fill_viridis_c(option = "plasma")  # Optional: use a color scale from the viridis package

# Display the choropleth map
print(nz_choropleth)
