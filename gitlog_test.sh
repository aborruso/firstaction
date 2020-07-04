#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

### crea log git per i file CSV, in formato JSON ###

git log --since="2020-06-21T13:03:51 +0000" --date=iso --all --no-merges >"$folder"/processing/log.txt
