#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

# verifica se le API di openregio rispondono
response=$(curl -k --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null https://openregio.anbsc.it/statistiche/export/5/immobili/0/0/0/json)

# se rispondono scarica i dati, fai il sort per m_bene o s_bene e converti in CSV
if [[ "$response" == 200 ]]; then
  curl -kL https://openregio.anbsc.it/statistiche/export/5/immobili/0/0/0/json | jq -c 'sort_by(.m_bene)|.[]' >openregio_immobiliDestinati.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/1/immobili/0/0/0/json | jq -c 'sort_by(.s_bene)|.[]' >openregio_immobiliGestione.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/5/aziende/0/0/0/json | jq -c 'sort_by(.m_bene)|.[]' >openregio_aziendeDestinate.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/1/aziende/0/0/0/json | jq -c 'sort_by(.s_bene)|.[]' >openregio_aziendeGestione.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export_procedure/0/0/0/0/json | jq -c '.[]' >openregio_procedureGestione.jsonl
  mlr --j2c unsparsify then clean-whitespace then sort -f m_bene openregio_immobiliDestinati.jsonl >openregio_immobiliDestinati.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f s_bene openregio_immobiliGestione.jsonl >openregio_immobiliGestione.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f m_bene openregio_aziendeDestinate.jsonl >openregio_aziendeDestinate.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f s_bene openregio_aziendeGestione.jsonl >openregio_aziendeGestione.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f nome_regione,distretto,ufficio_giudiziario,tipologia_procedura,provvedimento,procedura_rg openregio_procedureGestione.jsonl >openregio_procedureGestione.csv
fi

if [ $(git status --porcelain | wc -l) -eq "0" ]; then
  echo "  🟢 Git repo is clean."
else
  echo "  🔴 Git repo dirty. Quit."
  curl -X POST -H "Content-Type: application/json" -d '{"value1":"novità sul repo openregio"}' https://maker.ifttt.com/trigger/alert/with/key/"$SUPER_SECRET"
fi
