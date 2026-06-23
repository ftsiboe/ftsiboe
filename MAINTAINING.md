# Maintaining this site & repo

This repo holds two things:

1. **The GitHub profile page** — `README.md` (shown on your GitHub profile).
2. **The website** — `docs/` → published by GitHub Pages at
   <https://ftsiboe.github.io/ftsiboe/> using the **AcademicPages** theme.

Both are **generated** from a few source files by one script:

```bash
Rscript data-raw/scripts/render.R     # rebuild everything
git add -A && git commit -m "update site" && git push
```

> **Golden rule:** edit the *sources* below, then run `render.R`.
> Never hand-edit `docs/*.md` or `docs/_publications/` — they are overwritten.

---

## What do I edit to change…?

| I want to change… | Edit this | Then |
|---|---|---|
| Wording of a page (About, Working Papers, R Packages, Replication, Metrics) | the matching `data-raw/scripts/pages/*.Rmd` | run `render.R` |
| The GitHub **profile** page | `data-raw/scripts/pages/README.Rmd` | run `render.R` |
| **Publications** (add/remove/fix a paper or link) | the `links.csv` in that area folder, e.g. `data-raw/publications/<area>/links.csv` | run `render.R` |
| Sidebar **profile** (name, photo, bio, email, Scholar/ORCID/…) | `docs/_config.yml` → `author:` block | commit |
| Top **navigation** menu | `docs/_data/navigation.yml` | commit |
| **Theme / look** (colors, layout) | `docs/_sass/`, `docs/_includes/`, `docs/_layouts/` | commit |
| **Citation numbers** (citations, h-index, i10) | nothing — auto-updated weekly by the Action | — |
| **Private-package** descriptions | `data-raw/private-packages-inventory.csv` | run `update_private_packages.R` |

---

## The publications manifests (`links.csv`)

Each **area folder** under `data-raw/publications/` has its own `links.csv`
(e.g. `risk-management/links.csv`, `cocoa/links.csv`, `production/links.csv`, …).
`render.R` reads **all** of them and combines the rows. One row per paper, three
columns:

```csv
topic,file,url
crop-insurance-demand,"AEPP 2022 - Turner & Tsiboe - The Crop Insurance Demand Response….pdf",https://doi.org/10.1002/aepp.13314
```

- **`file`** — the PDF's file name. PDFs stay on your computer (they're git-ignored
  for copyright); only the link is published.
- **`url`** — the **public** version (journal DOI, USDA-ERS, AgEcon, or ARPC page).
  Leave it **blank** if you don't have one yet — the paper still appears, just
  without a link.
- **`topic`** — one of the topic keys (these become the headings on the
  Publications page). Each key must also exist under `publication_category:` in
  `docs/_config.yml`. Current topics:

  `background-and-policy`, `crop-insurance-demand`, `crop-insurance-rating`,
  `prevented-planting`, `premium-and-interest-deferrals`, `yield-modeling`,
  `index-insurance`, `impacts-of-crop-insurance`, `safety-net-simulation`,
  `climate-and-environment`, `cocoa`, `production`, `gender`, `off-farm-work`,
  `demand-and-markets`, `sustainability`, `food-security-and-poverty`,
  `biotechnology`, `rice`, `impact-evaluation`

`render.R` turns each row into a file in `docs/_publications/`, and the
Publications page lists them grouped by topic (in the `_config.yml` order).

### Add a new publication
1. Add the PDF to the right area folder under
   `data-raw/publications/<area>/` (optional, for your records).
2. Add a row to that area's `links.csv` (set `topic` to a valid topic key).
3. `Rscript data-raw/scripts/render.R` → commit → push.

### Add a new topic (new heading)
1. Use the new topic name in the `topic` column of any `links.csv` rows.
2. Add it under `publication_category:` in `docs/_config.yml`
   (key = topic name, `title:` = the heading shown). Order there = order on page.
3. Re-run `render.R`.

### Add a whole new area folder
1. Create `data-raw/publications/<area>/` and drop a `links.csv` inside it.
2. Make sure each `topic` you use is registered in `_config.yml`.
3. Re-run `render.R` — it auto-discovers the new `links.csv`.

---

## Add a whole new page/section (e.g., "Teaching")

1. Create the source `data-raw/scripts/pages/teaching.Rmd`.
2. Add one line to the `jobs` list in `data-raw/scripts/render.R`:
   ```r
   list(src = "teaching.Rmd", out = file.path(root,"docs","teaching.md"),
        front = fm_ap("Teaching", "/teaching/"))
   ```
3. Add a menu entry in `docs/_data/navigation.yml`:
   ```yaml
   - title: "Teaching"
     url: /teaching/
   ```
4. Re-run `render.R`.

---

## Working papers

Public PDFs live in `data-raw/working-papers/` (these **are** committed). The
Working Papers page lists them automatically (titles are derived from the file
names). Add a PDF there, run `render.R`.

## CV

Put your current CV at `docs/assets/cv.pdf`; the **CV** menu item links to it.

---

## How it deploys

- **Pages source:** Settings → Pages → *Deploy from a branch* → `main` / `docs`
  (classic build — **not** GitHub Actions). The AcademicPages theme here uses
  only GitHub-Pages-allowed plugins, so the classic build works.
- **Automatic rebuilds:** the workflow `.github/workflows/R-google-scholar-profile.yaml`
  refreshes `data-raw/scholar-metrics.json` and re-runs `render.R` on a schedule
  and on pushes to the sources, committing any changes.

## Sources vs generated (don't edit the generated side)

| Sources (edit these) | Generated (leave alone) |
|---|---|
| `data-raw/scripts/pages/*.Rmd` | `README.md`, `docs/index.md`, `docs/*.md` |
| `data-raw/publications/*/links.csv` (one per area) | `docs/_publications/*.md` |
| `docs/_config.yml`, `docs/_data/navigation.yml` | `data-raw/scholar-metrics.json` (auto) |
| `data-raw/private-packages-inventory.csv` | `data-raw/private-packages/*.md` |
