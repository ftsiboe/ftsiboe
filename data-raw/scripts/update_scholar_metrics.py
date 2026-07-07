#!/usr/bin/env python3
import json
import sys
from datetime import datetime
import requests
from bs4 import BeautifulSoup

SCHOLAR_URL = "https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en"
OUT_FILE   = "scholar-metrics.json"

def fetch_metrics(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (compatible; GitHubActions/1.0)"
    }
    resp = requests.get(url, headers=headers, timeout=10)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")

    # The stats table has id="gsc_rsb_st"
    table = soup.find("table", {"id": "gsc_rsb_st"})
    rows  = table.find_all("tr")
    metrics = {}
    for row in rows:
        cols = row.find_all("td")
        if len(cols) >= 2:
            name = cols[0].text.strip().lower().replace('-', '_')
            alltime = cols[1].text.strip()
            metrics[name] = int(alltime.replace(',', ''))
    # Citations-per-year histogram: years are span.gsc_g_t, bar counts span.gsc_g_al.
    # Scholar sometimes prints fewer year labels than bars; align to recent years.
    years  = [int(s.get_text().strip()) for s in soup.select("span.gsc_g_t")
              if s.get_text().strip().isdigit()]
    counts = [int(s.get_text().strip().replace(",", "")) for s in soup.select("span.gsc_g_al")
              if s.get_text().strip().replace(",", "").isdigit()]
    cites_per_year = {}
    if counts:
        if len(years) != len(counts):
            end = years[-1] if years else datetime.now().year
            years = list(range(end - len(counts) + 1, end + 1))
        cites_per_year = {str(y): c for y, c in zip(years, counts)}

    return {
        "citations": metrics.get("citations", 0),
        "h_index":   metrics.get("h_index", 0),
        "i10_index": metrics.get("i10_index", 0),
        "cites_per_year": cites_per_year,
    }

if __name__ == "__main__":
    try:
        data = fetch_metrics(SCHOLAR_URL)
    except Exception as e:
        print(f"[warning] fetch failed: {e}", file=sys.stderr)
        sys.exit(0)

    with open(OUT_FILE, "w") as f:
        json.dump(data, f, indent=2)
    print("✔ Updated", OUT_FILE, data)
