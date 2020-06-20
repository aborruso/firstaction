#!/bin/bash

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm "$folder"/gitlog.tsv
rm "$folder"/gitlogt.tsv

for i in ./*.csv; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  echo "$filename.$extension"
  git log --date=iso --no-merges --pretty=format:"%h%x09%an%x09%ad%x09%s" -- "$i" | ./mlr --tsv -N put '$filename="'"$filename"'"' >>"$folder"/gitlog.tsv
  git log --date=iso --no-merges --pretty=format:"%h%x09%an%x09%ad%x09%s" -- "$i" >>"$folder"/gitlogt.tsv
done

./mlr -I --tsv -N sort -f 3,5 "$folder"/gitlog.tsv

