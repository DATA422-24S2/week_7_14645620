# Load necessary libraries
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
  addTiles() %>%  # Add default OpenStreetMap tiles
  setView(lng = 174.885971, lat = -40.900557, zoom = 5)  # Center the map on New Zealand with a specified zoom level

# Display the basic map
nz_map

# Create a dataset for major New Zealand cities with their population
nz_pop <- data.frame(
  city = c("Auckland", "Wellington", "Christchurch"),
  lat = c(-36.8485, -41.2865, -43.5321),
  lng = c(174.7633, 174.7762, 172.6362),
  population = c(1628900, 215100, 381800)
)

# Create a map with markers for major cities
nz_map_pop <- leaflet(nz_pop) %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  setView(lng = 174.885971, lat = -40.900557, zoom = 5) %>%  # Center the map on New Zealand
  addMarkers(~lng, ~lat, popup = ~paste(city, "<br>Population:", population))  # Add markers with popup information

# Display the map with markers
nz_map_pop

# Create a heatmap based on population density of the cities
nz_heatmap <- leaflet(nz_pop) %>%
  addTiles() %>%  # Add default OpenStreetMap tiles
  setView(lng = 174.885971, lat = -40.900557, zoom = 5) %>%  # Center the map on New Zealand
  addHeatmap(lng = ~lng, lat = ~lat, intensity = ~population, blur = 20, max = 0.5)  # Add heatmap layer

# Display the heatmap
nz_heatmap

# Load the geoJSON file containing territorial boundaries for New Zealand
nz_ta <- st_read("/Volumes/arjun/DATA201/week_7/nz_ta.geojson")

# Load the CSV file containing population data
pop_data <- read.csv("/Volumes/arjun/DATA201/week_7/nz_territory_2016_population.csv")

# Rename columns in the population data to match those in the geoJSON file
pop_data <- pop_data %>%
  rename(
    TA2016_NAM = "nz_territory",  # Rename 'nz_territory' to 'TA2016_NAM' to match geoJSON column
    population = "X2016_population",  # Rename 'X2016_population' to 'population'
    population_change_number = "X2016_population_change_number",  # Rename 'X2016_population_change_number'
    population_change_percent = "X2016_population_change_percent"  # Rename 'X2016_population_change_percent'
  )

# Merge the spatial data with the population data on the 'TA2016_NAM' column
nz_data <- nz_ta %>%
  left_join(pop_data, by = "TA2016_NAM")  # Merge based on the territorial name

# View the result of the merge to ensure proper integration of data
print(head(nz_data))

# Define a color palette for the choropleth map, using 'viridis' color scheme and population as the domain
pal <- colorNumeric(palette = "viridis", domain = nz_data$population)

# Create the choropleth map
choropleth_map <- leaflet(data = nz_data) %>%
  addProviderTiles(providers$OpenStreetMap) %>%  # Add base map layer
  addPolygons(
    fillColor = ~pal(population),  # Set polygon colors based on population data
    fillOpacity = 0.7,             # Set the opacity of the fill color
    color = "#BDBDC3",             # Border color of polygons
    weight = 1,                    # Border weight
    popup = ~paste(TA2016_NAM, "<br>Population:", population)  # Popup with region name and population
  ) %>%
  addLegend(
    pal = pal,                     # Add a legend to the map
    values = ~population,         # Values to use for color scale
    title = "Population",         # Title of the legend
    position = "bottomright"       # Position of the legend on the map
  ) %>%
  setView(lng = 174.885971, lat = -40.900557, zoom = 5)  # Set initial view of the map

# Display the choropleth map
print(choropleth_map)

# Read the geoJSON file into an sf object
nz_ta <- st_read(geojson_path)

# Display the structure of the sf object to understand its contents
print(nz_ta)

# Create a black and white plot of the NZ territories
ggplot(data = nz_ta) + 
  geom_sf(fill = "white", color = "black") +  # Fill regions with white and borders with black
  theme_void()  # Remove axes, labels, and background

# Print summary statistics to check the distribution
summary(pop_data$population)

# Create a histogram of the population distribution
hist(pop_data$population, main = "Population Distribution", xlab = "Population", col = "lightblue", border = "black")

# Add a log-transformed population column
nz_data$log_population <- log1p(nz_data$population)

# Define a color palette with log scale
pal <- colorNumeric(palette = "viridis", domain = nz_data$log_population)

# Create the choropleth map with log scale
choropleth_map <- leaflet(data = nz_data) %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  addPolygons(
    fillColor = ~pal(log1p(population)),  # Use log-transformed population for color
    fillOpacity = 0.7,
    color = "#BDBDC3",
    weight = 1,
    popup = ~paste(TA2016_NAM, "<br>Population:", population)
  ) %>%
  addLegend(
    pal = pal, 
    values = ~log1p(population),
    title = "Population (log scale)",
    position = "bottomright"
  ) %>%
  setView(lng = 174.885971, lat = -40.900557, zoom = 5)

# Display the map
print(choropleth_map)

# Rename columns for consistency and clarity (although here we are renaming to the same names)
pop_data_clean <- pop_data %>%
  rename(
    TA2016_NAM = "TA2016_NAM",  # Keeping the column name TA2016_NAM unchanged
    population = "population",  # Keeping the column name population unchanged
    population_change_number = "population_change_number",  # Keeping the column name population_change_number unchanged
    population_change_percent = "population_change_percent"  # Keeping the column name population_change_percent unchanged
  )

# Remove rows with missing population data to clean the dataset
pop_data_clean <- pop_data_clean %>%
  filter(!is.na(population))  # Ensures there are no missing population values

# Create a histogram to visualize the distribution of the population across territories
hist(pop_data_clean$population, 
     main = "Population Distribution",  # Title of the histogram
     xlab = "Population",  # Label for the x-axis
     col = "lightblue",  # Color of the bars
     border = "black")  # Color of the border of the bars



# Merge geospatial data (nz_ta) with numeric data (pop_data_clean)
# The left_join ensures that all regions from nz_ta are included, even if there's no matching population data
nz_data_merged <- nz_ta %>%
  left_join(pop_data_clean, by = "TA2016_NAM")  # Join on the TA2016_NAM column which is common in both datasets

# Check the first few rows of the merged data to verify the join
head(nz_data_merged)

