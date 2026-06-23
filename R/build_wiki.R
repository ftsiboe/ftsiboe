# Tools to generate a GitHub-wiki edition of the risk-management publications
# index from a links.csv file and a set of topic sub-folders.

# Topic taxonomy --------------------------------------------------------------

#' Topic taxonomy for the publications index
#'
#' Internal lookup table mapping each topic sub-folder to a display title and a
#' one-line scope note.
#'
#' @return A data frame with columns `folder`, `title`, and `scope`.
#' @noRd
.pub_topics <- function() {
  data.frame(
    folder = c("background-and-policy", "crop-insurance-demand", "crop-insurance-rating",
               "prevented-planting", "premium-and-interest-deferrals", "yield-modeling",
               "index-insurance", "impacts-of-crop-insurance", "safety-net-simulation",
               "climate-and-environment"),
    title  = c("Background & policy", "Crop insurance demand", "Crop insurance rating",
               "Prevented planting", "Premium & interest deferrals", "Yield modeling",
               "Index insurance", "Impacts of crop insurance", "Safety-net simulation",
               "Climate & environment"),
    scope  = c("Policy reviews, program overviews, portfolio size, and farm financial conditions.",
               "Participation, premium-subsidy response, and program adoption.",
               "Ratemaking, actuarial adjustments, and rating methods.",
               "Prevented-planting coverage, buy-up options, and their elimination.",
               "Interest deferrals on unpaid premiums during disaster years.",
               "Sub-county yield calibration, prediction, and volatility (incl. asymmetric information).",
               "Area- and agroclimatic-based index insurance products.",
               "Effects on farm revenue, technology, efficiency, and conservation practices.",
               "Agent-based and simulation models of safety-net design and resiliency.",
               "Climate-change exposure and environmental outcomes of insurance."),
    stringsAsFactors = FALSE)
}

# Ordering --------------------------------------------------------------------

#' Order publication file names newest-to-oldest
#'
#' Sorts by the first four-digit outlet year found in each file name, then by the
#' ARPC issue number (e.g. `2026-12` before `2026-01`), then alphabetically.
#'
#' @param fnames Character vector of file names.
#' @return Integer ordering vector suitable for subsetting `fnames`.
#' @noRd
.order_new_to_old <- function(fnames) {
  yr  <- as.integer(sub(".*?((?:19|20)\\d\\d).*", "\\1", fnames))
  num <- suppressWarnings(as.integer(sub(".*?(?:19|20)\\d\\d-(\\d+).*", "\\1", fnames)))
  num[is.na(num)] <- 0L
  order(-yr, -num, fnames)
}

# Entry rendering -------------------------------------------------------------

#' Render the Markdown bullet list for one topic folder
#'
#' @param folder_path Absolute or relative path to a topic folder.
#' @param links Data frame with columns `file` and `url`.
#' @param hub Character vector of ARPC hub URLs (flagged with a dagger).
#' @return A character vector of Markdown list lines.
#' @noRd
.pub_entries <- function(folder_path, links, hub) {
  files <- if (dir.exists(folder_path)) list.files(folder_path, pattern = "\\.pdf$") else character(0)
  if (!length(files)) return("*(no files yet)*")
  files <- files[.order_new_to_old(files)]
  vapply(files, function(f) {
    label <- tools::file_path_sans_ext(f)
    u <- links$url[match(f, links$file)]
    if (length(u) == 0L || is.na(u)) sprintf("- %s — _link pending_", label)
    else if (u %in% hub)             sprintf("- [%s](%s) †", label, u)
    else                             sprintf("- [%s](%s)", label, u)
  }, character(1))
}

# Main builder ----------------------------------------------------------------

#' Build a GitHub-wiki edition of the publications index
#'
#' Generates a multi-page GitHub wiki from a `links.csv` file (columns `file`,
#' `url`) and the topic sub-folders under `dir`. The wiki comprises a `Home.md`
#' landing page (intro, attribution, publication count, and a linked topic list
#' with per-topic counts), one page per topic (entries sorted newest-to-oldest,
#' each linking to its public DOI/URL), and a `_Sidebar.md` for navigation.
#' Entries whose URL is an ARPC hub page are flagged with a dagger.
#'
#' The wiki is a separate Git repository on GitHub
#' (`github.com/<user>/<repo>.wiki.git`); publish the generated pages by copying
#' them into a clone of that repository and pushing.
#'
#' @param dir Path to the publications directory containing the topic
#'   sub-folders and `links.csv`.
#' @param out_dir Directory to write the wiki pages to. Defaults to a `wiki/`
#'   sub-folder of `dir`.
#' @param author,scholar,orcid,linkedin Attribution details shown on the Home
#'   page.
#'
#' @return Invisibly, the path to `out_dir`. Called for the side effect of
#'   writing `Home.md`, `_Sidebar.md`, and one Markdown page per topic.
#'
#' @examples
#' \dontrun{
#' build_wiki("data-raw/publications/risk-management")
#' }
#'
#' @importFrom tools file_path_sans_ext
#' @importFrom utils read.csv
#' @export
build_wiki <- function(dir = ".",
                       out_dir  = file.path(dir, "wiki"),
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

  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

  n_pdf <- function(folder) {
    p <- file.path(dir, folder)
    if (dir.exists(p)) length(list.files(p, pattern = "\\.pdf$")) else 0L
  }
  total   <- sum(vapply(topics$folder, n_pdf, integer(1)))
  updated <- format(Sys.Date(), "%B %d, %Y")

  ## per-topic pages
  for (i in seq_len(nrow(topics))) {
    f <- topics$folder[i]
    writeLines(c(
      sprintf("# %s", topics$title[i]), "",
      sprintf("*%s*", topics$scope[i]), "",
      .pub_entries(file.path(dir, f), links, hub), "",
      "---", "",
      "[← Back to index](Home)"
    ), file.path(out_dir, paste0(f, ".md")))
  }

  ## Home
  home <- c(
    "# Risk Management — Publications Index", "",
    sprintf(paste0("Publications on **agricultural risk management and the farm safety net** ",
                   "sole/co-authored by **%s**, grouped by *broad topic area*. Each entry links ",
                   "to the publicly available version (journal DOI, USDA-ERS DOI, or AgEcon/ARPC); ",
                   "full-text PDFs are not hosted here."), author), "",
    sprintf("%d publications · last updated %s", total, updated), "",
    sprintf("**Find more:** [Google Scholar](%s) · [ORCID](%s) · [LinkedIn](%s)",
            scholar, orcid, linkedin), "",
    "## Topics", "")
  for (i in seq_len(nrow(topics))) {
    home <- c(home, sprintf("- [%s](%s) — %s _(%d)_",
                            topics$title[i], topics$folder[i], topics$scope[i],
                            n_pdf(topics$folder[i])))
  }
  home <- c(home, "",
            "† Recent ARPC item without an assigned DOI yet — links to the ARPC hub for now.")
  writeLines(home, file.path(out_dir, "Home.md"))

  ## Sidebar
  side <- c("**[Publications Index](Home)**", "")
  for (i in seq_len(nrow(topics))) {
    side <- c(side, sprintf("- [%s](%s)", topics$title[i], topics$folder[i]))
  }
  writeLines(side, file.path(out_dir, "_Sidebar.md"))

  message(sprintf("Wrote %d wiki pages to '%s' (%d publications).",
                  nrow(topics) + 2L, out_dir, total))
  invisible(out_dir)
}
