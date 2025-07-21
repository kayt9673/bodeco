import json
import re

def clean_brand(brand):
    if not brand:
        return ''
    brand = re.sub(r'<.*?>', '', brand)
    return brand.strip().lower()

def clean_price(price):
    if not price:
        return ''
    return re.sub(r'[^\d.,]', '', price)

def clean_materials(materials):
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

def standardize_entry(entry):
    return {
        "url": entry.get("url", ""),
        "materials": clean_materials(entry.get("materials", [])),
        "brand": clean_brand(entry.get("brand", "")),
        "price": clean_price(entry.get("price", "")),
        "item_name": entry.get("item_name", "")
    }

def main():
    with open("output.json", "r") as f:
        try:
            data = json.load(f)
        except Exception:
            # fallback: try to extract last non-empty array
            content = f.read()
            arrays = list(re.finditer(r'\[.*?\]', content, re.DOTALL))
            data = []
            for match in reversed(arrays):
                arr = json.loads(match.group(0))
                if arr and isinstance(arr, list) and isinstance(arr[0], dict):
                    data = arr
                    break
    cleaned = [standardize_entry(e) for e in data]
    with open("output_cleaned.json", "w") as f:
        json.dump(cleaned, f, indent=2)
    print("Cleaned data written to output_cleaned.json")

if __name__ == "__main__":
    main() 