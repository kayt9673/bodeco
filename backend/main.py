from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import subprocess, json, os, uuid
from sustainability import score_sustainability
from search import search_google
from fastapi import Query

app = FastAPI()

class ScoreRequest(BaseModel):
    link: str  # we’ll just echo this back; spider is hard‑coded

@app.get("/search")
def search(query: str = Query(..., min_length=1)):
    results = search_google(query)
    return results

@app.get("/score_all")
def get_all_scores():
    data_path = os.path.join(os.path.dirname(__file__), "myproject", "output_cleaned.json")
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            products = json.load(f)
    except Exception as e:
        raise HTTPException(500, f"Error reading output_cleaned.json: {e}")

    results = []
    for product in products:
        materials = product.get("materials", [])
        score = score_sustainability(materials)
        results.append({
            "link": product.get("url"),
            "title": product.get("item_name"),
            "brand": product.get("brand"),
            "price": product.get("price"),
            "materials": materials,
            "sustainability_score": score
        })

    return results

