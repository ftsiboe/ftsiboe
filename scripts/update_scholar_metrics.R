#!/usr/bin/env Rscript

# URL of your Google Scholar profile
SCHOLAR_URL <- "https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en"
OUT_FILE    <- "scholar-metrics.json"

# Fetch the HTML
html <- tryCatch({
  paste(readLines(SCHOLAR_URL, warn = FALSE), collapse = "\n")
}, error = function(e) {
  warning("Failed to download page: ", e$message)
  quit(status = 0)  # don’t fail the workflow
})

# Extract the first three <td>…</td> with numbers (citations, h-index, i10-index)
raw_cells <- regmatches(
  html,
  gregexpr("<td[^>]*>[0-9,]+</td>", html, perl = TRUE)
)[[1]]

if (length(raw_cells) < 3) {
  warning("Unexpected page structure; found ", length(raw_cells), " numeric cells")
  quit(status = 0)
}

# Strip tags, commas, convert to integer
nums <- as.integer(gsub(",", "", gsub("<[^>]+>", "", raw_cells[1:3])))

# Build JSON text manually
json_txt <- sprintf(
  "{\n  \"citations\": %d,\n  \"h_index\": %d,\n  \"i10_index\": %d\n}\n",
  nums[1], nums[2], nums[3]
)

# Write out
cat(json_txt, file = OUT_FILE)
message("✔ Updated ", OUT_FILE, ": ", nums[1], "/", nums[2], "/", nums[3])
