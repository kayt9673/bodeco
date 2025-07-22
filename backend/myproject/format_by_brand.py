import json

# Load the cleaned JSON data
with open('backend/myproject/output_cleaned.json', 'r') as f:
    data = json.load(f)

# Transform into the desired format
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

# Save the result
with open('backend/myproject/output_by_brand.json', 'w') as f:
    json.dump(brand_map, f, indent=2)

# Optionally print the result
if __name__ == "__main__":
    print(json.dumps(brand_map, indent=2)) 