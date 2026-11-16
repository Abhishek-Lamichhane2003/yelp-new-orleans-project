# Yelp New Orleans Restaurant Analysis

## About the Project

This project looks at Seafood, Cajun/Creole, and Southern restaurants in New Orleans using Yelp data.

The main question I wanted to answer was:

**Where can someone find the best seafood, Cajun/Creole, and Southern restaurants in New Orleans, and which ZIP/ZCTA areas are best for finding them?**

I used restaurant information, Yelp reviews, geographic data, and reviewer-adjusted scores to compare restaurants and locations.

## Main Results

Some of the main things I found were:

- 648 restaurants matched at least one of the three selected categories.
- These restaurants were located across 24 ZIP/ZCTA areas.
- I compared ZIP/ZCTA areas with census tracts and ended up using ZIP/ZCTA for the main analysis.
- All 2,259 restaurants matched to a ZIP/ZCTA, while 57 did not match to a census tract.
- I used reviewers with at least 5 reviews in the selected categories for the reviewer-adjusted analysis.
- This gave me 7,052 eligible reviewers.
- For the final restaurant ranking, I only kept restaurants with at least 10 reviews from eligible reviewers.
- Some restaurant rankings changed after adjusting for the way different reviewers normally give ratings.

## What I Did

I first filtered the Yelp data to restaurants in New Orleans.

Then I focused on three categories:

- Seafood
- Cajun/Creole
- Southern

I checked how much these categories overlapped and then kept restaurants that belonged to at least one of them.

After that, I compared ZIP/ZCTA areas with census tracts to decide which geographic system worked better for the project.

For the review analysis, I also adjusted ratings based on each reviewer's normal rating behavior. This helped me compare restaurants in a different way instead of only using the regular Yelp star average.

## Reviewer Adjustment

Different Yelp users rate restaurants differently. Some people usually give high ratings, while others are more strict.

To account for this, I calculated each reviewer's average rating and compared each individual review with that average.

The basic idea was:

```text
Normalized Score = Review Rating - Reviewer's Average Rating
```

A positive score means the reviewer rated that restaurant higher than they normally rate restaurants.

A negative score means they rated it lower than usual.

## Final Ranking

For the final Top 10 list, I only included restaurants that had at least 10 reviews from eligible reviewers.

I ranked the restaurants mainly using their average normalized score and used the total number of reviews as a second sorting value.

The full report also includes a map showing where the Top 10 restaurants are located.

## Files in This Project

```text
yelp-new-orleans-project/
│
├── R/
│   ├── import.R
│   ├── geographic_analysis.R
│   └── final_analysis.R
│
├── data/
│   └── new_orleans/
│       ├── business.rds
│       └── reviews.rds
│
├── yelp_new_orleans_project.qmd
├── yelp_new_orleans_project.html
├── homework6.qmd
├── homework6.html
└── README.md
```

## Data

The project uses:

- Yelp Open Dataset
- U.S. Census geographic data
- `tigris` R package

The original Yelp JSON files are not included in the repository because they are very large.

I filtered the original files and saved smaller RDS files that contain the New Orleans data needed for this project.

## Tools Used

- R
- RStudio
- tidyverse
- sf
- tigris
- Quarto
- Git and GitHub

## Full Report

The full analysis can be viewed here:

[View the Full Project Report](yelp_new_orleans_project.html)

The Quarto source file is:

`yelp_new_orleans_project.qmd`

## Author

Abhishek Lamichhane
