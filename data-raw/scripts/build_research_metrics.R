#!/usr/bin/env Rscript
# =============================================================================
#  build_research_metrics.R
# -----------------------------------------------------------------------------
#  Research-portfolio analytics over your publication list.
#
#  RUN FROM THE REPO ROOT:
#      Rscript data-raw/scripts/build_research_metrics.R
#
#  WHAT IT DOES
#  ------------
#  1. Reads every data-raw/publications/*/links.csv and pulls the DOI.
#  2. Enriches each paper from OpenAlex (free, no key): citation count,
#     citations-by-year, journal source, and the journal's 2-year mean
#     citedness — an OPEN, automatable stand-in for the Clarivate Journal
#     Impact Factor (the real JCR IF is paywalled and has no free API).
#  3. Reads author-assigned JEL codes and keywords straight from the local
#     PDF first pages; OpenAlex keywords are used as a fallback for keywords.
#  4. Keeps the PEER-REVIEWED JOURNAL subset (OpenAlex source type "journal";
#     ARPC briefs, USDA reports, working papers carry no IF/JEL and are dropped
#     from the impact math).
#  5. Writes:
#        data-raw/metrics/publications_enriched.csv   (one row per paper)
#        data-raw/metrics/collective_impact_by_year.csv
#        data-raw/metrics/themes_by_year.csv
#  6. Renders, to docs/assets/research-metrics/ (JEL and keywords on separate
#     plots):
#        collective_impact.png                    — citation-weighted IF trajectory
#        themes_streamgraph_jel.png / _keyword    — themes flowing over time
#        themes_bubble_jel.png      / _keyword    — bubble timeline (year x term)
#        themes_wordclouds_jel.png  / _keyword    — word clouds per era
#
#  COLLECTIVE IMPACT (your formula)
#  --------------------------------
#        Collective IF(Y) = Σ_i [ IF_i · C_i(Y) ] / Σ_i C_i(Y)
#  over papers i published in or before year Y, where C_i(Y) is paper i's
#  cumulative citations through year Y and IF_i is its journal's 2-yr mean
#  citedness. NOTE: IF_i is held at its current value (a full historical
#  per-year JCR series is not reconstructable from free data). To use official
#  IFs, drop a journal-by-year table in data-raw/metrics/if_overrides.csv
#  (columns: issn,year,impact_factor) and it will take precedence.
#
#  MANUAL OVERRIDES (optional, all read if present)
#  ------------------------------------------------
#    data-raw/metrics/jel_overrides.csv      doi,jel        (fill gaps the PDF
#                                            parser missed; ';'-separated codes)
#    data-raw/metrics/keyword_overrides.csv  doi,keywords   ('; '-separated)
#    data-raw/metrics/if_overrides.csv       issn,year,impact_factor
#
#  Safe to re-run: OpenAlex responses are cached under data-raw/metrics/cache/.
#  Delete that folder to force a full refresh.
# =============================================================================

email     <- "ftsiboe@hotmail.com"          # OpenAlex "polite pool" identifier
pub_root  <- "data-raw/publications"
out_dir   <- "data-raw/metrics"
cache_dir <- file.path(out_dir, "cache")
plot_dir  <- "docs/assets/research-metrics"
WINDOW    <- 10                              # years back for the IF series / eras

# locate the repo root so the script works from anywhere, then anchor there
local({
  a <- commandArgs(trailingOnly = FALSE)
  fa <- sub("^--file=", "", a[grep("^--file=", a)])
  if (length(fa)) setwd(normalizePath(file.path(dirname(fa), "..", "..")))
})
if (!dir.exists(pub_root))
  stop("Run from the repo root (can't see ", pub_root, ").", call. = FALSE)
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(plot_dir,  recursive = TRUE, showWarnings = FALSE)

