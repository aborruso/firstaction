#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata



git log --since="2020-06-18T21:35:51 +0000" --date=iso --all --no-merges  \
  --pretty=format:'{%n  "commit": "%H",%n  "author": "%aN <%aE>",%n  "date": "%ad",%n  "message": "%f"%n},' \
  -- '*.csv' |
  perl -pe 'BEGIN{print "["}; END{print "]\n"}' |
  perl -pe 's/},]/}]/' | jq . >"$folder"/rawdata/gitlog.json

git log --since="2020-06-18T21:35:51 +0000" --date=iso --all --no-merges  \
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

jq --slurp '.[1] as $logstat | .[0] | map(.paths = $logstat[.commit])' "$folder"/rawdata/gitlog.json "$folder"/rawdata/gitlogstat.json | jq -c '.[]' >"$folder"/log.json
