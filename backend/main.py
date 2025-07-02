from fastapi import FastAPI, Request
from search import search_google
from scrape import scrape_link
from pydantic import BaseModel

app = FastAPI()

class ScrapeRequest(BaseModel):
    link: str

@app.get("/search")
def search(query: str):
    return search_google(query)

@app.post("/scrape")
def scrape(req: ScrapeRequest):
    return scrape_link(req.link)
