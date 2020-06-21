#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

response=$(curl -k --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null https://openregio.anbsc.it/statistiche/export/5/immobili/0/0/0/json)

if [[ "$response" == 200 ]]; then
  curl -kL https://openregio.anbsc.it/statistiche/export/5/immobili/0/0/0/json | jq -c 'sort_by(.m_bene)|.[]' >openregio_immobiliDestinati.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/1/immobili/0/0/0/json | jq -c 'sort_by(.s_bene)|.[]' >openregio_immobiliGestione.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/5/aziende/0/0/0/json | jq -c 'sort_by(.m_bene)|.[]' >openregio_aziendeDestinate.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export/5/aziende/0/0/0/json | jq -c 'sort_by(.m_bene)|.[]' >openregio_aziendeGestione.jsonl
  curl -kL https://openregio.anbsc.it/statistiche/export_procedure/0/0/0/0/json | jq -c '.[]' >openregio_procedureGestione.jsonl
  mlr --j2c unsparsify then clean-whitespace then sort -f m_bene openregio_immobiliDestinati.jsonl >openregio_immobiliDestinati.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f s_bene openregio_immobiliGestione.jsonl >openregio_immobiliGestione.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f m_bene openregio_aziendeDestinate.jsonl >openregio_aziendeDestinate.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f m_bene openregio_aziendeGestione.jsonl >openregio_aziendeGestione.csv
  mlr --j2c unsparsify then clean-whitespace then sort -f nome_regione,distretto,ufficio_giudiziario,tipologia_procedura,provvedimento,procedura_rg openregio_procedureGestione.jsonl >openregio_procedureGestione.csv
fi