need <- function(p) requireNamespace(p, quietly = TRUE)
if (!need("jsonlite")) stop("Please install.packages('jsonlite').", call. = FALSE)
has_pdftools <- need("pdftools")
if (!has_pdftools)
  message("NOTE: install.packages('pdftools') to read JEL/keywords from PDFs. ",
          "Without it, keywords fall back to OpenAlex and JEL stays empty.\n")

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
read_csv0 <- function(f) utils::read.csv(f, stringsAsFactors = FALSE, check.names = FALSE,
                                         colClasses = "character", encoding = "UTF-8")

doi_from_url <- function(u) {
  u <- trimws(u %||% "")
  if (!nzchar(u)) return(NA_character_)
  d <- sub("^https?://(dx\\.)?doi\\.org/", "", u, ignore.case = TRUE)
  if (grepl("^10\\.", d)) tolower(d) else NA_character_
}
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a

api_get <- function(url) {
  key  <- gsub("[^A-Za-z0-9]+", "_", url)
  cf   <- file.path(cache_dir, paste0(substr(key, 1, 120), ".rds"))
  if (file.exists(cf)) return(readRDS(cf))
  Sys.sleep(0.12)
  res <- tryCatch(
    jsonlite::fromJSON(paste0(url, ifelse(grepl("\\?", url), "&", "?"), "mailto=", email),
                       flatten = TRUE),
    error = function(e) NULL)
  if (!is.null(res)) saveRDS(res, cf)
  res
}

# author JEL + keywords from a local PDF (first 3 pages)
parse_pdf <- function(path) {
  empty <- list(jel = character(0), keywords = character(0))
  if (!has_pdftools || !file.exists(path)) return(empty)
  txt <- tryCatch(paste(pdftools::pdf_text(path)[1:3], collapse = " "),
                  error = function(e) "")
  txt <- gsub("\\s+", " ", txt)
  # --- JEL: anchor on "JEL", then grab the run of codes that follows ---------
  jel <- character(0)
  m <- regmatches(txt, regexpr("JEL[^A-Za-z0-9]{0,18}(?:classification|codes?|category|class)?[^A-Za-z0-9]{0,4}([A-Z][0-9]{1,2}(?:[^A-Za-z]{1,3}[A-Z][0-9]{1,2}){0,12})",
                                txt, ignore.case = TRUE, perl = TRUE))
  if (length(m)) jel <- unique(toupper(unlist(regmatches(m, gregexpr("[A-Z][0-9]{1,2}", m)))))
  # --- Keywords: text after "Keyword(s)" up to the next section marker -------
  kw <- character(0)
  k <- regmatches(txt, regexpr("Key ?words?[:\\.\\s]+(.{3,240}?)(?:JEL|Abstract|1\\.? Introduction|©|Article history|http)",
                               txt, ignore.case = TRUE, perl = TRUE))
  if (length(k)) {
    k <- sub("Key ?words?[:\\.\\s]+", "", k, ignore.case = TRUE, perl = TRUE)
    kw <- trimws(unlist(strsplit(k, "\\s*[,;•·|]\\s*")))
    kw <- kw[nchar(kw) > 1 & nchar(kw) < 60]
  }
  list(jel = jel, keywords = kw)
}

clean_terms <- function(x) {
  x <- tolower(trimws(x)); x <- x[nzchar(x)]
  x <- gsub("\\s+", " ", x)
  unique(x)
}

