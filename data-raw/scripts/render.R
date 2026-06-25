#!/usr/bin/env Rscript
# =============================================================================
#  render.R  —  builds the website (docs/) + the GitHub profile README
# =============================================================================
#
#  RUN IT (from the repository root):
#      Rscript data-raw/scripts/render.R
#  then commit & push. GitHub Pages (Settings > Pages > Deploy from branch >
#  main / docs) rebuilds the site at https://ftsiboe.github.io/ .
#
#  GOLDEN RULE: only edit the *sources* listed below, then re-run this script.
#  Everything in docs/*.md and docs/_pages/topic-*.md is GENERATED from the .Rmd
#  sources — don't hand-edit those (changes are overwritten on the next run).
#
# -----------------------------------------------------------------------------
#  WHAT DO I EDIT TO CHANGE ... ?
# -----------------------------------------------------------------------------
#  * A page's wording (About, Working Papers, R Packages, Replication, Metrics)
#        -> edit the matching .Rmd in  data-raw/scripts/pages/
#           (README.Rmd = the GitHub profile page; home.Rmd = the site "About").
#
#  * Your publications (add / remove / fix a paper or its link)
#        -> edit the links.csv in that area:  data-raw/publications/<area>/links.csv
#           columns:  topic , file , url , venue
#           - "file"  = PDF file name, "YEAR[-issue] - Authors - Title.pdf"
#                       (year first so files sort by date; outlet NOT in the name).
#                       Kept locally; not pushed.
#           - "url"   = the PUBLIC link (journal DOI / USDA-ERS / AgEcon / ARPC);
#                       leave blank if none yet (paper shows without a link).
#           - "venue" = journal/outlet shown in the citation (e.g. AEPP); may be blank.
#           - "topic" = a topic key (must exist under publication_category: in
#                       docs/_config.yml). EVERY area's links.csv is read.
#
#  * The Publications pages are .Rmd sources you can edit independently, all
#    under  data-raw/scripts/pages/publications/ :
#        - publications.Rmd        -> docs/publications.md  (the AREA index)
#        - pub-<area>.Rmd          -> docs/_pages/topic-<area>.md (one per area)
#      Each pub-<area>.Rmd just calls pub_area_page("<area>") from site_helpers.R;
#      risk-management is the one area split into sub-topic sections.
#
#  * Add a NEW AREA (its own bullet on the index + its own page)
#        1. create  data-raw/publications/<area>/links.csv  with its papers,
#        2. add the area under  publication_category:  in  docs/_config.yml
#           (key = <area>, title = the heading shown), AND
#        3. copy an existing pages/publications/pub-<area>.Rmd to pub-<newarea>.Rmd
#           and change the pub_area_page("<newarea>") line.  Re-run this script.
#      To make an area have SUB-TOPICS (like risk-management), give its sub-topic
#      entries  group: <area>  in _config.yml and use those topic keys in links.csv.
#
#  * Your sidebar profile (name, photo, bio, email, Scholar/ORCID/GitHub/...)
#        -> edit  docs/_config.yml   (the  author:  block).  NOT this script.
#
#  * The top navigation menu
#        -> edit  docs/_data/navigation.yml .
#
#  * The look / theme (colors, layout)
#        -> docs/_sass/, docs/_includes/, docs/_layouts/ (AcademicPages theme).
#
#  * Scholar citation numbers   -> automatic (the .github workflow updates
#        data-raw/scholar-metrics.json; the badges read it live).
#  * Private-package READMEs     -> edit data-raw/private-packages-inventory.csv
#        then run  Rscript data-raw/scripts/update_private_packages.R .
#
# -----------------------------------------------------------------------------
#  HOW DO I ADD A WHOLE NEW PAGE/SECTION (e.g., "Teaching")?
# -----------------------------------------------------------------------------
#    1. Create the source:   data-raw/scripts/pages/teaching.Rmd
#    2. Add a job to the `jobs` list below, e.g.:
#         list(src = "teaching.Rmd", out = file.path(root,"docs","teaching.md"),
#              front = fm_ap("Teaching", "/teaching/"))
#    3. Add a menu entry in docs/_data/navigation.yml:
#         - title: "Teaching"
#           url: /teaching/
#    4. Re-run this script.
# =============================================================================

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required.", call. = FALSE)
}

## --- Locate the repository root (so paths work from anywhere) ----------------
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
if (length(file_arg) > 0) {
  root <- normalizePath(file.path(dirname(file_arg), "..", ".."))
} else {
  root <- normalizePath(getwd())
}
pages <- file.path(root, "data-raw", "scripts", "pages")   # <- the .Rmd sources
setwd(root)   # so helpers that read relative paths (docs/_config.yml) resolve

