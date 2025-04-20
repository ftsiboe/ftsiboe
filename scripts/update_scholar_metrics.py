#!/usr/bin/env python3
import json
import sys
from scholarly import scholarly, ProxyGenerator

SCHOLAR_ID = "ox2t_YIAAAAJ"

# Try to initialize free proxies, but don’t fail if that API changed
pg = ProxyGenerator()
try:
    pg.FreeProxies()               
    scholarly.use_proxy(pg)
    print("[info] Using FreeProxies()")
except Exception as e:
    print(f"[warning] could not init FreeProxies(): {e}", file=sys.stderr)
    # continue without proxy

def fetch_metrics(user_id):
    author = scholarly.search_author_id(user_id)
    author = scholarly.fill(author, sections=[])
    return {
        "citations": author.get("citedby", 0),
        "h_index":   author.get("hindex", 0),
        "i10_index": author.get("i10index", 0),
    }

if __name__ == "__main__":
    try:
        metrics = fetch_metrics(SCHOLAR_ID)
    except Exception as e:
        print(f"[warning] could not fetch metrics: {e}", file=sys.stderr)
        sys.exit(0)

    with open("scholar-metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)
    print("Updated scholar‑metrics.json:", metrics)
