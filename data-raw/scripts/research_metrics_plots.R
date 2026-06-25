# =============================================================================
#  research_metrics_plots.R  —  visual helpers for build_research_metrics.R
# -----------------------------------------------------------------------------
#  make_plots(TRAJ, TH, plot_dir, WINDOW) renders:
#    collective_impact.png                     — citation-weighted IF trajectory
#    themes_streamgraph_jel.png   / _keyword   — themes flowing over time
#    themes_bubble_jel.png        / _keyword   — year x term bubble timeline
#    themes_wordclouds_jel.png    / _keyword   — word clouds per era
#  JEL codes and keywords are drawn on SEPARATE plots. Every plot is guarded:
#  missing optional packages (ggstream, ggwordcloud) downgrade gracefully.
# =============================================================================

make_plots <- function(TRAJ, TH, plot_dir, WINDOW = 10) {
  have <- function(p) requireNamespace(p, quietly = TRUE)
  gg   <- have("ggplot2")
  if (gg) suppressMessages(library(ggplot2))
  PAL  <- c(JEL = "#c05621", keyword = "#2b6cb0")

  save_png <- function(file, plot, w = 9, h = 5.5) {
    if (gg) ggplot2::ggsave(file.path(plot_dir, file), plot, width = w, height = h, dpi = 150, bg = "white")
  }

  ## --- Collective impact-factor trajectory -----------------------------------
  if (gg && !is.null(TRAJ) && nrow(TRAJ)) {
    p1 <- ggplot(TRAJ, aes(year, collective_if)) +
      geom_line(linewidth = 1.1, colour = "#2b6cb0") +
      geom_point(aes(size = total_citations), colour = "#2b6cb0", alpha = .7) +
      scale_size_area(max_size = 7, name = "Citations\n(weight)") +
      labs(title = "Collective impact of the portfolio over time",
           subtitle = "Citation-weighted average of journal 2-yr mean citedness (open IF proxy)",
           x = NULL, y = "Collective IF") +
      theme_minimal(base_size = 12)
    save_png("collective_impact.png", p1)
  } else message("  [skip] collective_impact.png (need ggplot2 / data)")

  if (is.null(TH) || !nrow(TH)) { message("  [skip] theme plots (no JEL/keywords found)"); return(invisible()) }
  if (!gg) { message("  [skip] theme plots (install.packages('ggplot2'))"); return(invisible()) }

  ## helper: render the three theme views for ONE type ------------------------
  theme_views <- function(type) {
    d0  <- TH[TH$type == type, ]
    sfx <- tolower(type)
    col <- unname(PAL[type])
    lab <- ifelse(type == "JEL", "JEL codes", "keywords")
    if (!nrow(d0)) { message(sprintf("  [skip] %s plots (none found)", lab)); return(invisible()) }

    tot <- aggregate(papers ~ term, d0, sum); tot <- tot[order(-tot$papers), ]

    ## 1. streamgraph -- top 12 terms
    keep <- head(tot$term, 12)
    s <- aggregate(papers ~ year + term, d0[d0$term %in% keep, ], sum)
    p2 <- ggplot(s, aes(year, papers, fill = term))
    if (have("ggstream")) {
      p2 <- p2 + ggstream::geom_stream(type = "ridge", bw = .8) +
                 ggstream::geom_stream(type = "ridge", bw = .8, colour = "white", linewidth = .15)
    } else {
      message("  [note] install.packages('ggstream') for a true streamgraph; using stacked area")
      p2 <- p2 + geom_area(position = "stack", colour = "white", linewidth = .15)
    }
    p2 <- p2 + labs(title = paste0("How research themes evolved — ", lab),
                    subtitle = paste("Top", lab, "by paper count"),
                    x = NULL, y = "Papers (stacked)", fill = NULL) +
      theme_minimal(base_size = 12)
    save_png(paste0("themes_streamgraph_", sfx, ".png"), p2, w = 10, h = 6)

    ## 2. bubble timeline -- top ~22 terms, single colour for the type
    keep <- head(tot$term, 22)
    b <- aggregate(cbind(papers, citations) ~ year + term, d0[d0$term %in% keep, ], sum)
    ord <- aggregate(year ~ term, b, min); ord <- ord[order(ord$year), ]
    b$term <- factor(b$term, levels = rev(ord$term))
    p3 <- ggplot(b, aes(year, term, size = papers)) +
      geom_point(alpha = .8, colour = col) +
      scale_size_area(max_size = 9, name = "Papers") +
      labs(title = paste0("Theme bubble timeline — ", lab),
           subtitle = paste("When each", sub("s$", "", lab), "appears, sized by papers"),
           x = NULL, y = NULL) +
      theme_minimal(base_size = 11)
    save_png(paste0("themes_bubble_", sfx, ".png"), p3, w = 9, h = 7.5)

    ## 3. word clouds per era
    yr  <- range(d0$year)
    brk <- unique(round(seq(yr[1], yr[2] + 1, length.out = 4)))
    if (length(brk) >= 2 && have("ggwordcloud")) {
      d0$era <- cut(d0$year, breaks = brk, include.lowest = TRUE, right = FALSE, dig.lab = 4)
      cl <- aggregate(papers ~ term + era, d0, sum)
      cl <- do.call(rbind, lapply(split(cl, cl$era), function(s) head(s[order(-s$papers), ], 35)))
      p4 <- ggplot(cl, aes(label = term, size = papers)) +
        ggwordcloud::geom_text_wordcloud(colour = col, eccentricity = 1) +
        scale_size_area(max_size = 13) + facet_wrap(~era) +
        labs(title = paste0("Theme word clouds by era — ", lab)) +
        theme_minimal(base_size = 12)
      save_png(paste0("themes_wordclouds_", sfx, ".png"), p4, w = 11, h = 6)
    } else if (length(brk) >= 2) {
      message("  [skip] themes_wordclouds_", sfx, ".png (install.packages('ggwordcloud'))")
    }
  }

  theme_views("JEL")
  theme_views("keyword")
}