# -----------------------------------------------------------------------------
# 1. Collect publications (DOI + local PDF path) from the manifests
# -----------------------------------------------------------------------------
files <- list.files(pub_root, pattern = "^links\\.csv$", recursive = TRUE, full.names = TRUE)
rows  <- list()
for (f in files) {
  area <- basename(dirname(f))
  d    <- read_csv0(f)
  for (i in seq_len(nrow(d))) {
    doi <- doi_from_url(d$url[i])
    # PDF may live in <area>/<file> or, for risk-management, <area>/<topic>/<file>
    cand <- c(file.path(pub_root, area, d$file[i]),
              file.path(pub_root, area, d$topic[i], d$file[i]))
    pdf  <- cand[file.exists(cand)][1]
    rows[[length(rows) + 1]] <- data.frame(
      area = area, topic = d$topic[i], venue = d$venue[i], file = d$file[i],
      doi = doi %||% NA_character_, pdf = pdf %||% NA_character_,
      stringsAsFactors = FALSE)
  }
}
pubs <- do.call(rbind, rows)
pubs <- pubs[!is.na(pubs$doi), ]
message(sprintf("Found %d publications with a DOI.", nrow(pubs)))

# optional manual overrides
ov <- function(name) { p <- file.path(out_dir, name); if (file.exists(p)) read_csv0(p) else NULL }
jel_ov <- ov("jel_overrides.csv"); kw_ov <- ov("keyword_overrides.csv"); if_ov <- ov("if_overrides.csv")

# -----------------------------------------------------------------------------
# 2. Enrich from OpenAlex + PDFs
# -----------------------------------------------------------------------------
src_cache <- new.env()
get_source <- function(sid) {
  if (is.na(sid) || !nzchar(sid)) return(NULL)
  key <- sub(".*/", "", sid)
  if (!is.null(src_cache[[key]])) return(src_cache[[key]])
  s <- api_get(paste0("https://api.openalex.org/sources/", key))
  src_cache[[key]] <- s; s
}

enr <- vector("list", nrow(pubs))
for (i in seq_len(nrow(pubs))) {
  p   <- pubs[i, ]
  w   <- api_get(paste0("https://api.openalex.org/works/doi:", p$doi))
  yr  <- if (!is.null(w)) w$publication_year %||% NA else NA
  cit <- if (!is.null(w)) w$cited_by_count   %||% NA else NA
  cby <- if (!is.null(w) && !is.null(w$counts_by_year))
           setNames(w$counts_by_year$cited_by_count, w$counts_by_year$year) else NULL
  # nested access: a single OpenAlex work parses to nested lists, not dotted cols
  src <- if (!is.null(w)) w$primary_location$source else NULL
  sid <- src$id           %||% NA
  styp<- src$type         %||% NA
  jnm <- src$display_name %||% p$venue
  issn<- src$issn_l       %||% NA

  ifx <- NA_real_
  if (!is.na(sid)) { s <- get_source(sid)
    ifx <- if (!is.null(s)) (s$summary_stats$`2yr_mean_citedness` %||% NA) else NA }
  # official-IF override by ISSN (most recent year wins), if supplied
  if (!is.null(if_ov) && !is.na(issn)) {
    h <- if_ov[if_ov$issn == issn, , drop = FALSE]
    if (nrow(h)) ifx <- as.numeric(h$impact_factor[which.max(as.integer(h$year))])
  }

  pk  <- parse_pdf(p$pdf)
  jel <- pk$jel
  kw  <- pk$keywords
  if (length(kw) == 0 && !is.null(w$keywords) && !is.null(w$keywords$display_name))
    kw <- head(w$keywords$display_name, 6)                     # OpenAlex keyword fallback
  if (length(kw) == 0 && !is.null(w$concepts)) {
    cc <- w$concepts; cc <- cc[cc$level >= 1 & cc$score > 0.3, , drop = FALSE]
    kw <- head(cc$display_name, 6)
  }
  if (!is.null(jel_ov)) { hit <- jel_ov$jel[tolower(jel_ov$doi) == p$doi]
                          if (length(hit) && nzchar(hit[1])) jel <- trimws(strsplit(hit[1], ";")[[1]]) }
  if (!is.null(kw_ov))  { hit <- kw_ov$keywords[tolower(kw_ov$doi) == p$doi]
                          if (length(hit) && nzchar(hit[1])) kw <- trimws(strsplit(hit[1], ";")[[1]]) }

  enr[[i]] <- data.frame(
    doi = p$doi, area = p$area, topic = p$topic, year = yr, journal = jnm, issn = issn %||% NA,
    is_journal = identical(tolower(styp %||% ""), "journal"),
    citations = cit, if_proxy = round(as.numeric(ifx), 3),
    jel = paste(jel, collapse = ";"), keywords = paste(clean_terms(kw), collapse = ";"),
    cby = I(list(cby)), stringsAsFactors = FALSE)
  if (i %% 5 == 0) message(sprintf("  enriched %d/%d", i, nrow(pubs)))
}
E <- do.call(rbind, enr)

