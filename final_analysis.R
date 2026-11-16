library(tidyverse)

# Load data
restaurants <- readRDS("data/new_orleans/business.rds")
reviews <- readRDS("data/new_orleans/reviews.rds")

# Split categories
restaurant_categories <- restaurants |>
  select(business_id, name, categories) |>
  separate_rows(categories, sep = ",") |>
  mutate(category = str_to_lower(str_trim(categories)))

# Categories I chose
selected_categories <- c(
  "seafood",
  "cajun/creole",
  "southern"
)

# Count restaurants in each category
category_counts <- restaurant_categories |>
  filter(category %in% selected_categories) |>
  count(category, sort = TRUE)

category_counts

# Keep restaurants in these categories
selected_restaurants <- restaurant_categories |>
  filter(category %in% selected_categories) |>
  distinct(business_id) |>
  inner_join(restaurants, by = "business_id")

nrow(selected_restaurants)

# Check which categories appear together
category_pairs <- restaurant_categories |>
  filter(category %in% selected_categories) |>
  select(business_id, category) |>
  inner_join(
    restaurant_categories |>
      filter(category %in% selected_categories) |>
      select(business_id, category2 = category),
    by = "business_id"
  ) |>
  filter(category < category2) |>
  count(category, category2, sort = TRUE)

category_pairs

library(sf)
library(tigris)

# Turn restaurants into map points
selected_sf <- st_as_sf(
  selected_restaurants,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

# Get ZIP areas
zips <- zctas(
  cb = TRUE,
  year = 2020
)

zips <- st_transform(zips, 4326)

# Match restaurants to ZIP areas
selected_zip <- st_join(
  selected_sf,
  zips["ZCTA5CE20"]
)

# Check how many ZIP areas we have
selected_zip |>
  st_drop_geometry() |>
  summarise(
    restaurants = n(),
    zip_areas = n_distinct(ZCTA5CE20, na.rm = TRUE)
  )

# Keep reviews for the selected restaurants
category_reviews <- reviews |>
  semi_join(selected_restaurants, by = "business_id")

# Average rating using all reviewers
all_reviewer_summary <- category_reviews |>
  group_by(business_id) |>
  summarise(
    number_of_reviews = n(),
    average_stars = mean(stars, na.rm = TRUE),
    .groups = "drop"
  )

# Count reviews for each reviewer
reviewer_activity <- category_reviews |>
  count(user_id, name = "review_count")

# Keep reviewers with at least 5 reviews
eligible_reviewers <- reviewer_activity |>
  filter(review_count >= 5)

# Reviews from active reviewers
selected_reviewer_reviews <- category_reviews |>
  semi_join(eligible_reviewers, by = "user_id")

# Check how many reviewers and reviews remain
nrow(eligible_reviewers)

100 * nrow(selected_reviewer_reviews) / nrow(category_reviews)

# Find each reviewer's average rating
reviewer_baselines <- category_reviews |>
  group_by(user_id) |>
  summarise(
    reviewer_mean = mean(stars, na.rm = TRUE),
    .groups = "drop"
  )

# Create normalized scores
adjusted_reviews <- category_reviews |>
  left_join(reviewer_baselines, by = "user_id") |>
  mutate(
    normalized_score = stars - reviewer_mean
  ) |>
  semi_join(eligible_reviewers, by = "user_id")

# Make final restaurant summary
restaurant_summary <- selected_restaurants |>
  select(
    business_id, name, address,
    latitude, longitude
  ) |>
  left_join(
    all_reviewer_summary,
    by = "business_id"
  ) |>
  left_join(
    adjusted_reviews |>
      group_by(business_id) |>
      summarise(
        eligible_reviews = n(),
        average_normalized_score = mean(
          normalized_score,
          na.rm = TRUE
        ),
        .groups = "drop"
      ),
    by = "business_id"
  )

# Top 10 restaurants
top10 <- restaurant_summary |>
  filter(eligible_reviews >= 5) |>
  arrange(
    desc(average_normalized_score),
    desc(number_of_reviews)
  ) |>
  slice_head(n = 10)

top10

# Compare raw ratings and normalized scores
ggplot(
  restaurant_summary,
  aes(
    x = average_stars,
    y = average_normalized_score
  )
) +
  geom_hline(yintercept = 0) +
  geom_point(
    aes(size = number_of_reviews),
    alpha = 0.6
  ) +
  labs(
    title = "Raw Ratings vs Reviewer-Adjusted Scores",
    x = "Average Yelp Stars",
    y = "Average Normalized Score",
    size = "Reviews"
  ) +
  theme_minimal()

# Top 10 restaurant map
top10_sf <- st_as_sf(
  top10,
  coords = c("longitude", "latitude"),
  crs = 4326,
  remove = FALSE
)

# ZIP areas that have our selected restaurants
selected_zip_ids <- selected_zip |>
  st_drop_geometry() |>
  pull(ZCTA5CE20) |>
  unique()

selected_zip_map <- zips |>
  filter(ZCTA5CE20 %in% selected_zip_ids)

# Make the map
ggplot() +
  geom_sf(
    data = selected_zip_map,
    fill = "grey95"
  ) +
  geom_sf(
    data = top10_sf,
    size = 3
  ) +
  labs(
    title = "Top 10 Selected Restaurants in New Orleans",
    subtitle = "ZIP/ZCTA boundaries"
  ) +
  theme_minimal()