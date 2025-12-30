#!/bin/bash
set -e

echo "================= TMDB MOVIES DATA ANALYSIS ================"

# 0 Download data and install csvkit if not already installed 
DATA_URL="https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv"
DATA_FILE="tmdb-movies.csv"

# Check exits DATA_FILE and is not empty 
if [ ! -s "$DATA_FILE" ]; then
    echo "Downloading dataset..."
    curl -L -o "$DATA_FILE" "$DATA_URL"
else
    echo "Dataset already exists and is not empty"
fi

# Check if csvkit is installed
if ! command -v csvcut >/dev/null 2>&1; then
    echo "csvkit is not installed. Please install csvkit first."
    echo "Linux:  pip install csvkit"
    echo "macOS:  brew install csvkit"
    exit 1
fi

# 1. Sort movies by release_date desc  
csvsort -c release_date -r "$DATA_FILE" > movies_sorted_by_release_date_desc.csv 

# 2. Filter movies with vote_average > 7.5
csvgrep -c vote_average -r "^(8|9|10)(\.\d+)?$|^7\.[6-9]" "$DATA_FILE" > movies_vote_avg_gt_7_5.csv

# 3. Movie with max & min revenue
# Max revenue
echo "----------------MAX REVENUE----------------"

# Find max revenue value
max_revenue=$(csvgrep -c revenue -r "^0(\.0+)?$" -i "$DATA_FILE" | csvstat -c revenue --max | tr -d ',')

# Get movie(s) with max revenue
csvgrep -c revenue -r "^${max_revenue}$" "$DATA_FILE" | csvcut -c original_title,revenue | csvlook

# Min revenue 
echo "----------------MIN REVENUE----------------"

# Find min revenue value
min_revenue=$(csvgrep -c revenue -r "^0(\.0+)?$" -i "$DATA_FILE" | csvstat -c revenue --min | tr -d ',')

# Get movie(s) with min revenue
csvgrep -c revenue -r "^${min_revenue}$" "$DATA_FILE" | csvcut -c original_title,revenue | csvlook

# 4. Total revenue
echo "----------------TOTAL REVENUE----------------"
csvstat -c revenue --sum "$DATA_FILE"

# 5. Top 10 profitable movies
echo "----------------TOP 10 PROFITABLE MOVIES----------------"
csvcut -c original_title,budget,revenue "$DATA_FILE" | csvformat -T | tail -n +2 | awk -F'\t' '{print $3-$2 "\t" $1}' | sort -nr | head -10

# 6. Director & Actor with most movies
# Director with most movies
echo "----------------DIRECTOR WITH MOST MOVIES----------------"
csvcut -c director "$DATA_FILE" | csvformat -T | tail -n +2 | tr '|' '\n' | grep -vE '^(""|[[:space:]]*)$' | sort | uniq -c | sort -nr | head -n 1

# Actor with most movies
echo "----------------ACTOR WITH MOST MOVIES----------------"
csvcut -c cast "$DATA_FILE" | csvformat -T | tail -n +2 | tr '|' '\n' | grep -vE '^(""|[[:space:]]*)$' |  sort | uniq -c | sort -nr | head -n 1

# 7. Count movies by genres
echo "----------------COUNT MOVIES BY GENRES----------------"
csvcut -c genres "$DATA_FILE" | csvformat -T | tail -n +2 | tr '|' '\n' | grep -vE '^(""|[[:space:]]*)$' | sort | uniq -c | sort -rn

# 8. Top 10 companies that produced most movies in the latest year
echo "----------------TOP 10 COMPANIES THAT PRODUCED MOST MOVIES IN THE LATEST YEAR----------------"

# Find the latest year
latest_year=$(csvcut -c release_year "$DATA_FILE" | csvformat -T | tail -n +2 | sort -nr | head -n 1)

# Filter movies in the latest year and count production companies
csvgrep -c release_year -m $latest_year "$DATA_FILE" | csvcut -c production_companies | csvformat -T | tail -n +2 | tr '|' '\n' | grep -vE '^(""|[[:space:]]*)$' | sort | uniq -c | sort -nr | head -10

# 9. Top 3 most popular movies by year
echo "----------------TOP 3 MOST POPULAR MOVIES BY YEAR----------------"
csvsort -c release_year,popularity -r "$DATA_FILE" \
| csvcut -c release_year,original_title,popularity\
| csvformat -T \
| tail -n +2 \
| awk -F'\t' '
    {
    count[$1]++
        if (count[$1] <= 3)
        print $0
    }
'
echo "================= FINISHED ================"