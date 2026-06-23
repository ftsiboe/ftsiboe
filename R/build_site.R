# Build a GitHub Pages (Jekyll) site for the publications index. Reuses the
# internal helpers defined in R/build_wiki.R (.pub_topics, .order_new_to_old,
# .pub_entries).

#' Build a GitHub Pages site for the publications index
#'
#' Generates a single-page Jekyll site (`index.md` + `_config.yml`) under
#' `docs/`, suitable for GitHub Pages "Deploy from a branch" using the `/docs`
#' folder on `main`. A normal `git push` then publishes the site. The page lists
#' every topic (with a jump-to table of contents and per-topic counts) and each
#' publication's public DOI/URL, sorted newest-to-oldest; ARPC hub links are
#' flagged with a dagger.
#'
#' `_config.yml` is written only if it does not already exist, so a customized
#' theme or settings are preserved across rebuilds; `index.md` is always
#' regenerated.
#'
#' @param dir Path to the publications directory containing the topic
#'   sub-folders and `links.csv`.
#' @param docs Output directory for the site (GitHub Pages source). Default
#'   `"docs"` (relative to the repository root).
#' @param site_title Title used in the page heading, front matter, and config.
#' @param theme A GitHub Pages supported Jekyll theme. Default
#'   `"jekyll-theme-cayman"`.
#' @param author,scholar,orcid,linkedin Attribution shown on the page.
#'
#' @return Invisibly, the path to `docs`. Called for the side effect of writing
#'   `index.md` (and `_config.yml` if absent).
#'
#' @examples
#' \dontrun{
#' build_site("data-raw/publications/risk-management")
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom utils read.csv
#' @export
build_site <- function(dir = ".",
                       docs = "docs",
                       site_title = "Risk Management — Publications Index",
                       theme = "jekyll-theme-cayman",
                       author   = "Francis Tsiboe, Ph.D.",
                       scholar  = "https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en",
                       orcid    = "https://orcid.org/0000-0001-5984-1072",
                       linkedin = "https://www.linkedin.com/in/francis-tsiboe-02b97248/") {

  topics <- .pub_topics()
  links_path <- file.path(dir, "links.csv")
  links <- if (file.exists(links_path)) {
    utils::read.csv(links_path, stringsAsFactors = FALSE)
  } else {
    data.frame(file = character(), url = character(), stringsAsFactors = FALSE)
  }
  hub <- c("https://www.arpc-ndsu.com/briefs", "https://www.arpc-ndsu.com/publications")

  dir.create(docs, showWarnings = FALSE, recursive = TRUE)
  n_pdf <- function(folder) {
    p <- file.path(dir, folder)
    if (dir.exists(p)) length(list.files(p, pattern = "\\.pdf$")) else 0L
  }
  total   <- sum(vapply(topics$folder, n_pdf, integer(1)))
  updated <- format(Sys.Date(), "%B %d, %Y")

  ## _config.yml (only if missing, to preserve customisation)
  cfg <- file.path(docs, "_config.yml")
  if (!file.exists(cfg)) {
    writeLines(c(
      sprintf('title: "%s"', site_title),
      'description: "Publications on agricultural risk management and the farm safety net, sole/co-authored by Francis Tsiboe."',
      sprintf("theme: %s", theme)
    ), cfg)
  }

  ## index.md
  md <- c(
    "---", sprintf('title: "%s"', site_title), "---", "",
    sprintf(paste0("Publications on **agricultural risk management and the farm safety net** ",
                   "sole/co-authored by **%s**, grouped by *broad topic area*. Each entry links ",
                   "to the publicly available version (journal DOI, USDA-ERS DOI, or AgEcon/ARPC); ",
                   "full-text PDFs are not hosted here."), author), "",
    sprintf("%d publications · last updated %s", total, updated), "",
    sprintf("**Find more:** [Google Scholar](%s) · [ORCID](%s) · [LinkedIn](%s)",
            scholar, orcid, linkedin), "",
    "**Browse:** [R Packages](r-packages/) · [Replication Packages](replication-packages/)", "",
    "## Contents", "")
  for (i in seq_len(nrow(topics))) {
    md <- c(md, sprintf("- [%s](#%s) _(%d)_",
                        topics$title[i], topics$folder[i], n_pdf(topics$folder[i])))
  }
  md <- c(md, "")
  for (i in seq_len(nrow(topics))) {
    md <- c(md,
            sprintf("## %s {#%s}", topics$title[i], topics$folder[i]), "",
            sprintf("*%s*", topics$scope[i]), "",
            .pub_entries(file.path(dir, topics$folder[i]), links, hub), "")
  }
  md <- c(md,
          "† Recent ARPC item without an assigned DOI yet — links to the ARPC hub for now.")
  writeLines(md, file.path(docs, "index.md"))

  message(sprintf("Wrote GitHub Pages site to '%s' (%d publications). Enable Pages: Settings → Pages → Deploy from a branch → main / docs.",
                  docs, total))
  invisible(docs)
}
