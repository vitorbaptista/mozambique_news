.PHONY: data/raw/jornalnoticias_co_mz.jsonlines
START_DATE?=$(shell date -d 'last Sunday - 5 days' --iso-8601)

data: data/jornalnoticias_co_mz.csv

data/jornalnoticias_co_mz.csv: data/raw/jornalnoticias_co_mz.jsonlines
	jq -r '[.[]]' data/raw/jornalnoticias_co_mz.jsonlines > $@

data/raw/jornalnoticias_co_mz.jsonlines:
	scrapy crawl jornalnoticias_co_mz -o $@ -a start_date=$(START_DATE)
	sort -u -o $@ $@
