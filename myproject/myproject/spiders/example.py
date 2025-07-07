import scrapy
import re
import json

class MaterialsSpider(scrapy.Spider):
    name = "materials_percent"
    # works for: abercrombie, brandy, hollister
    start_urls = [
        "https://us.brandymelville.com/products/robyn-top-1",
        ""
        # add more URLs
    ]

    def start_requests(self):
        for url in self.start_urls:
            yield scrapy.Request(url, callback=self.parse)

    def parse(self, response):
        self.logger.info(f"Parsing URL: {response.url}")

        if "captcha" in response.url.lower() or "challenge" in response.url.lower():
            self.logger.warning(f"Blocked by captcha or challenge page: {response.url}")
            yield {"url": response.url, "materials": [], "error": "captcha_blocked"}
            return

        materials_text = self.extract_materials_text(response)
        materials_list = self.extract_materials(materials_text)

        # If no materials found, try JSON-LD extraction fallback
        if not materials_list:
            self.logger.info("No materials found via standard extraction, trying JSON-LD extraction")
            jsonld_text = self.extract_materials_from_jsonld(response)
            materials_list = self.extract_materials(jsonld_text)

        if not materials_list:
            # If still no materials, try Playwright rendering
            self.logger.info("No materials found in JSON-LD either, trying Playwright rendering...")
            yield scrapy.Request(
                response.url,
                callback=self.parse_with_playwright,
                meta={
                    "playwright": True,
                    "playwright_page_methods": [
                        ("click", 'button[data-qa-action="show-extra-detail"]'),
                        ("wait_for_selector", "div.product-detail-description"),
                    ],
                    "playwright_include_page": True,
                },
                dont_filter=True,
            )
        else:
            yield {
                "url": response.url,
                "materials": materials_list
            }

    async def parse_with_playwright(self, response):
        page = response.meta.get("playwright_page")
        if page:
            await page.close()

        materials_text = self.extract_materials_text(response)
        materials_list = self.extract_materials(materials_text)

        yield {
            "url": response.url,
            "materials": materials_list
        }

    def extract_materials_text(self, response):
        def extract_materials_text(self, response):
            # 1. CSS selectors for material/fabric keywords in class/id
            candidate_texts = response.css(
                '[class*="material"]::text, [id*="material"]::text, [class*="fabric"]::text, [id*="fabric"]::text'
            ).getall()
            candidate_texts = [text.strip() for text in candidate_texts if text.strip()]
            materials_text = " ".join(candidate_texts).replace('\xa0', ' ')

            if materials_text:
                return materials_text

            # 2. Meta description fallback
            meta_desc = response.xpath('//meta[@name="description"]/@content').get()
            if meta_desc:
                fabrics_match = re.search(r'(Fabrics?|Materials?):\s*([^\.]+)', meta_desc, re.IGNORECASE)
                if fabrics_match:
                    return fabrics_match.group(2)

            # 3. Product attribute list fallback
            items = response.xpath('//div[contains(@class,"product-intro_attr-list-textli")]')
            for item in items:
                label = item.xpath('.//div[contains(@class,"product-intro_attr-list-textname")]/text()').get()
                if label and ("composition" in label.lower() or "material" in label.lower() or "fabric" in label.lower()):
                    val = item.xpath('.//div[contains(@class,"product-intro_attr-list-textval")]//text()').getall()
                    val_text = " ".join([v.strip() for v in val if v.strip()])
                    if val_text:
                        return val_text

            # 5. General catch-all for containers with id/class containing keywords like 'fact', 'detail', 'composition'
            # This can catch Amazon and similar site structures
            containers = response.css(
                '[id*="fact"], [class*="fact"], [id*="detail"], [class*="detail"], [id*="composition"], [class*="composition"]'
            )
            for container in containers:
                texts = container.css('*::text').getall()
                texts = [t.strip() for t in texts if t.strip()]
                combined = " ".join(texts)
                if combined:
                    return combined

            # 6. If nothing found, return empty string
            return ""


    def extract_materials_from_jsonld(self, response):
        materials_texts = []
        scripts = response.xpath('//script[@type="application/ld+json"]/text()').getall()
        for script_text in scripts:
            try:
                data = json.loads(script_text)
                items = data if isinstance(data, list) else [data]

                for item in items:
                    desc = item.get("description")
                    if desc:
                        materials_texts.append(desc)
                    variants = item.get("hasVariant")
                    if variants and isinstance(variants, list):
                        for variant in variants:
                            desc_var = variant.get("description")
                            if desc_var:
                                materials_texts.append(desc_var)
            except Exception as e:
                self.logger.debug(f"Failed to parse JSON-LD: {e}")
                continue
        return " ".join(materials_texts)

    def extract_materials(self, materials_text):
        pattern = re.compile(r'(\d{1,3}%)[\s\-]*(\w+(?:\s\w+)*)', re.IGNORECASE)
        matches = pattern.findall(materials_text)
        return [{"percentage": p, "material": m.strip()} for p, m in matches]
