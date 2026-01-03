<div align="center" >
  <h1><strong>TMDB Movies – Linux Command Line</strong></h1>
</div>

## Overview

This project analyzes the TMDB Movies dataset using Linux command-line tools and [csvkit](https://csvkit.readthedocs.io/en/latest/) \
All analysis steps are automated in a single shell script.

## Why csvkit?
The `overview` column contains embedded commas, which cause traditional tools such as `awk`, `cut -d','`, or `sort` to parse the data incorrectly.  
`csvkit` safely parses CSV files and provides useful utilities such as `csvsort`, `csvstat`, and `csvlook` for reliable analysis and readable output in pipelines

## Requirements
- Linux or macOS
- Python & pip
- csvkit installed

## Install csvkit:

**Linux:**
```
pip install csvkit
```

**macOS:**
```
brew install csvkit
```
**Verify installation:**
```
csvcut --version
```
## How to Run:
Grant execute permission and run the script:
```
chmod +x NguyenLeDanTrinh_K22_LV1_project_01.sh
./NguyenLeDanTrinh_K22_LV1_project_01.sh
```

## Dataset Columns
Download dataset source:
```
curl -L -o tmdb-movies.csv https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv
```
Check dataset columns:
```
head -n 1 tmdb-movies.csv
```
Key columns used: 
| #  | Column Name |
|----|------------|
| 1  | id |
| 2  | imdb_id |
| 3  | popularity |
| 4  | budget |
| 5  | revenue |
| 6  | original_title |
| 7  | cast |
| 8  | homepage |
| 9  | director |
| 10 | tagline |
| 11 | keywords |
| 12 | overview |
| 13 | runtime |
| 14 | genres |
| 15 | production_companies |
| 16 | release_date |
| 17 | vote_count |
| 18 | vote_average |
| 19 | release_year |
| 20 | budget_adj |
| 21 | revenue_adj |

## Analysis Tasks
1. Sort movies by release date (descending)
2. Filter movies with vote average > 7.5
3. Highest & lowest revenue movies (excluding zero revenue)
4. Total revenue
5. Top 10 highest profit movies
6. Most prolific director & actor
7. Count movies by genres
8. Additional Ideas
- Top 10 companies that produced most movies in the latest year
- Top 3 movies by popularity per year
## Conclusion
This project showcases practical data analysis using Linux shell pipelines and **csvkit** to handle complex CSV structures reliably.
