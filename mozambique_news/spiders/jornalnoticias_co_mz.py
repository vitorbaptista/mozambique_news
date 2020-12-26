import datetime
import scrapy


class JornalnoticiasCoMzSpider(scrapy.Spider):
    name = "jornalnoticias_co_mz"
    allowed_domains = ["www.jornalnoticias.co.mz"]
    start_urls = [
        "https://www.jornalnoticias.co.mz/index.php/politica",
        "https://www.jornalnoticias.co.mz/index.php/sociedade",
        "https://www.jornalnoticias.co.mz/index.php/capital/maputo",
        "https://www.jornalnoticias.co.mz/index.php/capital/beira",
        "https://www.jornalnoticias.co.mz/index.php/capital/nampula",
    ]

    def parse(self, response):
        for news_section in response.css('[itemtype="https://schema.org/BlogPosting"]'):
            news_data = self.extract_news(news_section)
            yield news_data

        try:
            start_date = datetime.datetime.strptime(self.start_date, "%Y-%m-%d")
            if news_data["published_at"].replace(tzinfo=None) < start_date.replace(
                tzinfo=None
            ):
                return  # Stop scraping
        except AttributeError:
            pass

        next_page = response.css(".pagination .seguinte a::attr(href)").get()
        if next_page is not None:
            yield response.follow(next_page, callback=self.parse)

    def extract_news(self, selector):
        extractors = {
            "published_at": '[itemprop="datePublished"]::attr(datetime)',
            "title": '[itemprop="name"] a::text',
            "url": '[itemprop="name"] a::attr(href)',
            "category": '[itemprop="genre"]::text',
            "body": "span::text",
        }

        data = {
            key: "\n".join([row.strip() for row in selector.css(extractor).extract()])
            for (key, extractor) in extractors.items()
        }
        data["url"] = f"https://www.jornalnoticias.co.mz{data['url']}"

        if not data["body"]:
            data["body"] = "\n".join(
                [row.strip() for row in selector.css("p::text").extract()]
            )

        if not data["body"]:
            all_text = [row.strip() for row in selector.css("::text").extract()]
            text_start_index = all_text.index("Twitter")
            text_end_index = all_text.index("Comments")

            data["body"] = "\n".join(all_text[text_start_index + 1 : text_end_index])

        for key in extractors.keys():
            assert data[key], f"Key {key} is empty: {data}"

        data["published_at"] = datetime.datetime.strptime(
            data["published_at"], "%Y-%m-%dT%H:%M:%S%z"
        )

        return data
