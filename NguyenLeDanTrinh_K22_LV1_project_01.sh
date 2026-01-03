#!/bin/bash
DATA_URL='https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv'
DATA_FILE='tmdb-movies.csv'

echo "---------TMDB MOVIES DATA ANALYSIS----------"
#0.0 Download data:
curl -L -o "$DATA_FILE" "$DATA_URL"

#0.1 Cleand data
# Remove new line in field
awk '/^[0-9]+,/ {if (NR != 1) print ""; printf "%s",$0; next} {printf " %s",$0}' tmdb-movies.csv > rm-nl-tmdb-movies.csv
wc -l rm-nl-tmdb-movies.csv
# Remove commas inside double quote
awk '
{
	out =""
	inquote = 0
	for (i = 1; i <= length($0); i++) {
		c = substr($0, i, 1)
		
		if (c == "\"") {
			inquote = !inquote
			out = out c
		} else if (c == "," && inquote) {
			out = out "/"
		} else {
			out = out c
		}
	}
	print out
}
' rm-nl-tmdb-movies.csv > cleaned-tmdb-movies.csv

#1. Sort movies by release_date desc:
awk -F',' '
{
	split($16, d, "/")
	mm = d[1] 
	dd = d[2]
	yy = d[3]
	
	curr_yy = 26
	year = (yy > curr_yy ? 1900 + yy : 2000 + yy)
	
	printf "%04d%02d%02d,%s\n", year, mm, dd, $0
}
' cleaned-tmdb-movies.csv \
| sort -t',' -r -k1,1 | cut -d',' -f2- > tmdb-movies-sorted-by-release-date-desc.csv

#2. Filter movies with vote_average > 7.5
awk -F',' '$18 > 7.5 {print $0}' cleaned-tmdb-movies.csv > tmdb-movies-vote-avg-gt-7-5.csv

#3. Movie with max and min revenue
# The highest revenue
echo "-------------THE HIGHEST REVENUE------------"
# Max revenue
max=$(awk -F',' 'NR > 1 && $5 != 0 {print $5}' cleaned-tmdb-movies.csv | sort -nr | head -n 1)

#Get all max revenue value 
awk -F',' -v max="$max" '$5==max {print $6, $5}' cleaned-tmdb-movies.csv

# The lowest revenue
echo "-------------THE LOWEST REVENUE-------------"
# Min revenue
min=$(awk -F',' 'NR > 1 && $5 != 0 {print $5}' cleaned-tmdb-movies.csv | sort -n | head -n 1)

# Get all min revenue value
awk -F',' -v min="$min" '$5==min {print $6, $5}' cleaned-tmdb-movies.csv

#4. Total revenue:
echo "-------------TOTAL REVENUE-------------"
awk -F',' '{sum += $5} END {print sum}' cleaned-tmdb-movies.csv 

#5. Top 10 profitable movies
echo "-------------TOP 10 PROFITABLE MOVIES------------"
awk -F',' 'NR > 1 && $6 != "" {profit = $5 -$4; print profit, $6}' cleaned-tmdb-movies.csv | sort -nr | head -n 10

#6. Director and actor with most movies
# Director with most movies:
echo "-------------DIRECTOR WITH MOST MOVIES-------------"
awk -F',' 'NR > 1 {gsub(/\|/,"\n",$9); print $9}' cleaned-tmdb-movies.csv | sort | uniq -c | sort -nr | head -n 1

echo "-------------ACTOR WITH MOST MOVIES--------------"
awk -F',' 'NR > 1 {gsub(/\|/,"\n",$7); if ($7 != "") print $7}' cleaned-tmdb-movies.csv | sort | uniq -c | sort -nr | head -n 1

#7. Movies by genres
echo "-------------MOVIES BY GENRES---------------"
awk -F',' 'NR > 1 && $14 != "" {gsub(/\|/,"\n",$14); print $14}' cleaned-tmdb-movies.csv | sort | uniq -c | sort -nr

#8. Top 10 companies that produced most movies in the latest year
echo "-------------TOP 10 COMPANIES THAT PRODUCED MOST MOVIES IN THE LATEST YEAR-----------"
latest_year=$(sort -t',' -k19,19nr cleaned-tmdb-movies.csv | awk -F',' 'NR==1 {print$19}')

awk -F',' -v year="$latest_year" '
{ 
	gsub(/\|/,"\n",$15) 
	if ($19 == year && $15 != "") print $15
}
' cleaned-tmdb-movies.csv | sort | uniq -c | sort -nr | head -n 10
#9. Top 3 most popular movies by year
echo "------------TOP 3 MOST POPULAR MOVIES BY YEAR--------------"
awk -F',' 'NR > 1 && $3 != "" && $19 != "" {
	print $19 "," $3 "," $6
}
' cleaned-tmdb-movies.csv | sort -t',' -k1,1r -k2,2nr | awk -F',' '
{
	count[$1]++
	if (count[$1] <= 3) {
		print "Year: ", $1, "|Popularity: ", $2, "|Movies: ", $3
	}
}
' 
