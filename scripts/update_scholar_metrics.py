#!/usr/bin/env python3
import json
from scholarly import scholarly

# your Google Scholar user ID
SCHOLAR_ID = "ox2t_YIAAAAJ"

def fetch_metrics(user_id):
    author = scholarly.search_author_id(user_id)
    author = scholarly.fill(author, sections=[])
    return {
        "citations": author.get("citedby", 0),
        "h_index":   author.get("hindex", 0),
        "i10_index": author.get("i10index", 0),
    }

if __name__ == "__main__":
    metrics = fetch_metrics(SCHOLAR_ID)
    with open("scholar-metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)
    print("Updated scholar‑metrics.json:", metrics)
