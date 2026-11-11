library(tidyverse)
library(sf)
library(tigris)

# Load New Orleans restaurant data
restaurants <- readRDS("data/new_orleans/business.rds")

# Check the data
dim(restaurants)
head(restaurants)

# Convert restaurants to spatial points
restaurants_sf <- st_as_sf(
  restaurants,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

restaurants_sf

# Get ZIP code areas
zips <- zctas(
  cb = TRUE,
  year = 2020
)

# Look at the data
zips

# Make ZIP areas use the same coordinate system
zips <- st_transform(zips, 4326)

# Match restaurants to ZIP areas
restaurants_zip <- st_join(
  restaurants_sf,
  zips["ZCTA5CE20"]
)

# Check the results
head(restaurants_zip)

# Count restaurants in each ZIP area
zip_summary <- restaurants_zip |>
  st_drop_geometry() |>
  group_by(ZCTA5CE20) |>
  summarise(
    restaurants = n(),
    average_rating = mean(stars)
  ) |>
  arrange(desc(restaurants))

zip_summary

# Check for restaurants that did not match a ZIP area
sum(is.na(restaurants_zip$ZCTA5CE20))

# Add restaurant counts to ZIP map
zip_map <- zips |>
  inner_join(zip_summary, by = "ZCTA5CE20")

# Map restaurant counts by ZIP area
ggplot(zip_map) +
  geom_sf(aes(fill = restaurants)) +
  labs(
    title = "New Orleans Restaurants by ZIP Area",
    fill = "Restaurants"
  ) +
  theme_minimal()

# Get census tracts for Orleans Parish
tracts <- tracts(
  state = "LA",
  county = "Orleans",
  cb = TRUE,
  year = 2020
)

# Use the same coordinate system
tracts <- st_transform(tracts, 4326)

tracts

# Match restaurants to census tracts
restaurants_tract <- st_join(
  restaurants_sf,
  tracts["GEOID"]
)

# Check the results
head(restaurants_tract)

# Count restaurants in each census tract
tract_summary <- restaurants_tract |>
  st_drop_geometry() |>
  group_by(GEOID) |>
  summarise(
    restaurants = n(),
    average_rating = mean(stars)
  ) |>
  arrange(desc(restaurants))

tract_summary

# Check for restaurants that did not match a tract
sum(is.na(restaurants_tract$GEOID))

# Add restaurant counts to census tract map
tract_map <- tracts |>
  inner_join(
    tract_summary |> filter(!is.na(GEOID)),
    by = "GEOID"
  )

# Map restaurant counts by census tract
ggplot(tract_map) +
  geom_sf(aes(fill = restaurants)) +
  labs(
    title = "New Orleans Restaurants by Census Tract",
    fill = "Restaurants"
  ) +
  theme_minimal()

# Compare the two geographic systems
comparison <- tibble(
  geography = c("ZIP/ZCTA", "Census Tract"),
  areas_with_restaurants = c(
    sum(!is.na(zip_summary$ZCTA5CE20)),
    sum(!is.na(tract_summary$GEOID))
  ),
  unmatched_restaurants = c(
    sum(is.na(restaurants_zip$ZCTA5CE20)),
    sum(is.na(restaurants_tract$GEOID))
  )
)

comparison