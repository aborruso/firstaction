#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

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

jq --slurp '.[1] as $logstat | .[0] | map(.paths = $logstat[.commit])' "$folder"/rawdata/gitlog.json "$folder"/rawdata/gitlogstat.json >"$folder"/processing/tmplog.json

jq <"$folder"/processing/tmplog.json -c '.[]' >"$folder"/processing/log.json

mlr <"$folder"/processing/log.json --j2c unsparsify >"$folder"/processing/tmplog.csv

mlr <"$folder"/processing/tmplog.csv --csv cat -n then reshape -r ":" -o item,value then filter -x '$value==""' then put '$item=sub($item,"paths:","")' then nest --explode --values --across-fields --nested-fs ":"  -f item then reshape -s item_2,value then cut -x -f n,item_1 then sort -r date then filter '$author=~"actions"' then put '$URLcommit="https://github.com/aborruso/firstaction/commit/".$commit' >"$folder"/processing/tmp2.csv
