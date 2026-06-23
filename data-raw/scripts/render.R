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
#  Everything in docs/*.md and docs/_publications/ is GENERATED — don't hand-edit
#  those (your changes would be overwritten on the next run).
#
# -----------------------------------------------------------------------------
#  WHAT DO I EDIT TO CHANGE ... ?
# -----------------------------------------------------------------------------
#  * A page's wording (About, Working Papers, R Packages, Replication, Metrics)
#        -> edit the matching .Rmd in  data-raw/scripts/pages/
#           (README.Rmd = the GitHub profile page; home.Rmd = the site "About").
#
#  * Your publications (add / remove / fix a paper or its link)
#        -> edit   data-raw/publications/risk-management/links.csv
#           columns:  topic , file , url
#           - "file"  = the PDF's file name (kept locally; not pushed).
#           - "url"   = the PUBLIC link (journal DOI / USDA-ERS / AgEcon / ARPC).
#           - "topic" = one of the topic folder names (see TOPICS below).
#           render.R turns each row into docs/_publications/<date>-<slug>.md .
#
#  * Add a NEW publication TOPIC (a new heading on the Publications page)
#        1. use the new topic name in links.csv rows, AND
#        2. add it under  publication_category:  in  docs/_config.yml
#           (key = topic name, title = the heading shown).  No code change here.
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
  list(src = "metrics.Rmd",             out = file.path(root, "docs", "metrics.md"),              front = fm_ap("Research Metrics", "/metrics/"))
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

## --- PUBLICATIONS: build docs/_publications/*.md from links.csv ---------------
##     Driven entirely by the manifests — to add a paper, add a row to the
##     links.csv in its area folder, e.g. data-raw/publications/<area>/links.csv
##     (do NOT edit this code). EVERY area's links.csv is read and combined.
##     TOPICS (the `topic` column) must match the keys under
##     `publication_category:` in docs/_config.yml (risk-management sub-topics +
##     cocoa, production, gender, off-farm-work, demand-and-markets, sustainability,
##     food-security-and-poverty, biotechnology, rice, impact-evaluation).
##     A blank `url` is fine — the paper appears without a link.
gen_publications <- function(root) {
  pubroot <- file.path(root, "data-raw", "publications")
  out <- file.path(root, "docs", "_publications")
  dir.create(out, showWarnings = FALSE, recursive = TRUE)
  unlink(list.files(out, pattern = "\\.md$", full.names = TRUE))   # rebuild clean
  # read EVERY area's links.csv (columns: topic, file, url) and combine
  csvs <- list.files(pubroot, pattern = "^links\\.csv$", recursive = TRUE, full.names = TRUE)
  m <- do.call(rbind, lapply(csvs, function(f) {
    d <- utils::read.csv(f, stringsAsFactors = FALSE)
    d[, c("topic", "file", "url")]
  }))

  slug <- function(s) { s <- sub("\\.pdf$", "", s, ignore.case = TRUE); s <- tolower(s)
    s <- gsub("[^a-z0-9]+", "-", s); s <- gsub("(^-|-$)", "", s); substr(s, 1, 80) }
  esc <- function(x) gsub('"', '\\\\"', x)

  for (i in seq_len(nrow(m))) {
    topic <- m$topic[i]; fname <- m$file[i]; url <- m$url[i]
    if (is.na(url)) url <- ""
    stem  <- sub("\\.pdf$", "", fname, ignore.case = TRUE)
    parts <- trimws(strsplit(stem, " - ", fixed = TRUE)[[1]])  # "OUTLET YYYY - Authors - Title"
    title   <- parts[length(parts)]                            # title = text after last " - "
    authors <- if (length(parts) >= 3) parts[2] else ""
    vtok <- parts[1]                                          # outlet token only, e.g. "ARPC 2024-3"
    yr <- regmatches(vtok, regexpr("(19|20)[0-9]{2}", vtok)); year <- if (length(yr)) as.integer(yr) else 2025L
    mm <- regmatches(vtok, regexec("(?:19|20)[0-9]{2}-([0-9]+)", vtok, perl = TRUE))[[1]]
    issue <- if (length(mm) >= 2) as.integer(mm[2]) else 0L     # ARPC issue # (for ordering)
    venue <- sub("\\s+[0-9]{4}$", "", parts[1])                # outlet, year stripped
    d <- as.Date(sprintf("%d-01-01", year)) + (if (issue > 0) issue else 150L)  # date -> sort order
    sl <- slug(fname)
    cite <- if (nzchar(authors))
      sprintf('%s (%d). &quot;%s.&quot; <i>%s</i>.', esc(authors), year, esc(title), esc(venue))
    else
      sprintf('(%d). &quot;%s.&quot; <i>%s</i>.', year, esc(title), esc(venue))
    md <- c("---",
            sprintf('title: "%s"', esc(title)),
            "collection: publications",
            sprintf("category: %s", topic),
            sprintf("permalink: /publication/%s", sl),
            sprintf("date: %s", format(d, "%Y-%m-%d")),
            sprintf('venue: "%s"', esc(venue)),
            if (nzchar(url)) sprintf('paperurl: "%s"', url) else NULL,  # omit when blank
            sprintf("citation: '%s'", cite),
            "---", "")
    writeLines(md, file.path(out, sprintf("%s-%s.md", format(d, "%Y-%m-%d"), sl)), useBytes = TRUE)
  }
  message(sprintf("- generated %d publications -> docs/_publications/", nrow(m)))
}
gen_publications(root)

message("\nAll pages rendered. Commit & push, then check https://ftsiboe.github.io/ftsiboe/")
