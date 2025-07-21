import json
from collections import defaultdict

# Load the JSON array from file
with open('output.json', 'r') as f:
    try:
        entries = json.load(f)
    except Exception as e:
        print(f"Failed to load JSON: {e}")
        entries = []

# Normalize price (remove commas and ensure float format)
def normalize_price(price):
    try:
        return float(price.replace(',', '').strip())
    except:
        return None

# 1. Map: brand -> {item_name: {price, materials}}
brand_map = defaultdict(dict)
for entry in entries:
    brand = entry.get('brand')
    item_name = entry.get('item_name')
    raw_price = entry.get('price')
    price = normalize_price(raw_price)
    materials = entry.get('materials')
    
    if brand and item_name:
        brand_map[brand][item_name] = {'price': price, 'materials': materials}

# 2. Map: price -> list of {item_name, brand, materials}
price_map = defaultdict(list)
for entry in entries:
    item_name = entry.get('item_name')
    brand = entry.get('brand')
    raw_price = entry.get('price')
    price = normalize_price(raw_price)
    materials = entry.get('materials')

    if price is not None and item_name:
        price_map[price].append({'item_name': item_name, 'brand': brand, 'materials': materials})

# Prepare output string
output_lines = []
output_lines.append('Brand Map:')
for brand, items in brand_map.items():
    output_lines.append(f'  {brand}:')
    for item, details in items.items():
        output_lines.append(f'    {item}: {details}')

output_lines.append('\nPrice Map:')
for price in sorted(price_map.keys()):
    output_lines.append(f'  ${price:.2f}:')
    for item in price_map[price]:
        output_lines.append(f'    {item}')

output_str = '\n'.join(output_lines)

# Print to console
print(output_str)

# Save to text file
with open('output_maps.txt', 'w') as out_f:
    out_f.write(output_str) 