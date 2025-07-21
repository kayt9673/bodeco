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


@app.post("/score")
def get_sustainability_score(req: ScoreRequest):
    # 1) temp filename
    tmpfile = f"scrape_{uuid.uuid4().hex}.json"
    # 2) point at your Scrapy project folder
    project_dir = os.path.join(os.path.dirname(__file__), "myproject")

    # 3) run the crawl (no -a, since start_urls is hard‑coded)
    result = subprocess.run(
        ["scrapy", "crawl", "materials_percent", "-t", "json", "-o", tmpfile],
        cwd=project_dir,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        raise HTTPException(500, f"Scrapy failed:\n{result.stderr.strip()}")

    # 4) read the JSON output
    outpath = os.path.join(project_dir, tmpfile)
    try:
        with open(outpath, "r", encoding="utf-8") as f:
            items = json.load(f)
    except Exception as e:
        raise HTTPException(500, f"Failed to read scrape output: {e}")
    finally:
        if os.path.exists(outpath):
            os.remove(outpath)

    if not items:
        raise HTTPException(404, "No data scraped")

    # 5) grab the first result
    item = items[0]
    materials  = item.get("materials", [])
    description = item.get("description", "")

    # 6) score it
    score = score_sustainability(materials)

    return {
        "url":             req.link,
        "materials":       materials,
        "description":     description,
        "sustainability_score": score
    }
