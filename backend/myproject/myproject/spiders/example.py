import scrapy
import re
import json

class MaterialsSpider(scrapy.Spider):
    name = "materials_percent"
    # works for: abercrombie, brandy, hollister
    start_urls = [
        "https://www.abercrombie.com/shop/us/p/off-the-shoulder-twist-top-59070820?seq=04&source=googleshopping&cmp=PLA%3AEVG%3A20%3AA%3AD%3AUS%3AX%3AGGL%3AX%3ASHOP%3AX%3AX%3AX%3AX%3AX%3Ax%3AA%26F+Adults_Google_Shopping_PLA_US_Tops_All+products_PRODUCT_GROUP&gclsrc=aw.ds&gad_source=1&gad_campaignid=17296424375&gbraid=0AAAAADeAqWPNI36FsJZSLmdu2SCogRkZZ&gclid=Cj0KCQjwyvfDBhDYARIsAItzbZHvPmL-4p5UN73UAaF8xDZ00aLyIyL5YOSjql8zHcTuGxN35s36V0oaApyVEALw_wcB",
        "https://us.brandymelville.com/products/robyn-top",
        "https://us.brandymelville.com/products/zelly-striped-top-8",
        "https://www.hollisterco.com/shop/us/p/soft-stretch-seamless-fabric-crew-baby-tee-59799819?categoryId=166318&faceout=model&seq=02",
        "https://www.hollisterco.com/shop/us/p/easy-satin-tie-babydoll-top-59791819?categoryId=625001100&faceout=model&seq=03&afsource=social+proofing"
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
        brand = self.extract_brand(response)
        price = self.extract_price(response)
        item_name = self.extract_item_name(response)

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
                "materials": materials_list,
                "brand": brand,
                "price": price,
                "item_name": item_name
            }

    async def parse_with_playwright(self, response):
        page = response.meta.get("playwright_page")
        if page:
            await page.close()

        materials_text = self.extract_materials_text(response)
        materials_list = self.extract_materials(materials_text)
        brand = self.extract_brand(response)
        price = self.extract_price(response)
        item_name = self.extract_item_name(response)

        yield {
            "url": response.url,
            "materials": materials_list,
            "brand": brand,
            "price": price,
            "item_name": item_name
        }

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

        # 4. Hollister/Abercrombie fallback: scan for details in visible product details/description
        details_selectors = [
            '.product-details', '.product-description', '.product-info', '.product-detail-description',
            '[data-testid="pdp-description-section"]', '[data-testid="product-description"]',
            '[class*="composition"]', '[class*="details"]', '[class*="description"]'
        ]
        for sel in details_selectors:
            details = response.css(f'{sel} *::text').getall()
            details = [d.strip() for d in details if d.strip()]
            if details:
                combined = " ".join(details)
                # Look for material keywords in the combined text
                if re.search(r'(\d{1,3}%|cotton|polyester|modal|spandex|nylon|viscose|rayon|wool|silk|linen|acrylic)', combined, re.IGNORECASE):
                    return combined

        # 5. Fallback: all visible text (last resort)
        all_text = " ".join([t.strip() for t in response.css('body *::text').getall() if t.strip()])
        if re.search(r'(\d{1,3}%|cotton|polyester|modal|spandex|nylon|viscose|rayon|wool|silk|linen|acrylic)', all_text, re.IGNORECASE):
            return all_text

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
        if not materials_text:
            materials_text = ""
        # Normalize whitespace (including non-breaking spaces)
        import re
        materials_text = re.sub(r'\s+', ' ', materials_text.replace('\xa0', ' '))
        # Match patterns like '100% cotton' or '100% cotton Measurement'
        pattern = re.compile(r'(\d{1,3})%[\s\-]*([A-Za-z]+)', re.IGNORECASE)
        matches = pattern.findall(materials_text)
        materials = []
        for percent, mat in matches:
            entry = {"percentage": percent.strip() + "%", "material": mat.strip().lower()}
            materials.append(entry)
        if materials:
            return materials
        # Last resort: scan for material keywords
        material_keywords = [
            "cotton", "polyester", "nylon", "viscose", "rayon", "spandex", "elastane", "lycra", "wool", "cashmere", "silk", "linen", "acrylic", "modal", "lyocell", "leather", "polyurethane", "polyamide", "acetate", "cupro", "hemp", "bamboo", "down", "feather", "faux fur", "suede", "velvet", "jersey", "tencel", "elastomultiester", "metallic", "rubber", "latex"
        ]
        found = []
        for kw in material_keywords:
            if re.search(rf'\b{re.escape(kw)}\b', materials_text, re.IGNORECASE):
                found.append({"material": kw})
        return found

    def extract_brand(self, response):
        import re
        from urllib.parse import urlparse
        # Try Open Graph, JSON-LD, or common selectors
        brand = response.xpath('//meta[@property="og:brand"]/@content').get()
        if brand:
            return brand.strip()
        # JSON-LD
        scripts = response.xpath('//script[@type="application/ld+json"]/text()').getall()
        for script_text in scripts:
            try:
                data = json.loads(script_text)
                if isinstance(data, dict):
                    brand_val = data.get("brand")
                    if isinstance(brand_val, dict):
                        brand = brand_val.get("name", "")
                    elif isinstance(brand_val, str):
                        brand = brand_val
                    if brand:
                        break
            except Exception:
                continue
        # data-product-brand attribute
        if not brand:
            brand = response.xpath('//*[@data-product-brand]/@data-product-brand').get()
        # Clean up brand: if it's HTML or a short code, use domain
        if not brand or re.search(r'<.*?>', str(brand)) or (isinstance(brand, str) and len(brand.strip()) <= 3):
            parsed_url = urlparse(response.url)
            domain = parsed_url.hostname or ""
            # Remove www. and TLD
            domain = re.sub(r'^www\.', '', domain)
            domain = domain.split('.')
            if len(domain) > 1:
                brand = domain[-2]  # e.g., 'hollisterco' from 'www.hollisterco.com'
            else:
                brand = domain[0]
        return brand.strip() if brand else None

    def extract_price(self, response):
        # 1. Try Open Graph meta tag (Brandy Melville uses this)
        price = response.xpath('//meta[@property="og:price:amount"]/@content').get()
        if price:
            return price.strip()
        # 2. Try Shopify product meta (Brandy Melville, many Shopify stores)
        shopify_price = response.xpath('//script[contains(text(), "ShopifyAnalytics.lib.track")]/text()').re_first(r'"price"\s*:\s*"([\d.]+)"')
        if shopify_price:
            return shopify_price.strip()
        # 3. Try JSON-LD offers.price
        scripts = response.xpath('//script[@type="application/ld+json"]/text()').getall()
        for script_text in scripts:
            try:
                data = json.loads(script_text)
                if isinstance(data, dict):
                    offers = data.get("offers")
                    if isinstance(offers, dict):
                        price_val = offers.get("price")
                        if price_val:
                            return str(price_val).strip()
            except Exception:
                continue
        # 4. Fallback: look for price in visible text (generic)
        price_text = response.css('[class*="price"], [id*="price"]::text').re_first(r'\$?([\d,.]+)')
        if price_text:
            return price_text.strip()
        return None

    def extract_item_name(self, response):
        # Try Open Graph, JSON-LD, or common selectors
        name = response.xpath('//meta[@property="og:title"]/@content').get()
        if name:
            return name.strip()
        # JSON-LD
        scripts = response.xpath('//script[@type="application/ld+json"]/text()').getall()
        for script_text in scripts:
            try:
                data = json.loads(script_text)
                if isinstance(data, dict):
                    name_val = data.get("name")
                    if name_val:
                        return name_val.strip()
            except Exception:
                continue
        # Fallback: look for product name in visible text
        name_text = response.css('[class*="title"], [id*="title"]::text').get()
        if name_text:
            return name_text.strip()
        return None
