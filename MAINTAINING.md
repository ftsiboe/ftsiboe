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
| Wording of a top-level page (About, Working Papers, R Packages, Replication, Metrics) | the matching `data-raw/scripts/pages/*.Rmd` | run `render.R` |
| The GitHub **profile** page | `data-raw/scripts/pages/README.Rmd` | run `render.R` |
| **Publications** (add/remove/fix a paper or link) | the `links.csv` in that area folder, e.g. `data-raw/publications/<area>/links.csv` | run `render.R` |
| A single **area page**'s layout/prose | `data-raw/scripts/pages/publications/pub-<area>.Rmd` | run `render.R` |
| The Publications **index** (areas + sub-bullets) | `data-raw/scripts/pages/publications/publications.Rmd` | run `render.R` |
| How a citation/list is **formatted** everywhere | `data-raw/scripts/site_helpers.R` (shared helpers) | run `render.R` |
| Sidebar **profile** (name, photo, bio, email, Scholar/ORCID/…) | `docs/_config.yml` → `author:` block | commit |
| Top **navigation** menu | `docs/_data/navigation.yml` | commit |
| **Theme / look** (colors, layout) | `docs/_sass/`, `docs/_includes/`, `docs/_layouts/` | commit |
| **Citation numbers** (citations, h-index, i10) | nothing — auto-updated weekly by the Action | — |
| **Private-package** descriptions | `data-raw/private-packages-inventory.csv` | run `update_private_packages.R` |

---

## The publications manifests (`links.csv`)

Each **area folder** under `data-raw/publications/` has its own `links.csv`
(e.g. `risk-management/links.csv`, `cocoa/links.csv`, `production/links.csv`, …).
`render.R` reads **all** of them and combines the rows. One row per paper, four
columns:

```csv
topic,file,url,venue
crop-insurance-demand,"2022 - Turner & Tsiboe - The Crop Insurance Demand Response….pdf",https://doi.org/10.1002/aepp.13314,AEPP
```

- **`file`** — the PDF's file name, using the convention
  **`YEAR[-issue] - Authors - Title.pdf`** (year first so the files sort by date
  on your computer; the outlet is *not* in the name). PDFs stay local (git-ignored
  for copyright); only the link is published. *(Exception: presentation PDFs in
  `data-raw/publications/presentations/` keep the conference abbreviation:
  `YEAR - CONF - Title.pdf`. Presentations aren't listed on the site.)*
- **`url`** — the **public** version (journal DOI, USDA-ERS, AgEcon, or ARPC page).
  Leave it **blank** if you don't have one yet — the paper still appears, just
  without a link.
- **`venue`** — the journal/outlet shown in the citation on the site (e.g. `AEPP`,
  `USDA ERS EIB`, `ARPC Brief`). Blank is fine — the citation just omits it.
- **`topic`** — one of the topic keys (these become the headings on the
  Publications page). Each key must also exist under `publication_category:` in
  `docs/_config.yml`. Current topics:

  `background-and-policy`, `crop-insurance-demand`, `crop-insurance-rating`,
  `prevented-planting`, `premium-and-interest-deferrals`, `yield-modeling`,
  `index-insurance`, `impacts-of-crop-insurance`, `safety-net-simulation`,
  `climate-and-environment`, `cocoa`, `production`, `gender`, `off-farm-work`,
  `demand-and-markets`, `sustainability`, `food-security-and-poverty`,
  `biotechnology`, `rice`, `impact-evaluation`

### Structure: areas, sub-topics, and pages

The Publications section is organized by **area** (each = a folder in
`data-raw/publications/`). Every area gets:

- an entry under `publication_category:` in `docs/_config.yml` (no `group:`),
- a self-contained source `data-raw/scripts/pages/publications/pub-<area>.Rmd`
  → `docs/_pages/topic-<area>.md` (permalink `/publications/<area>/`).

One area, **risk-management**, is split into **sub-topics**. A sub-topic is a
`publication_category:` entry with `group: risk-management`; its papers live in
`data-raw/publications/risk-management/links.csv` with that sub-topic key in the
`topic` column. The risk-management page shows one `## section` per sub-topic.

The **index**, `data-raw/scripts/pages/publications/publications.Rmd` →
`docs/publications.md` (permalink `/publications/`), lists each area as a bullet,
with risk-management's sub-topics as sub-bullets linking to that page's sections.

All the page sources just call helpers from `data-raw/scripts/site_helpers.R`
(`pub_area_page()`, `pub_topic_index()`), so the manifest reading and citation
formatting live in **one** place — edit there to change how every paper renders.

### Add a new publication
1. Add the PDF to the right area folder under
   `data-raw/publications/<area>/` (optional, for your records).
2. Add a row to that area's `links.csv` (`topic` = the area key, or a sub-topic
   key for risk-management).
3. `Rscript data-raw/scripts/render.R` → commit → push.

### Add a new AREA (new bullet + page)
1. Create `data-raw/publications/<area>/links.csv` with its papers.
2. Add the area under `publication_category:` in `docs/_config.yml`
   (key = `<area>`, `title:` = heading shown). Order there = order on the index.
3. Copy an existing `pages/publications/pub-<area>.Rmd` to `pub-<newarea>.Rmd`
   and change the `pub_area_page("<newarea>")` line.
4. Re-run `render.R`.

### Add a sub-topic to risk-management
1. Add the sub-topic under `publication_category:` with `group: risk-management`.
2. Use that key in the `topic` column of `risk-management/links.csv` rows.
3. Re-run `render.R` (no new page needed — it becomes a section on the risk page).

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
| `data-raw/scripts/pages/*.Rmd` + `pages/publications/*.Rmd` + `data-raw/scripts/site_helpers.R` | `README.md`, `docs/index.md`, `docs/*.md` |
| `data-raw/publications/*/links.csv` (one per area) | `docs/publications.md`, `docs/_pages/topic-*.md` |
| `docs/_config.yml`, `docs/_data/navigation.yml` | `data-raw/scholar-metrics.json` (auto) |
| `data-raw/private-packages-inventory.csv` | `data-raw/private-packages/*.md` |
