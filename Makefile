.PHONY: data/raw/jornalnoticias_co_mz.jsonlines
START_DATE?=2000-01-01

all: data/jornalnoticias_co_mz.csv

data/jornalnoticias_co_mz.csv: data/raw/jornalnoticias_co_mz.jsonlines
	jq -r '[.[]]' data/raw/jornalnoticias_co_mz.jsonlines > $@

data/raw/jornalnoticias_co_mz.jsonlines:
	scrapy crawl jornalnoticias_co_mz -o $@ -a start_date=$(START_DATE)
	sort -u -o $@ $@
