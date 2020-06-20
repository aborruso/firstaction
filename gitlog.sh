#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata/gitlog

for i in ./*.csv; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  echo "$filename.$extension"
  echo "commit id,author,date,comment,changed files,linesAdded,linesDeleted" >"$folder"/rawdata/gitlog/"$filename".csv
  git log --date=iso --all --no-merges --pretty="%x40%h%x2C%an%x2C%ad%x2C%x22%s%x22%x2C" --shortstat -- "$i" | tr "\n" " " | tr "@" "\n" >>"$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ files changed//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ file changed//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ insertions(+)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ insertion(+)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ deletions(-)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ deletion(-)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i '/^$/d' "$folder"/rawdata/gitlog/"$filename".csv
  mlr -I --csv --allow-ragged-csv-input clean-whitespace then put '$fileName="'"$filename"'"' "$folder"/rawdata/gitlog/"$filename".csv
done

mlr --c2t sort -f date "$folder"/rawdata/gitlog/*.csv >"$folder"/gitlog.tsv
