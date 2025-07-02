import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GOOGLE_API_KEY")
CX = os.getenv("GOOGLE_CX")

def search_google(query):
    url = "https://www.googleapis.com/customsearch/v1"
    params = {
        "key": API_KEY,
        "cx": CX,
        "q": query,
        "num": 5
    }

    response = requests.get(url, params=params)
    data = response.json()

    results = []

    for item in data.get("items", []):
        title = item.get("title")
        link = item.get("link")
        image = None

        # Try to get image if it exists
        try:
            image = item["pagemap"]["cse_image"][0]["src"]
        except (KeyError, IndexError):
            pass

        results.append({
            "title": title,
            "link": link,
            "image": image
        })

    return results
