#!/usr/bin/env Rscript
# =============================================================================
#  preview.R  —  R-only content preview of the site pages (no Ruby/Jekyll)
# =============================================================================
#  This renders a page's .Rmd source to a standalone HTML file and opens it in
#  your browser, so you can check content/links/ordering WITHOUT installing
#  Jekyll. NOTE: this shows the page CONTENT only — it does NOT show the
#  AcademicPages theme (sidebar, top nav, styling). For the fully themed site,
#  push and view https://ftsiboe.github.io/ftsiboe/ (GitHub builds it for you).
#
#  USAGE (from the repository root):
#    Rscript data-raw/scripts/preview.R                 # preview the Publications index
#    Rscript data-raw/scripts/preview.R pub-cocoa.Rmd   # preview one topic page
#    Rscript data-raw/scripts/preview.R home.Rmd
#  Or, interactively in R/RStudio:
#    source("data-raw/scripts/preview.R"); preview("publications.Rmd")
# =============================================================================

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required (install.packages('rmarkdown')).", call. = FALSE)
}

## --- locate repo root --------------------------------------------------------
.find_root <- function() {
  a <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", a[grep("^--file=", a)])
  if (length(f) > 0) normalizePath(file.path(dirname(f), "..", "..")) else normalizePath(getwd())
}

preview <- function(src = "publications.Rmd", root = .find_root()) {
  pages <- file.path(root, "data-raw", "scripts", "pages")
  if (!file.exists(file.path(pages, src))) {
    stop("No such page source: ", file.path(pages, src),
         "\nAvailable:\n  ", paste(list.files(pages, "\\.Rmd$"), collapse = "\n  "),
         call. = FALSE)
  }
  out <- file.path(tempdir(), sub("\\.Rmd$", ".html", src, ignore.case = TRUE))
  message("Rendering ", src, " -> ", out)
  rmarkdown::render(
    input         = file.path(pages, src),
    output_format = rmarkdown::html_document(self_contained = TRUE, theme = "readable"),
    output_file   = basename(out), output_dir = dirname(out),
    knit_root_dir = root,    # so chunks can read links.csv / _config.yml
    quiet         = TRUE
  )
  if (interactive()) utils::browseURL(out) else message("Open it in a browser:\n  ", out)
  invisible(out)
}

## run from the command line: Rscript preview.R [page.Rmd]
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  preview(if (length(args) >= 1) args[1] else "publications.Rmd")
}
