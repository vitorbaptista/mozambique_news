.PHONY: data/raw/jornalnoticias_co_mz.jsonlines data/raw/opais_co_mz.jsonlines
START_DATE?=$(shell date -d 'last Sunday - 5 days' --iso-8601)

data: data/jornalnoticias_co_mz.csv data/opais_co_mz.csv

data/jornalnoticias_co_mz.csv: data/raw/jornalnoticias_co_mz.jsonlines
	jq -r '[.[]]' $< > $@

data/raw/jornalnoticias_co_mz.jsonlines:
	scrapy crawl jornalnoticias_co_mz -o $@ -a start_date=$(START_DATE)
	sort -u -o $@ $@

data/opais_co_mz.csv: data/raw/opais_co_mz.jsonlines
	 jq --raw-output '[.] | map(.id, .date_gmt, .categories[0], .link, .title.rendered, .content.rendered) | @csv' $< > $@

data/raw/opais_co_mz.jsonlines:
	curl --silent 'https://opais.co.mz/api/wp-json/wp/v2/posts?categories=9&_embed&per_page=100&page=1' \
		| jq -c '.[]' \
		>> $@
	curl --silent 'https://opais.co.mz/api/wp-json/wp/v2/posts?categories=3&_embed&per_page=100&page=1' \
		| jq -c '.[]' \
		>> $@
	sort -u -o $@ $@
