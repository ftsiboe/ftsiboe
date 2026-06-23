# =============================================================================
#  site_helpers.R  —  shared helpers for the Publications pages
# =============================================================================
#  Sourced by the page sources (data-raw/scripts/pages/publications.Rmd and
#  each pub-<topic>.Rmd). This is the ONE place the manifest is read and a
#  citation is formatted — edit here to change how every publication renders.
#  Paths are relative to the repo root (render.R knits with knit_root_dir = root).
#
#  CONTENTS
#    fm_ap()           build the AcademicPages YAML front matter for a page
#    pub_manifest()    read all links.csv into one data frame (adds `area` column)
#    pub_cite()        format one file name (+url) into a citation line
#    pub_topic_list()  print one topic's papers as a markdown list
#    pub_categories()  read keys + titles + group (in order) from _config.yml
#    pub_area_page()   print one area's page (risk-management = grouped sections)
#    pub_topic_index() print the Publications landing (areas + sub-topic bullets)
# =============================================================================

## --- PAGE FRONT MATTER -------------------------------------------------------
## Build the YAML header that makes a page use the AcademicPages theme (sidebar +
## masthead). `layout` is usually "single"; the Publications pages use "archive".
fm_ap <- function(title, permalink, layout = "single") {
  c("---",
    sprintf("layout: %s", layout),
    sprintf('title: "%s"', title),
    sprintf("permalink: %s", permalink),
    "author_profile: true",
    "---")
}

## --- PUBLICATIONS DATA + FORMATTING ------------------------------------------
## Read every area's links.csv (columns: topic, file, url) into one data frame,
## adding `area` = the folder name (data-raw/publications/<area>/links.csv).
pub_manifest <- function() {
  csvs <- list.files("data-raw/publications", pattern = "^links\\.csv$",
                     recursive = TRUE, full.names = TRUE)
  m <- do.call(rbind, lapply(csvs, function(f) {
    d <- utils::read.csv(f, stringsAsFactors = FALSE)[, c("topic", "file", "url")]
    d$area <- basename(dirname(f))
    d
  }))
  m$url[is.na(m$url)] <- ""
  m[nzchar(m$file), , drop = FALSE]
}

## Turn one "OUTLET YYYY[-n] - Authors - Title.pdf" (+ url) into a citation.
## Returns list(year, md) so callers can sort then print `md`.
pub_cite <- function(fname, url = "") {
  stem    <- sub("\\.pdf$", "", fname, ignore.case = TRUE)
  parts   <- trimws(strsplit(stem, " - ", fixed = TRUE)[[1]])
  vtok    <- parts[1]                                   # outlet token, e.g. "ARPC 2024-3"
  yr      <- regmatches(vtok, regexpr("(19|20)[0-9]{2}", vtok))
  title   <- parts[length(parts)]
  authors <- if (length(parts) >= 3) parts[2] else ""
  venue   <- sub("\\s+[0-9]{4}.*$", "", vtok)           # outlet, year stripped
  s <- paste0(if (nzchar(authors)) paste0(authors, " ") else "",
              if (length(yr)) sprintf("(%s). ", yr) else "",
              sprintf("“%s.” *%s*.", title, venue))
  if (nzchar(url)) s <- paste0(s, " [Full text](", url, ")")
  list(year = if (length(yr)) as.integer(yr) else 0L, md = s)
}

## Print one topic's papers as a markdown list, newest first. Use results="asis".
pub_topic_list <- function(topic, manifest = pub_manifest()) {
  m <- manifest[manifest$topic == topic, , drop = FALSE]
  if (nrow(m) == 0) { cat("*(no publications in this topic yet)*\n"); return(invisible()) }
  recs <- Map(pub_cite, m$file, m$url)
  recs <- recs[order(vapply(recs, function(x) x$year, numeric(1)), decreasing = TRUE)]
  for (r in recs) cat("- ", r$md, "\n", sep = "")
}

## Read publication_category from docs/_config.yml -> data.frame(key, title, group)
## (group is optional per entry; "" when absent). Order follows the file.
pub_categories <- function() {
  cfg  <- readLines("docs/_config.yml", warn = FALSE)
  i0   <- grep("^publication_category:", cfg)
  rest <- cfg[(i0 + 1):length(cfg)]
  endi <- which(grepl("^[^[:space:]#]", rest))[1]
  block  <- if (is.na(endi)) rest else rest[seq_len(endi - 1)]
  keyidx <- grep("^\\s{2}[A-Za-z0-9-]+:\\s*$", block)
  keys   <- sub("^\\s{2}([A-Za-z0-9-]+):\\s*$", "\\1", block[keyidx])
  ends   <- c(keyidx[-1] - 1, length(block))
  fld <- function(seg, name) {
    v <- grep(sprintf("^\\s{4}%s:", name), seg, value = TRUE)
    if (length(v)) gsub("^'|'$", "", trimws(sub(sprintf("^\\s{4}%s:\\s*", name), "", v[1]))) else ""
  }
  do.call(rbind, lapply(seq_along(keys), function(j) {
    seg <- block[keyidx[j]:ends[j]]
    data.frame(key = keys[j], title = fld(seg, "title"), group = fld(seg, "group"),
               stringsAsFactors = FALSE)
  }))
}

## Print one AREA's page (use results="asis"). If the area has sub-topics
## (entries with group == area, e.g. risk-management) it prints a "## Title"
## section per sub-topic (with an explicit {#key} anchor) and lists that
## sub-topic's papers; otherwise it lists the area's papers as a flat list.
pub_area_page <- function(area, manifest = pub_manifest(), cats = pub_categories()) {
  subs <- cats[cats$group == area, , drop = FALSE]
  if (nrow(subs) > 0) {
    for (i in seq_len(nrow(subs))) {
      if (sum(manifest$topic == subs$key[i]) == 0) next
      cat(sprintf("\n## %s {#%s}\n\n", subs$title[i], subs$key[i]))
      pub_topic_list(subs$key[i], manifest)
    }
  } else {
    pub_topic_list(area, manifest)            # area key == topic for single-topic areas
  }
}

## Print the Publications index (landing). Top-level AREAS (entries with no
## `group`) become bullets linking to their page; their sub-topics become
## sub-bullets linking to the matching section on that page (#anchor). Counts
## come from the manifests; empty areas/sub-topics are skipped. Use results="asis".
pub_topic_index <- function(base = "https://ftsiboe.github.io/ftsiboe/publications") {
  m <- pub_manifest(); cats <- pub_categories()
  ct <- function(k) sum(m$topic == k)
  areas <- cats[!nzchar(cats$group), , drop = FALSE]
  for (a in seq_len(nrow(areas))) {
    akey <- areas$key[a]
    subs <- cats[cats$group == akey, , drop = FALSE]
    nA <- if (nrow(subs)) sum(m$topic %in% subs$key) else ct(akey)
    if (nA == 0) next
    cat(sprintf("- [%s](%s/%s/) (%d)\n", areas$title[a], base, akey, nA))
    if (nrow(subs)) for (i in seq_len(nrow(subs))) {
      ns <- ct(subs$key[i]); if (ns == 0) next
      cat(sprintf("  - [%s](%s/%s/#%s) (%d)\n", subs$title[i], base, akey, subs$key[i], ns))
    }
  }
}
