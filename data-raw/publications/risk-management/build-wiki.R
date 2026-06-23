#!/usr/bin/env Rscript
# Convenience runner for the Risk Management — Publications Index wiki.
#
# The implementation now lives in the package: ftsiboe::build_wiki()
# (source in R/build_wiki.R). This script just calls it for this directory.
#
# NOTE: superseded by data-raw/scripts/render.R (which also rebuilds the wiki).
# Usage (from the repository root):
#   Rscript data-raw/publications/risk-management/build-wiki.R
#
# Output: data-raw/publications/risk-management/wiki/ (Home.md, _Sidebar.md, topic pages)

target <- "data-raw/publications/risk-management"

if (requireNamespace("ftsiboe", quietly = TRUE)) {
  ftsiboe::build_wiki(target)
} else if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")          # load the in-development package
  build_wiki(target)
} else {
  stop("Install this package first (e.g. devtools::install() or devtools::load_all()).",
       call. = FALSE)
}
