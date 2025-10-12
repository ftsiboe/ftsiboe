#!/usr/bin/env Rscript

# ---- Config ----
SCHOLAR_URL <- "https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en"
OUT_FILE    <- "data-raw/scholar-metrics.json"
MAX_TRIES   <- 6
BASE_WAIT   <- 2  # seconds (exponential backoff)

# ---- Fetch HTML with headers & retries ----
get_html <- function(url) {
  if(!requireNamespace("curl", quietly = TRUE)) {
    install.packages("curl", repos = "https://cloud.r-project.org")
  }

  h <- curl::new_handle()
  curl::handle_setheaders(
    h,
    "User-Agent"      = paste0(
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
      "AppleWebKit/537.36 (KHTML, like Gecko) ",
      "Chrome/120.0.0.0 Safari/537.36"
    ),
    "Accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" = "en-US,en;q=0.9",
    "Referer"         = "https://www.google.com/"
  )

  for (i in seq_len(MAX_TRIES)) {
    try({
      res <- curl::curl_fetch_memory(url, handle = h)
      if (res$status_code == 200L && length(res$content) > 0) {
        return(rawToChar(res$content))
      } else if (res$status_code %in% c(403L, 429L)) {
        # backoff on forbidden / rate-limited
        wait <- BASE_WAIT * 2^(i - 1)
        message(sprintf("Received %d. Backing off for %.1fs (attempt %d/%d)…",
                        res$status_code, wait, i, MAX_TRIES))
        Sys.sleep(wait)
      } else {
        warning("Unexpected status: ", res$status_code)
        break
      }
    }, silent = TRUE)
  }
  return(NULL)
}

html <- get_html(SCHOLAR_URL)

if (is.null(html)) {
  warning("Could not fetch Google Scholar page (403/429 likely). Leaving previous JSON untouched.")
  quit(status = 0)  # don't fail CI
}

# ---- Parse metrics (same logic as yours) ----
raw_cells <- regmatches(
  html,
  gregexpr("<td[^>]*>[0-9,]+</td>", html, perl = TRUE)
)[[1]]

if (length(raw_cells) < 3) {
  warning("Unexpected page structure; found ", length(raw_cells), " numeric cells")
  quit(status = 0)
}

nums <- as.integer(gsub(",", "", gsub("<[^>]+>", "", raw_cells[c(1,3,5)])))

json_txt <- sprintf(
  "{\n  \"citations\": %d,\n  \"h_index\": %d,\n  \"i10_index\": %d\n}\n",
  nums[1], nums[2], nums[3]
)

dir.create(dirname(OUT_FILE), showWarnings = FALSE, recursive = TRUE)
cat(json_txt, file = OUT_FILE)
message("✔ Updated ", OUT_FILE, ": ", nums[1], "/", nums[2], "/", nums[3])
