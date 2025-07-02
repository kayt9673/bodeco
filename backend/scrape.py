import requests
from bs4 import BeautifulSoup

def scrape_link(link):
    try:
        response = requests.get(link)
        soup = BeautifulSoup(response.text, 'html.parser')

        name = soup.find("h1")
        name = name.get_text(strip=True) if name else "Unknown"

        composition = None
        for tag in soup.find_all(text=True):
            if "composition" in tag.lower() or "material" in tag.lower():
                composition = tag.strip()
                break

        return {"name": name, "composition": composition}
    except Exception as e:
        return {"error": str(e)}
