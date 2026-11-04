library(tidyverse)
library(jsonlite)

# Load business data
business <- stream_in(
  file("data/raw/yelp_academic_dataset_business.json"),
  verbose = FALSE
)

# Keep the columns needed
business <- business |>
  select(business_id, name, address, city, state,
         postal_code, latitude, longitude, stars,
         review_count, categories)

# Filter New Orleans restaurants
new_orleans_business <- business |>
  filter(city == "New Orleans") |>
  filter(str_detect(categories, "Restaurants"))

# Check the data
dim(new_orleans_business)

# Save New Orleans business data
saveRDS(
  new_orleans_business,
  "data/new_orleans/business.rds"
)


# Reload saved New Orleans businesses
new_orleans_business <- readRDS("data/new_orleans/business.rds")

# Get New Orleans restaurant IDs
restaurant_ids <- new_orleans_business$business_id

# Empty list for the reviews we want
review_list <- list()

# Keep only New Orleans restaurant reviews
keep_reviews <- function(x) {
  
  x <- x |>
    filter(business_id %in% restaurant_ids) |>
    select(business_id, user_id, stars, date, text,
           useful, funny, cool)
  
  review_list <<- append(review_list, list(x))
}

# Read the review file in smaller pieces
jsonlite::stream_in(
  file("data/raw/yelp_academic_dataset_review.json"),
  handler = keep_reviews,
  pagesize = 10000,
  verbose = FALSE
)

# Combine all review pieces
new_orleans_reviews <- bind_rows(review_list)

# Check the data
dim(new_orleans_reviews)

# Save New Orleans reviews
saveRDS(
  new_orleans_reviews,
  "data/new_orleans/reviews.rds"
)