#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing
mkdir -p "$folder"/docs
mkdir -p "$folder"/processing/diff

#mlr --opprint --barred  put -S '$yearmonth=strftime(strptime(regextract($input,"^.*:[0-9]{2}"),"%Y-%m-%dT%k:%M:%S"),"%Y-%m")'
mlr --csv put '$year=strftime(strptime(regextract($date,"^.*:[0-9]{2}"),"%Y-%m-%d %k:%M:%S"),"%Y");$month=strftime(strptime(regextract($date,"^.*:[0-9]{2}"),"%Y-%m-%d %k:%M:%S"),"%m")' "$folder"/processing/log.csv >"$folder"/processing/diff/log.csv

mlr --c2n --ofs "\t" cut -o -f year,month,path then uniq -a then sort -n year,month -f path "$folder"/processing/diff/log.csv >"$folder"/processing/diff/loop.tsv

while IFS=$'\t' read -r year month resource; do
    echo "$resource"
done <"$folder"/processing/diff/loop.tsv
