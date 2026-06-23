---
title: "Research Metrics"
permalink: /metrics/
layout: single
author_profile: true
---


<!-- Source for docs/metrics.md (GitHub Pages).
     The numbers are shown via dynamic shields.io badges that read
     data-raw/scholar-metrics.json at view time, so they stay current as long
     as the .github "Update Scholar Metrics" workflow keeps that JSON fresh —
     no site re-render needed when the metrics change. -->

Citation metrics from my [Google Scholar
profile](https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en).

![Citations](https://img.shields.io/badge/dynamic/json?label=Citations&query=$.citations&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=4285F4&style=for-the-badge)
![h-index](https://img.shields.io/badge/dynamic/json?label=h-index&query=$.h_index&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=brightgreen&style=for-the-badge)
![i10-index](https://img.shields.io/badge/dynamic/json?label=i10--index&query=$.i10_index&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=informational&style=for-the-badge)

The badges above read
[`data-raw/scholar-metrics.json`](https://github.com/ftsiboe/ftsiboe/blob/main/data-raw/scholar-metrics.json),
which the **Update Scholar Metrics** GitHub Actions workflow
(`.github/workflows/R-google-scholar-profile.yaml`) refreshes from
Google Scholar on a weekly and monthly schedule. Because the b