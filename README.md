![scarica e tieni aggiornati i dati openregio](https://github.com/aborruso/firstaction/workflows/scarica%20e%20tieni%20aggiornati%20i%20dati%20openregio/badge.svg)

Guida di riferimento <https://help.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow>

# idee

## Esportare come tsv/csv il log git di un file - modo 1

```bash
git log --date=iso --no-merges --pretty=format:"%h%x09%an%x09%ad%x09%s" -- openregio_immobiliGestione.csv
```

In output

```
2c0416d automatico      2020-06-19 22:54:32 +0000       Data e ora aggiornamento: Fri Jun 19 22:54:32 UTC 2020
647c5c3 automatico      2020-06-18 22:10:42 +0000       Data e ora aggiornamento: Thu Jun 18 22:10:42 UTC 2020
10ba198 automatico      2020-06-18 21:27:31 +0000       Data e ora aggiornamento: Thu Jun 18 21:27:31 UTC 2020
```

Le colonne sono, `hash, nome utente, data ISO del commit, e messaggio di commit`

## Esportare come tsv/csv il log git di un file - modo 2

Ho preso spunto da questa modalità <https://stackoverflow.com/questions/21137477/how-to-get-git-log-with-short-stat-in-one-line>

