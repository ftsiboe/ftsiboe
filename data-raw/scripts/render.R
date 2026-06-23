#!/usr/bin/env Rscript
# render.R — single entry point that renders every page from its .Rmd source in
# data-raw/scripts/pages/ to the correct output location.
#
# Run from the repository root:
#   Rscript data-raw/scripts/render.R
#
# Authoring rule: edit ONLY the .Rmd sources in data-raw/scripts/pages/.
# The .md files this produces are generated artifacts.

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required. install.packages('rmarkdown')", call. = FALSE)
}

## Resolve the repository root (works whether run from root or elsewhere) -------
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
if (length(file_arg) > 0) {
  root <- normalizePath(file.path(dirname(file_arg), "..", ".."))
} else {
  root <- normalizePath(getwd())
}
pages <- file.path(root, "data-raw", "scripts", "pages")

## Build plan: source .Rmd  ->  output .md  ->  optional Jekyll front matter ----
fm_page <- function(title, permalink = NULL) {
  c("---", sprintf('title: "%s"', title),
    if (!is.null(permalink)) sprintf("permalink: %s", permalink), "---")
}
jobs <- list(
  list(src = "README.Rmd",               out = file.path(root, "README.md"),
       front = NULL),
  list(src = "README.Rmd",               out = file.path(root, "docs", "index.md"),
       front = fm_page("Francis Tsiboe")),
  list(src = "publication-risk-management.Rmd", out = file.path(root, "docs", "risk-management.md"),
       front = fm_page("Risk Management — Publications", "/risk-management/")),
  list(src = "publication-risk-management.Rmd", out = file.path(root, "data-raw", "publications", "risk-management", "README.md"),
       front = NULL),
  list(src = "r-packages.Rmd",           out = file.path(root, "docs", "r-packages.md"),
       front = fm_page("R Packages", "/r-packages/")),
  list(src = "replication-packages.Rmd", out = file.path(root, "docs", "replication-packages.md"),
       front = fm_page("Replication Packages", "/replication-packages/")),
  list(src = "working-papers.Rmd",       out = file.path(root, "docs", "working-papers.md"),
       front = fm_page("Working Papers", "/working-papers/")),
  list(src = "metrics.Rmd",              out = file.path(root, "docs", "metrics.md"),
       front = fm_page("Research Metrics", "/metrics/"))
)

render_one <- function(job) {
  message("• ", job$src, "  ->  ", sub(paste0(root, .Platform$file.sep), "", job$out, fixed = TRUE))
  tmpdir <- tempfile("render_"); dir.create(tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)
  rmarkdown::render(
    input         = file.path(pages, job$src),
    output_format = rmarkdown::github_document(html_preview = FALSE),
    output_file   = "out.md",
    output_dir    = tmpdir,
    knit_root_dir = root,     # relative paths in chunks resolve from repo root
    quiet         = TRUE
  )
  body <- readLines(file.path(tmpdir, "out.md"), warn = FALSE, encoding = "UTF-8")
  if (!is.null(job$front)) body <- c(job$front, "", body)
  dir.create(dirname(job$out), showWarnings = FALSE, recursive = TRUE)
  writeLines(body, job$out, useBytes = TRUE)
}

invisible(lapply(jobs, render_one))

## Multi-page GitHub wiki (uses the package function) ---------------------------
rm_dir <- file.path(root, "data-raw", "publications", "risk-management")
if (requireNamespace("ftsiboe", quietly = TRUE)) {
  ftsiboe::build_wiki(rm_dir)
} else if (requireNamespace("devtools", quietly = TRUE) &&
           file.exists(file.path(root, "DESCRIPTION"))) {
  devtools::load_all(root, quiet = TRUE)
  build_wiki(rm_dir)
} else {
  message("(Skipped wiki: install the package or 'devtools' to build wiki/.)")
}

message("\nAll pages rendered.")
