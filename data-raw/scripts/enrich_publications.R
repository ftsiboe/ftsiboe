#!/usr/bin/env Rscript
# =============================================================================
#  enrich_publications.R  —  fill AJAE reference fields in every links.csv
# =============================================================================
#  Populates the AJAE (AAEA / Chicago author-date) reference columns used by
#  pub_ajae() in site_helpers.R:  authors, journal, volume, issue, pages, doi,
#  type.  Metadata come from Crossref (https://api.crossref.org).
#
#  RUN IT (from the repo root), then rebuild the site:
#      Rscript data-raw/scripts/enrich_publications.R
#      Rscript data-raw/scripts/render.R
#
#  BEHAVIOUR
#   * Only fills rows whose `authors` column is still EMPTY, so any manual
#     entries (e.g. the ARPC reports) are preserved. Delete a row's `authors`
#     value to force a refresh.
#   * DOI is taken from the `url` column when present; otherwise the script
#     asks Crossref for the best title match. Rows it can't resolve are left
#     blank and simply render in the fallback style until fixed.
#   * Results are cached in data-raw/publications/.crossref-cache.json so
#     re-runs only fetch new papers. Safe to run repeatedly; commit the CSVs.
#   * Non-fatal: network hiccups skip a row rather than stopping the run.
# =============================================================================

suppressWarnings(suppressMessages({
  if (!requireNamespace("jsonlite", quietly = TRUE))
    install.packages("jsonlite", repos = "https://cloud.r-project.org")
}))
library(jsonlite)

MAILTO <- "ftsiboe@hotmail.com"                       # polite pool identifier
CACHE  <- "data-raw/publications/.crossref-cache.json"
COLS   <- c("topic","file","url","venue","authors","journal","volume","issue","pages","doi","type")

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
cache  <- if (file.exists(CACHE)) fromJSON(CACHE, simplifyVector = FALSE) else list()

## --- Crossref helpers --------------------------------------------------------
cr_get <- function(url) {
  for (i in 1:3) {
    x <- tryCatch(fromJSON(URLencode(url), simplifyVector = FALSE), error = function(e) NULL)
    if (!is.null(x)) return(x)
    Sys.sleep(2 * i)
  }
  NULL
}

## Initials from a given name: "Robert J." -> "R.J.", "Chung-Ming" -> "C.M."
initials <- function(given) {
  toks <- Filter(nchar, strsplit(trimws(given %||% ""), "[[:space:].-]+")[[1]])
  if (!length(toks)) return("")
  paste0(toupper(substr(toks, 1, 1)), ".", collapse = "")
}

## Crossref author list -> AJAE string: "Family, F.M., G. Family, and H. Family"
ajae_authors <- function(auth) {
  if (is.null(auth) || !length(auth)) return("")
  nm <- vapply(seq_along(auth), function(i) {
    a <- auth[[i]]; fam <- trimws(a$family %||% ""); ini <- initials(a$given %||% "")
    if (i == 1) trimws(sub(",\\s*$", "", paste0(fam, ", ", ini)))
    else        trimws(paste0(ini, " ", fam))
  }, character(1))
  n <- length(nm)
  if (n == 1) return(nm[1])
  if (n == 2) return(paste0(nm[1], ", and ", nm[2]))
  paste0(paste(nm[-n], collapse = ", "), ", and ", nm[n])
}

extract_doi <- function(url) {
  m <- regmatches(url, regexpr("10\\.\\d{4,9}/[^[:space:]\"'<>]+", url %||% ""))
  if (length(m)) m[1] else ""
}

## Best-effort DOI discovery by title (used only when the url has no DOI).
find_doi <- function(title) {
  url <- sprintf("https://api.crossref.org/works?query.bibliographic=%s&rows=5&mailto=%s",
                 utils::URLencode(title, reserved = TRUE), MAILTO)
  x <- cr_get(url); if (is.null(x)) return("")
  items <- x$message$items %||% list()
  tl <- tolower(title)
  for (it in items) {
    t <- tolower((it$title %||% list(""))[[1]])
    if (nchar(t) && (startsWith(t, substr(tl, 1, 20)) || startsWith(tl, substr(t, 1, 20))))
      return(it$DOI %||% "")
  }
  if (length(items)) items[[1]]$DOI %||% "" else ""
}

## Fetch and cache the AJAE-relevant fields for one DOI.
work_fields <- function(doi) {
  if (!is.null(cache[[doi]])) return(cache[[doi]])
  x <- cr_get(sprintf("https://api.crossref.org/works/%s?mailto=%s", doi, MAILTO))
  if (is.null(x)) return(NULL)
  m <- x$message
  fields <- list(
    authors = ajae_authors(m$author %||% list()),
    journal = (m$`container-title` %||% list(""))[[1]] %||% "",
    volume  = m$volume %||% "",
    issue   = m$issue %||% "",
    pages   = m$page %||% (m$`article-number` %||% ""),
    doi     = m$DOI %||% doi
  )
  cache[[doi]] <<- fields
  fields
}

## --- Walk every manifest -----------------------------------------------------
csvs <- list.files("data-raw/publications", pattern = "^links\\.csv$",
                   recursive = TRUE, full.names = TRUE)
for (f in csvs) {
  d <- read.csv(f, stringsAsFactors = FALSE, check.names = FALSE)
  for (c in COLS) if (!c %in% names(d)) d[[c]] <- ""
  n_upd <- 0L
  for (i in seq_len(nrow(d))) {
    if (!nzchar(d$file[i]) || nzchar(d$authors[i])) next   # skip blank / already-filled
    ven <- d$venue[i]
    doi <- extract_doi(d$url[i])
    if (!nzchar(doi) && !grepl("^ARPC", ven))
      doi <- find_doi(sub("\\.pdf$", "", d$file[i], ignore.case = TRUE))
    if (!nzchar(doi)) next
    fl <- work_fields(doi); if (is.null(fl)) next
    d$authors[i] <- fl$authors
    d$doi[i]     <- fl$doi
    if (grepl("^ARPC|^USDA|ERS", ven)) {
      d$type[i] <- "report"
      if (!nzchar(d$journal[i])) d$journal[i] <- ven
    } else {
      d$type[i]   <- "article"
      d$journal[i] <- fl$journal
      d$volume[i]  <- fl$volume
      d$issue[i]   <- fl$issue
      d$pages[i]   <- fl$pages
    }
    n_upd <- n_upd + 1L
    Sys.sleep(0.5)
  }
  d <- d[, COLS]
  utils::write.csv(d, f, row.names = FALSE, na = "")
  message(sprintf("%-55s %d row(s) enriched", sub("^.*/publications/", "", f), n_upd))
}
writeLines(toJSON(cache, auto_unbox = TRUE, pretty = TRUE), CACHE)
message("\nDone. Now run:  Rscript data-raw/scripts/render.R")
