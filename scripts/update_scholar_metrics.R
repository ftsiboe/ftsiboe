#!/usr/bin/env Rscript

# scripts/update_scholar_metrics.R

# — install these via your workflow or a requirements file:
# install.packages(c("httr","rvest","jsonlite"), repos="https://cloud.r-project.org")

library(httr)
library(rvest)
library(jsonlite)

SCHOLAR_URL <- "https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en"
OUT_FILE    <- "scholar-metrics.json"

# fetch the page with a browser‑like UA to avoid blocking
resp <- GET(
  SCHOLAR_URL,
  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
)

if (status_code(resp) != 200) {
  warning("Failed to fetch Google Scholar (status ", status_code(resp), ")")
  quit(status = 0)  # don’t fail the workflow  
}

page <- read_html(resp)

# parse the metrics
citations <- page %>% 
  html_node("#gsc_rsb_st tr:nth-child(1) td:nth-child(2)") %>% 
  html_text() %>% 
  gsub(",", "", .) %>% as.integer()

h_index <- page %>% 
  html_node("#gsc_rsb_st tr:nth-child(2) td:nth-child(2)") %>% 
  html_text() %>% 
  gsub(",", "", .) %>% as.integer()

i10_index <- page %>% 
  html_node("#gsc_rsb_st tr:nth-child(3) td:nth-child(2)") %>% 
  html_text() %>% 
  gsub(",", "", .) %>% as.integer()

metrics <- list(
  citations = citations %||% 0,
  h_index   = h_index   %||% 0,
  i10_index = i10_index %||% 0
)

# write out JSON
write_json(metrics, OUT_FILE, auto_unbox = TRUE, pretty = TRUE)
message("✔ Updated ", OUT_FILE, ": ", toString(metrics))