## --- Shared helpers ----------------------------------------------------------
##     ALL shared logic (front matter, manifest reading, citation formatting,
##     the topic index, area pages) lives in ONE documented file. The page .Rmd
##     sources `source()` the same file, so nothing is duplicated.
source(file.path(root, "data-raw", "scripts", "site_helpers.R"))   # provides fm_ap(), pub_*()

## --- BUILD PLAN: one row per page.  src (.Rmd) -> out (.md) -> front matter ---
##     To add a page, copy a line and point it at a new pages/*.Rmd source.
##     README.md (the GitHub profile) is plain markdown, so its front = NULL.
jobs <- list(
  list(src = "README.Rmd",              out = file.path(root, "README.md"),                       front = NULL),
  list(src = "home.Rmd",                out = file.path(root, "docs", "index.md"),                front = fm_ap("About me", "/", "single")),
  list(src = "aboutme/research.Rmd",    out = file.path(root, "docs", "research.md"),             front = fm_ap("My Research", "/research/", "single")),
  list(src = "aboutme/leadership.Rmd",  out = file.path(root, "docs", "leadership.md"),           front = fm_ap("My Leadership", "/leadership/", "single")),
  list(src = "aboutme/outreach.Rmd",    out = file.path(root, "docs", "outreach.md"),             front = fm_ap("My Outreach & Extension", "/outreach/", "single")),
  list(src = "aboutme/teaching.Rmd",    out = file.path(root, "docs", "teaching.md"),             front = fm_ap("My Teaching & Mentoring", "/teaching/", "single")),
  list(src = "working-papers.Rmd",      out = file.path(root, "docs", "working-papers.md"),       front = fm_ap("Working Papers", "/working-papers/")),
  list(src = "r-packages.Rmd",          out = file.path(root, "docs", "r-packages.md"),           front = fm_ap("R Packages", "/r-packages/")),
  list(src = "replication-packages.Rmd",out = file.path(root, "docs", "replication-packages.md"), front = fm_ap("Replication Packages", "/replication-packages/")),
  list(src = "metrics.Rmd",             out = file.path(root, "docs", "metrics.md"),              front = fm_ap("Research Metrics", "/metrics/")),
  list(src = "publications/publications.Rmd", out = file.path(root, "docs", "publications.md"),    front = fm_ap("Publications", "/publications/", "archive"))
)

## --- Renderer (knits one .Rmd -> .md and prepends its front matter) ----------
##     You normally don't need to touch this function.
render_one <- function(job) {
  message("- ", job$src, " -> ", sub(paste0(root, .Platform$file.sep), "", job$out, fixed = TRUE))
  tmpdir <- tempfile("render_"); dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  rmarkdown::render(
    input = file.path(pages, job$src),
    output_format = rmarkdown::github_document(html_preview = FALSE),
    output_file = "out.md", output_dir = tmpdir,
    knit_root_dir = root,        # so chunks can read repo paths (links.csv, etc.)
    quiet = TRUE
  )
  body <- readLines(file.path(tmpdir, "out.md"), warn = FALSE, encoding = "UTF-8")
  if (!is.null(job$front)) body <- c(job$front, "", body)
  dir.create(dirname(job$out), showWarnings = FALSE, recursive = TRUE)
  writeLines(body, job$out, useBytes = TRUE)
}
invisible(lapply(jobs, render_one))

## --- PUBLICATIONS AREA PAGES: render each pages/publications/pub-<area>.Rmd ----
##     One self-contained source per AREA (a folder in data-raw/publications/),
##     each sourcing site_helpers.R to list its papers; risk-management is grouped
##     into sub-topic sections. They render to docs/_pages/topic-<area>.md.
##     Area titles come from publication_category: in docs/_config.yml.
##     To add an area: create data-raw/publications/<area>/links.csv, register the
##     area under publication_category:, and copy a pub-<area>.Rmd (change the key).
cats        <- pub_categories()
area_titles <- setNames(cats$title, cats$key)
pubdir      <- file.path(pages, "publications")
unlink(list.files(file.path(root, "docs", "_pages"), pattern = "^topic-.*\\.md$", full.names = TRUE))
for (f in list.files(pubdir, pattern = "^pub-.*\\.Rmd$")) {
  key <- sub("^pub-(.*)\\.Rmd$", "\\1", f)
  ttl <- if (key %in% names(area_titles)) unname(area_titles[[key]]) else key
  render_one(list(
    src   = file.path("publications", f),
    out   = file.path(root, "docs", "_pages", sprintf("topic-%s.md", key)),
    front = fm_ap(ttl, sprintf("/publications/%s/", key), "archive")
  ))
}

message("\nAll pages rendered. Commit & push, then check https://ftsiboe.github.io/")
