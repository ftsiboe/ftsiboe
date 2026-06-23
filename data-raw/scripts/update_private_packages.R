#!/usr/bin/env Rscript
# Copy each private package's README into data-raw/private-packages/<package>.md
#
# Source locations are listed in an inventory file (columns: package, readme),
# so adding/moving a package only means editing the CSV — no code changes.
#   inventory: data-raw/private-packages-inventory.csv
#
# Run from the repository root:
#   Rscript data-raw/scripts/update_private_packages.R

inv_path <- "data-raw/private-packages-inventory.csv"
dest_dir <- "data-raw/private-packages"

if (!file.exists(inv_path)) {
  stop("Inventory not found: ", inv_path, call. = FALSE)
}
inv <- utils::read.csv(inv_path, stringsAsFactors = FALSE)
stopifnot(all(c("package", "readme") %in% names(inv)))
dir.create(dest_dir, showWarnings = FALSE, recursive = TRUE)

copied <- 0L
missing <- character(0)
for (i in seq_len(nrow(inv))) {
  pkg <- trimws(inv$package[i])
  src <- trimws(inv$readme[i])
  dest <- file.path(dest_dir, paste0(pkg, ".md"))
  if (file.exists(src)) {
    file.copy(src, dest, overwrite = TRUE, copy.mode = TRUE)
    message("OK       ", pkg, "  <-  ", src)
    copied <- copied + 1L
  } else {
    message("MISSING  ", pkg, "  (", src, ")")
    missing <- c(missing, pkg)
  }
}

message(sprintf("\nCopied %d/%d private-package READMEs into %s.",
                copied, nrow(inv), dest_dir))
if (length(missing)) {
  message("Not found (check inventory paths): ", paste(missing, collapse = ", "))
}
