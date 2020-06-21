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
  echo "commitId,author,date,comment,changedFiles,linesAdded,linesDeleted" >"$folder"/rawdata/gitlog/"$filename".csv
  git log --since="2020-06-18T21:35:51 +0000" --date=iso --all --no-merges --pretty="%x40%h%x2C%an%x2C%ad%x2C%x22%s%x22%x2C" --shortstat -- "$i" | tr "\n" " " | tr "@" "\n" >>"$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ files changed//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ file changed//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ insertions(+)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ insertion(+)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ deletions(-)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i 's/ deletion(-)//g' "$folder"/rawdata/gitlog/"$filename".csv
  sed -i '/^$/d' "$folder"/rawdata/gitlog/"$filename".csv
  mlr -I --csv --allow-ragged-csv-input clean-whitespace then put '$fileName="'"$filename"'"' "$folder"/rawdata/gitlog/"$filename".csv
done

mlr --c2t sort -r date then put '$URL="https://github.com/aborruso/firstaction/commit/".$commitId' "$folder"/rawdata/gitlog/*.csv >"$folder"/gitlog.tsv

# altrà modalità di creazione log, in formato json

mkdir -p "$folder"/rawdata

git log --since="2020-06-21T13:03:51 +0000" --date=iso --all --no-merges \
  --pretty=format:'{%n  "commit": "%H",%n  "author": "%aN <%aE>",%n  "date": "%ad",%n  "message": "%f"%n},' \
  -- '*.csv' |
  perl -pe 'BEGIN{print "["}; END{print "]\n"}' |
  perl -pe 's/},]/}]/' | jq . >"$folder"/rawdata/gitlog.json

git log --since="2020-06-21T13:03:51 +0000" --date=iso --all --no-merges \
  --numstat \
  --format='%H' \
  -- '*.csv' |
  perl -lawne '
        if (defined $F[1]) {
            print qq#{"insertions": "$F[0]", "deletions": "$F[1]", "path": "$F[2]"},#
        } elsif (defined $F[0]) {
            print qq#],\n"$F[0]": [#
        };
        END{print qq#],#}' |
  tail -n +2 |
  perl -wpe 'BEGIN{print "{"}; END{print "}"}' |
  tr '\n' ' ' |
  perl -wpe 's#(]|}),\s*(]|})#$1$2#g' |
  perl -wpe 's#,\s*?}$#}#' | jq . >"$folder"/rawdata/gitlogstat.json

jq --slurp '.[1] as $logstat | .[0] | map(.paths = $logstat[.commit])' "$folder"/rawdata/gitlog.json "$folder"/rawdata/gitlogstat.json >"$folder"/tmplog.json
jq <"$folder"/tmplog.json -c '.[]' >"$folder"/log.json

mlr <"$folder"/log.json --j2c unsparsify >"$folder"/tmplog.csv

mlr <"$folder"/tmplog.csv --csv cat -n then reshape -r ":" -o item,value then filter -x '$value==""' then put '$item=sub($item,"paths:","")' then nest --explode --values --across-fields --nested-fs ":"  -f item then reshape -s item_2,value then cut -x -f n,item_1 then sort -r date then filter '$author=~"actions"' >"$folder"/tmp2.csv
