import json
from collections import OrderedDict

# Load the cleaned JSON data
with open('backend/myproject/output_cleaned.json', 'r') as f:
    data = json.load(f)

# Transform into the desired format
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

# Sort the prices as floats, but keep the original string as the key
sorted_prices = sorted(
    price_map.items(),
    key=lambda x: float(x[0].replace(',', '').replace('$', '')) if x[0].replace(',', '').replace('$', '').replace('.', '', 1).isdigit() else float('inf')
)
ordered_price_map = OrderedDict(sorted_prices)

# Save the result
with open('backend/myproject/output_by_price.json', 'w') as f:
    json.dump(ordered_price_map, f, indent=2)

# Optionally print the result
if __name__ == "__main__":
    print(json.dumps(ordered_price_map, indent=2)) 