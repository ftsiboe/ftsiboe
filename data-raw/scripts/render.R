#!/usr/bin/env Rscript
# render.R — build the GitHub Pages (AcademicPages) site + the profile README
# from the .Rmd sources in data-raw/scripts/pages/, and (re)generate the
# AcademicPages _publications collection from the links.csv manifest.
#
# Run from the repository root:
#   Rscript data-raw/scripts/render.R
#
# Authoring rule: edit ONLY the .Rmd sources in data-raw/scripts/pages/ and
# data-raw/publications/risk-management/links.csv. Everything in docs/*.md and
# docs/_publications/ is generated.

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required.", call. = FALSE)
}

## Repository root --------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
if (length(file_arg) > 0) {
  root <- normalizePath(file.path(dirname(file_arg), "..", ".."))
} else {
  root <- normalizePath(getwd())
}
pages <- file.path(root, "data-raw", "scripts", "pages")

## Front matter helpers ---------------------------------------------------------
# AcademicPages page (themed, with author sidebar)
fm_ap <- function(title, permalink, layout = "single") {
  c("---",
    sprintf("layout: %s", layout),
    sprintf('title: "%s"', title),
    sprintf("permalink: %s", permalink),
    "author_profile: true",
    "---")
}

## Pages: source .Rmd -> output -> front matter ---------------------------------
jobs <- list(
  list(src = "README.Rmd",               out = file.path(root, "README.md"),                 front = NULL),
  list(src = "home.Rmd",                  out = file.path(root, "docs", "index.md"),          front = fm_ap("About me", "/", "single")),
  list(src = "working-papers.Rmd",        out = file.path(root, "docs", "working-papers.md"), front = fm_ap("Working Papers", "/working-papers/")),
  list(src = "r-packages.Rmd",            out = file.path(root, "docs", "r-packages.md"),     front = fm_ap("R Packages", "/r-packages/")),
  list(src = "replication-packages.Rmd",  out = file.path(root, "docs", "replication-packages.md"), front = fm_ap("Replication Packages", "/replication-packages/")),
  list(src = "metrics.Rmd",               out = file.path(root, "docs", "metrics.md"),        front = fm_ap("Research Metrics", "/metrics/"))
)

render_one <- function(job) {
  message("- ", job$src, " -> ", sub(paste0(root, .Platform$file.sep), "", job$out, fixed = TRUE))
  tmpdir <- tempfile("render_"); dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  rmarkdown::render(
    input = file.path(pages, job$src),
    output_format = rmarkdown::github_document(html_preview = FALSE),
    output_file = "out.md", output_dir = tmpdir,
    knit_root_dir = root, quiet = TRUE
  )
  body <- readLines(file.path(tmpdir, "out.md"), warn = FALSE, encoding = "UTF-8")
  if (!is.null(job$front)) body <- c(job$front, "", body)
  dir.create(dirname(job$out), showWarnings = FALSE, recursive = TRUE)
  writeLines(body, job$out, useBytes = TRUE)
}
invisible(lapply(jobs, render_one))

## Publications collection from links.csv (AcademicPages _publications) ----------
gen_publications <- function(root) {
  csv <- file.path(root, "data-raw", "publications", "risk-management", "links.csv")
  out <- file.path(root, "docs", "_publications")
  dir.create(out, showWarnings = FALSE, recursive = TRUE)
  unlink(list.files(out, pattern = "\\.md$", full.names = TRUE))  # rebuild clean
  m <- utils::read.csv(csv, stringsAsFactors = FALSE)
  slug <- function(s) { s <- sub("\\.pdf$", "", s, ignore.case = TRUE); s <- tolower(s)
    s <- gsub("[^a-z0-9]+", "-", s); s <- gsub("(^-|-$)", "", s); substr(s, 1, 80) }
  esc <- function(x) gsub('"', '\\\\"', x)
  for (i in seq_len(nrow(m))) {
    topic <- m$topic[i]; fname <- m$file[i]; url <- m$url[i]
    stem  <- sub("\\.pdf$", "", fname, ignore.case = TRUE)
    parts <- trimws(strsplit(stem, " - ", fixed = TRUE)[[1]])
    title <- parts[length(parts)]
    authors <- if (length(parts) >= 3) parts[2] else ""
    yr <- regmatches(stem, regexpr("(19|20)[0-9]{2}", stem)); year <- if (length(yr)) as.integer(yr) else 2025L
    mm <- regmatches(stem, regexec("(?:19|20)[0-9]{2}-([0-9]+)", stem, perl = TRUE))[[1]]
    issue <- if (length(mm) >= 2) as.integer(mm[2]) else 0L
    venue <- sub("\\s+[0-9]{4}$", "", parts[1])
    d <- as.Date(sprintf("%d-01-01", year)) + (if (issue > 0) issue else 150L)
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
            sprintf('paperurl: "%s"', url),
            sprintf("citation: '%s'", cite),
            "---", "")
    writeLines(md, file.path(out, sprintf("%s-%s.md", format(d, "%Y-%m-%d"), sl)), useBytes = TRUE)
  }
  message(sprintf("- generated %d publications -> docs/_publications/", nrow(m)))
}
gen_publications(root)

message("\nAll pages rendered.")
