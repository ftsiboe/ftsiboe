#!/usr/bin/env Rscript
# =============================================================================
#  render.R  —  builds the website (docs/) + the GitHub profile README
# =============================================================================
#
#  RUN IT (from the repository root):
#      Rscript data-raw/scripts/render.R
#  then commit & push. GitHub Pages (Settings > Pages > Deploy from branch >
#  main / docs) rebuilds the site at https://ftsiboe.github.io/ftsiboe/ .
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
#           columns:  topic , file , url
#           - "file"  = the PDF's file name (kept locally; not pushed).
#           - "url"   = the PUBLIC link (journal DOI / USDA-ERS / AgEcon / ARPC);
#                       leave blank if none yet (paper shows without a link).
#           - "topic" = a topic key (must exist under publication_category: in
#                       docs/_config.yml). EVERY area's links.csv is read.
#
#  * The Publications page is built from .Rmd sources you can edit independently:
#        - pages/publications.Rmd          -> docs/publications.md  (the topic index)
#        - pages/pub-<topic>.Rmd           -> docs/_pages/topic-<topic>.md (one per topic)
#      Each pub-<topic>.Rmd lists its own topic's papers from the manifests.
#
#  * Add a NEW publication TOPIC (a new heading + its own page)
#        1. use the new topic key in links.csv rows,
#        2. add it under  publication_category:  in  docs/_config.yml
#           (key = topic key, title = the heading shown), AND
#        3. copy an existing pages/pub-<topic>.Rmd to pages/pub-<newkey>.Rmd and
#           change the `topic <- "<newkey>"` line inside.  Re-run this script.
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

## --- Front-matter helper -----------------------------------------------------
# Writes the YAML header that makes a page use the AcademicPages theme
# (sidebar + masthead). You normally don't touch this.
fm_ap <- function(title, permalink, layout = "single") {
  c("---",
    sprintf("layout: %s", layout),
    sprintf('title: "%s"', title),
    sprintf("permalink: %s", permalink),
    "author_profile: true",
    "---")
}

## --- BUILD PLAN: one row per page.  src (.Rmd) -> out (.md) -> front matter ---
##     To add a page, copy a line and point it at a new pages/*.Rmd source.
##     README.md (the GitHub profile) is plain markdown, so its front = NULL.
jobs <- list(
  list(src = "README.Rmd",              out = file.path(root, "README.md"),                       front = NULL),
  list(src = "home.Rmd",                out = file.path(root, "docs", "index.md"),                front = fm_ap("About me", "/", "single")),
  list(src = "working-papers.Rmd",      out = file.path(root, "docs", "working-papers.md"),       front = fm_ap("Working Papers", "/working-papers/")),
  list(src = "r-packages.Rmd",          out = file.path(root, "docs", "r-packages.md"),           front = fm_ap("R Packages", "/r-packages/")),
  list(src = "replication-packages.Rmd",out = file.path(root, "docs", "replication-packages.md"), front = fm_ap("Replication Packages", "/replication-packages/")),
  list(src = "metrics.Rmd",             out = file.path(root, "docs", "metrics.md"),              front = fm_ap("Research Metrics", "/metrics/")),
  list(src = "publications.Rmd",        out = file.path(root, "docs", "publications.md"),         front = fm_ap("Publications", "/publications/", "archive"))
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

## --- PUBLICATIONS TOPIC PAGES: render each pages/pub-<topic>.Rmd --------------
##     Each topic has its OWN self-contained source, pages/pub-<topic>.Rmd, which
##     reads the links.csv manifests and lists that topic's papers (edit those
##     files independently). They render to docs/_pages/topic-<topic>.md.
##     The landing index (pages/publications.Rmd -> docs/publications.md) is in
##     the `jobs` list above. Display titles/order come from `publication_category:`
##     in docs/_config.yml (single source of truth for headings).
pubcat_titles <- local({
  cfg <- readLines(file.path(root, "docs", "_config.yml"), warn = FALSE)
  i0  <- grep("^publication_category:", cfg)
  if (!length(i0)) return(setNames(character(0), character(0)))
  rest <- cfg[(i0 + 1):length(cfg)]
  endi <- which(grepl("^[^[:space:]#]", rest))[1]
  block <- if (is.na(endi)) rest else rest[seq_len(endi - 1)]
  keys   <- sub("^\\s{2}([A-Za-z0-9-]+):\\s*$", "\\1", grep("^\\s{2}[A-Za-z0-9-]+:\\s*$", block, value = TRUE))
  titles <- sub("^\\s{4}title:\\s*'(.*)'\\s*$", "\\1", grep("^\\s{4}title:", block, value = TRUE))
  setNames(titles, keys)
})

topic_srcs <- list.files(pages, pattern = "^pub-.*\\.Rmd$")
for (src in topic_srcs) {
  key <- sub("^pub-(.*)\\.Rmd$", "\\1", src)
  ttl <- if (key %in% names(pubcat_titles)) unname(pubcat_titles[[key]]) else key
  render_one(list(
    src   = src,
    out   = file.path(root, "docs", "_pages", sprintf("topic-%s.md", key)),
    front = fm_ap(ttl, sprintf("/publications/%s/", key), "archive")
  ))
}

message("\nAll pages rendered. Commit & push, then check https://ftsiboe.github.io/ftsiboe/")
