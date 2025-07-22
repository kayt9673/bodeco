import os
import json
from collections import OrderedDict

class PostProcessPipeline:
    def close_spider(self, spider):
        # 1. Clean output.json -> output_cleaned.json
        self.clean_output_json()
        # 2. Format by brand
        self.format_by_brand()
        # 3. Format by price
        self.format_by_price()

    def clean_output_json(self):
        try:
            with open('backend/myproject/output.json', 'r') as f:
                data = json.load(f)
        except Exception:
            # fallback: try to extract last non-empty array
            with open('backend/myproject/output.json', 'r') as f:
                content = f.read()
            import re
            arrays = list(re.finditer(r'\[.*?\]', content, re.DOTALL))
            data = []
            for match in reversed(arrays):
                arr = json.loads(match.group(0))
                if arr and isinstance(arr, list) and isinstance(arr[0], dict):
                    data = arr
                    break
        cleaned = [self.standardize_entry(e) for e in data]
        with open('backend/myproject/output_cleaned.json', 'w') as f:
            json.dump(cleaned, f, indent=2)

    def clean_brand(self, brand):
        import re
        if not brand:
            return ''
        brand = re.sub(r'<.*?>', '', brand)
        return brand.strip().lower()

    def clean_price(self, price):
        import re
        if not price:
            return ''
        return re.sub(r'[^\d.,]', '', price)

    def clean_materials(self, materials):
        cleaned = []
        for m in materials or []:
            if isinstance(m, dict):
                mat = {"material": m.get("material", "").strip().lower()}
                if "percentage" in m:
                    mat["percentage"] = m["percentage"]
                cleaned.append(mat)
            elif isinstance(m, str):
                cleaned.append({"material": m.strip().lower()})
        return cleaned

    def standardize_entry(self, entry):
        return {
            "url": entry.get("url", ""),
            "materials": self.clean_materials(entry.get("materials", [])),
            "brand": self.clean_brand(entry.get("brand", "")),
            "price": self.clean_price(entry.get("price", "")),
            "item_name": entry.get("item_name", "")
        }

    def format_by_brand(self):
        with open('backend/myproject/output_cleaned.json', 'r') as f:
            data = json.load(f)
        brand_map = {}
        for item in data:
            brand = item['brand']
            entry = {
                "item_name": item["item_name"],
                "price": item["price"],
                "materials": item["materials"]
            }
            if brand not in brand_map:
                brand_map[brand] = []
            brand_map[brand].append(entry)
        with open('backend/myproject/output_by_brand.json', 'w') as f:
            json.dump(brand_map, f, indent=2)

    def format_by_price(self):
        with open('backend/myproject/output_cleaned.json', 'r') as f:
            data = json.load(f)
        price_map = {}
        for item in data:
            price = item['price']
            entry = {
                "item_name": item["item_name"],
                "brand": item["brand"],
                "materials": item["materials"]
            }
            if price not in price_map:
                price_map[price] = []
            price_map[price].append(entry)
        sorted_prices = sorted(
            price_map.items(),
            key=lambda x: float(x[0].replace(',', '').replace('$', '')) if x[0].replace(',', '').replace('$', '').replace('.', '', 1).isdigit() else float('inf')
        )
        ordered_price_map = OrderedDict(sorted_prices)
        with open('backend/myproject/output_by_price.json', 'w') as f:
            json.dump(ordered_price_map, f, indent=2) 