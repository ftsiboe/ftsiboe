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
    d <- utils::read.csv(f, stringsAsFactors = FALSE)
    if (!"venue" %in% names(d)) d$venue <- ""
    d <- d[, c("topic", "file", "url", "venue")]
    d$area <- basename(dirname(f))
    d
  }))
  m$url[is.na(m$url)]     <- ""
  m$venue[is.na(m$venue)] <- ""
  m[nzchar(m$file), , drop = FALSE]
}

## Turn one file name "YEAR[-issue] - Authors - Title.pdf" (+ url, + venue from the
## manifest) into a citation. Returns list(year, md) so callers can sort by year.
pub_cite <- function(fname, url = "", venue = "") {
  stem  <- sub("\\.pdf$", "", fname, ignore.case = TRUE)
  parts <- trimws(strsplit(stem, " - ", fixed = TRUE)[[1]])   # YEAR[-issue] - Authors - Title
  ytok  <- parts[1]
  yr    <- regmatches(ytok, regexpr("(19|20)[0-9]{2}", ytok))
  if (length(parts) >= 3) {
    authors <- parts[2]; title <- paste(parts[3:length(parts)], collapse = " - ")
  } else if (length(parts) == 2) {
    authors <- ""; title <- parts[2]
  } else {
    authors <- ""; title <- stem
  }
  s <- paste0(if (nzchar(authors)) paste0(authors, " ") else "",
              if (length(yr)) sprintf("(%s). ", yr) else "",
              sprintf("“%s.”", title),
              if (nzchar(venue)) sprintf(" *%s*.", venue) else "")
  if (nzchar(url)) s <- paste0(s, " [Full text](", url, ")")
  list(year = if (length(yr)) as.integer(yr) else 0L, md = s)
}

