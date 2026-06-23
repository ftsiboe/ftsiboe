rfcipReSim (A Modular Simulator for FCIP Reinsurance Outcomes)
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rfcipReSim/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rfcipReSim/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rfcipReSim/graph/badge.svg?token=5PP9O74NZC)](https://codecov.io/gh/ftsiboe/rfcipReSim)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![R \>= 4.0](https://img.shields.io/badge/R-%3E=4.0-blue)
<!-- badges: end -->

# Introduction

`rfcipReSim` provides a modular framework for simulating reinsurance
outcomes under the Federal Crop Insurance Program (FCIP). Provides
seamless integration with the ‘rfcip’,
[`rmaADM`](https://github.com/dylan-turner25/rmaADM), ‘rfcipCalibrate’,
and ‘rfcipCalcPass’ packages to streamline data ingestion, scenario
generation, risk-sharing computations, and calibration workflows..

**Disclaimer:** This product uses data provided by the USDA, but is not
endorsed by or affiliated with USDA or the Federal Government.

# Installation

`rfcipReSim` can be installed directly from github using

``` r
# Demo-only installation of rfcipReSim from GitHub
# (chunk is set eval=FALSE so it will not actually run)
devtools::install_github(
  "ftsiboe/rfcipCalcPass",
  force      = TRUE,
  upgrade    = "never", auth_token = "insert token")
```

# Supported Functionalities