# scope: peer-reviewed journals only (drop briefs/reports/working papers)
J <- E[E$is_journal %in% TRUE & !is.na(E$year), ]
message(sprintf("Peer-reviewed journal articles in scope: %d of %d.", nrow(J), nrow(E)))

# write the per-paper table (drop the list column for CSV)
write.csv(E[, setdiff(names(E), "cby")],
          file.path(out_dir, "publications_enriched.csv"), row.names = FALSE)

if (nrow(J) == 0) {
  message("No journal-classified works returned by OpenAlex — wrote ",
          "publications_enriched.csv only (check your network or re-run).")
  quit(save = "no")
}

# -----------------------------------------------------------------------------
# 3. Collective impact-factor trajectory  (citation-weighted, by year)
# -----------------------------------------------------------------------------
cum_cit <- function(cby, upto) { if (is.null(cby)) return(0)
  y <- as.integer(names(cby)); sum(cby[y <= upto], na.rm = TRUE) }
years <- seq(max(min(J$year, na.rm = TRUE), max(J$year, na.rm = TRUE) - 30), max(J$year, na.rm = TRUE))
traj  <- lapply(years, function(Y) {
  idx <- which(J$year <= Y & !is.na(J$if_proxy))
  if (!length(idx)) return(NULL)
  w <- vapply(idx, function(i) cum_cit(E$cby[[match(J$doi[i], E$doi)]], Y), numeric(1))
  if (sum(w) == 0) w <- rep(1, length(idx))   # before any citations, weight equally
  data.frame(year = Y, collective_if = round(sum(J$if_proxy[idx] * w) / sum(w), 3),
             n_papers = length(idx), total_citations = sum(w))
})
TRAJ <- do.call(rbind, traj)
write.csv(TRAJ, file.path(out_dir, "collective_impact_by_year.csv"), row.names = FALSE)

# -----------------------------------------------------------------------------
# 4. Theme-by-year long table  (JEL codes + keywords)
# -----------------------------------------------------------------------------
long <- list()
for (i in seq_len(nrow(J))) {
  yr <- J$year[i]; ct <- max(J$citations[i], 0, na.rm = TRUE)
  for (term in clean_terms(strsplit(J$jel[i], ";")[[1]]))
    long[[length(long)+1]] <- data.frame(year=yr, type="JEL", term=toupper(term), papers=1, citations=ct)
  for (term in clean_terms(strsplit(J$keywords[i], ";")[[1]]))
    long[[length(long)+1]] <- data.frame(year=yr, type="keyword", term=term, papers=1, citations=ct)
}
TH <- do.call(rbind, long)
if (!is.null(TH)) {
  TH <- aggregate(cbind(papers, citations) ~ year + type + term, TH, sum)
  write.csv(TH[order(TH$year, -TH$papers), ], file.path(out_dir, "themes_by_year.csv"), row.names = FALSE)
}

# -----------------------------------------------------------------------------
# 5. Visualizations
# -----------------------------------------------------------------------------
source(file.path("data-raw", "scripts", "research_metrics_plots.R"), local = TRUE)
make_plots(TRAJ, TH, plot_dir, WINDOW)

message("\nDone.\n  data : ", out_dir, "/\n  plots: ", plot_dir, "/")