## Print one topic's papers as a markdown list, newest first. Use results="asis".
pub_topic_list <- function(topic, manifest = pub_manifest()) {
  m <- manifest[manifest$topic == topic, , drop = FALSE]
  if (nrow(m) == 0) { cat("*(no publications in this topic yet)*\n"); return(invisible()) }
  recs <- Map(pub_cite, m$file, m$url, m$venue)
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
pub_topic_index <- function(base = "https://ftsiboe.github.io/publications") {
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

## --- SEARCHABLE "BROWSE ALL" LIST -------------------------------------------
## pub_record()      parse one file name into (year, authors, title) + venue/url
## pub_search_list() print a client-side searchable list of EVERY publication,
##                   grouped by top-level AREA (config order), newest first, with
##                   a search box + area filter (plain list rows, not cards).

## Parse "YEAR[-issue] - Authors - Title.pdf" into parts (same rules as pub_cite).
pub_record <- function(fname, url = "", venue = "") {
  stem  <- sub("\\.pdf$", "", fname, ignore.case = TRUE)
  parts <- trimws(strsplit(stem, " - ", fixed = TRUE)[[1]])
  ytok  <- parts[1]
  yr    <- regmatches(ytok, regexpr("(19|20)[0-9]{2}", ytok))
  if (length(parts) >= 3) {
    authors <- parts[2]; title <- paste(parts[3:length(parts)], collapse = " - ")
  } else if (length(parts) == 2) {
    authors <- ""; title <- parts[2]
  } else {
    authors <- ""; title <- stem
  }
  list(year = if (length(yr)) as.integer(yr) else 0L,
       authors = authors, title = title, venue = venue, url = url)
}

## HTML/attribute escaping for the searchable list.
.esc_html <- function(s) { s <- gsub("&", "&amp;", s, fixed = TRUE); s <- gsub("<", "&lt;", s, fixed = TRUE); gsub(">", "&gt;", s, fixed = TRUE) }
.esc_attr <- function(s) gsub('"', "&quot;", .esc_html(s), fixed = TRUE)

## Emit the search box, area <select>, grouped list, and filter script. Papers
## come from pub_manifest() (grouped by the folder = top-level area key), so the
## list stays in sync with links.csv automatically. Use results="asis".
pub_search_list <- function(manifest = pub_manifest(), cats = pub_categories()) {
  areas <- cats[!nzchar(cats$group), , drop = FALSE]
  areas <- areas[vapply(areas$key, function(k) sum(manifest$area == k) > 0, logical(1)), , drop = FALSE]
  cat('<style>\n')
  cat('.pub-controls{display:flex;flex-wrap:wrap;gap:0.6rem;align-items:center;margin:1rem 0 0.25rem;}\n')
  cat('.pub-controls input,.pub-controls select{font:inherit;padding:0.45rem 0.6rem;border:1px solid var(--global-border-color);border-radius:8px;background:transparent;color:var(--global-text-color);}\n')
  cat('.pub-controls input{flex:1 1 240px;min-width:200px;}\n')
  cat('.pub-count{font-size:0.8rem;color:var(--global-text-color-light);margin:0.35rem 0 0.5rem;}\n')
  cat('.pub-area-h{font-size:0.75rem;letter-spacing:0.04em;text-transform:uppercase;color:var(--global-text-color-light);margin:1.1rem 0 0.35rem;}\n')
  cat('.pub-item{padding:0.4rem 0;border-bottom:1px solid var(--global-border-color);line-height:1.55;}\n')
  cat('.pub-item .v{font-style:italic;color:var(--global-text-color-light);}\n')
  cat('.pub-empty{color:var(--global-text-color-light);font-style:italic;margin:0.5rem 0;}\n')
  cat('</style>\n\n')
  cat('<div class="pub-controls">\n')
  cat('<input id="pub-search" type="search" placeholder="Search title, author, year, or journal" aria-label="Search publications">\n')
  cat('<select id="pub-area" aria-label="Filter by area">\n')
  cat('<option value="">All areas</option>\n')
  for (i in seq_len(nrow(areas))) cat(sprintf('<option value="%s">%s</option>\n', areas$key[i], .esc_html(areas$title[i])))
  cat('</select>\n')
  cat('</div>\n')
  cat('<p id="pub-count" class="pub-count"></p>\n\n')
  cat('<div id="pub-list">\n')
  for (i in seq_len(nrow(areas))) {
    ak   <- areas$key[i]
    m    <- manifest[manifest$area == ak, , drop = FALSE]
    recs <- Map(pub_record, m$file, m$url, m$venue)
    recs <- recs[order(vapply(recs, function(x) x$year, numeric(1)), decreasing = TRUE)]
    cat(sprintf('<div class="pub-area" data-area="%s">\n', ak))
    cat(sprintf('<div class="pub-area-h">%s</div>\n', .esc_html(areas$title[i])))
    for (r in recs) {
      dt   <- .esc_attr(tolower(paste(r$authors, if (r$year > 0) r$year else "", r$title, r$venue)))
      cite <- paste0(
        if (nzchar(r$authors)) paste0(.esc_html(r$authors), " ") else "",
        if (r$year > 0) sprintf("(%d). ", r$year) else "",
        sprintf("&ldquo;%s.&rdquo;", .esc_html(r$title)),
        if (nzchar(r$venue)) sprintf(' <span class="v">%s.</span>', .esc_html(r$venue)) else "",
        if (nzchar(r$url)) sprintf(' <a href="%s">Full text</a>', .esc_attr(r$url)) else "")
      cat(sprintf('<div class="pub-item" data-area="%s" data-text="%s">%s</div>\n', ak, dt, cite))
    }
    cat('</div>\n')
  }
  cat('</div>\n')
  cat('<p id="pub-empty" class="pub-empty" hidden>No publications match your search.</p>\n\n')
  cat('<script>\n')
  cat('(function(){\n')
  cat('  var list=document.getElementById("pub-list");\n')
  cat('  if(!list){return;}\n')
  cat('  var items=Array.prototype.slice.call(list.querySelectorAll(".pub-item"));\n')
  cat('  var areas=Array.prototype.slice.call(list.querySelectorAll(".pub-area"));\n')
  cat('  var search=document.getElementById("pub-search");\n')
  cat('  var area=document.getElementById("pub-area");\n')
  cat('  var count=document.getElementById("pub-count");\n')
  cat('  var empty=document.getElementById("pub-empty");\n')
  cat('  function apply(){\n')
  cat('    var q=(search.value||"").toLowerCase().trim();\n')
  cat('    var af=area.value;\n')
  cat('    var shown=0;\n')
  cat('    items.forEach(function(it){\n')
  cat('      var okQ=!q||it.getAttribute("data-text").indexOf(q)>-1;\n')
  cat('      var okA=!af||it.getAttribute("data-area")===af;\n')
  cat('      var vis=okQ&&okA;\n')
  cat('      it.style.display=vis?"":"none";\n')
  cat('      if(vis){shown++;}\n')
  cat('    });\n')
  cat('    areas.forEach(function(sec){\n')
  cat('      var any=Array.prototype.slice.call(sec.querySelectorAll(".pub-item")).some(function(it){return it.style.display!=="none";});\n')
  cat('      sec.style.display=any?"":"none";\n')
  cat('    });\n')
  cat('    count.textContent=shown+" of "+items.length+" publications";\n')
  cat('    empty.hidden=shown>0;\n')
  cat('  }\n')
  cat('  search.addEventListener("input",apply);\n')
  cat('  area.addEventListener("change",apply);\n')
  cat('  apply();\n')
  cat('})();\n')
  cat('</script>\n')
}
