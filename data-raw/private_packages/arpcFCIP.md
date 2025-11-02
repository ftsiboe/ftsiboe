arpcFCIP (Simulate and Benchmark Federal Crop Insurance Program (FCIP)
Outcomes)
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/arpcFCIP/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/arpcFCIP/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/arpcFCIP/graph/badge.svg?token=KBJI7A3P68)](https://codecov.io/gh/ftsiboe/arpcFCIP)
![R \>= 4.1](https://img.shields.io/badge/R-%3E=4.1-blue) [![Contributor
Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
<!-- badges: end -->

## 📖 Overview

`arpcFCIP` provides a unified workflow for simulating, calibrating, and
benchmarking outcomes under the Federal Crop Insurance Program (FCIP).
It harmonizes Statement of Business (SOB/TPU) data, builds
price-deflated baselines, applies elasticity-based demand shocks, and
projects insured acres, liability, total premium, subsidy, and indemnity
for reporting at national, state, or county levels.

### Core Capabilities

- Clean & aggregate SOB/TPU with an August cutover (`clean_sobtpu()`).
- Build a price-received deflator indexed to the base year
  (`get_price_indices()`).
- Calibrate demand elasticities by crop
  (`estimate_demand_elasticities()`).
- Estimate historic indemnification and projected LCRs
  (`estimate_historic_indemnification()`).
- Construct deflated baselines (`construct_baseline_business()`).
- Apply elasticity shocks to premiums/subsidies
  (`demand_shock_elasticity_based()`).
- Orchestrate multi-year simulations (`arpc_fcip_simulator()`).
- Produce benchmark roll-ups for reporting
  (`benchmark_arpc_fcip_outlook()`).

## 🔧 Installation

``` r
# install.packages("devtools")
devtools::install_github("ftsiboe/arpcFCIP", force = TRUE, upgrade = "never")
```

## ✨ Quick Start

``` r
library(arpcFCIP)
library(data.table)

sob_data     <- clean_sobtpu()
current_year <- max(sob_data$commodity_year, na.rm = TRUE)
price_idx    <- get_price_indices(current_year)
elast        <- estimate_demand_elasticities(estimation_window = 5)
hist_lcr     <- estimate_historic_indemnification(5, current_year, sob_data)

out_sim <- arpc_fcip_simulator(
  baseline_window          = 5,
  project_base_indemnity   = TRUE,
  current_year             = current_year,
  projection_window        = 5,
  sob_data                 = sob_data,
  price_indices            = price_idx,
  historic_indemnification = hist_lcr,
  demand_elasticities      = elast,
  current_policy           = 2026,
  premium_rate_adjustment  = TRUE
)

county_rollup <- benchmark_arpc_fcip_outlook(
  aggregation            = "county",
  preliminary_outlook    = out_sim,
  baseline_year          = current_year,
  project_base_indemnity = TRUE
)
head(county_rollup[])
```

## 🧠 Pipeline Diagram

``` r
clean_sobtpu()
   └─ sob_data
get_price_indices()
   └─ price_indices
estimate_demand_elasticities()
   └─ demand_elasticities
estimate_historic_indemnification()
   └─ historic_indemnification
      ↓
arpc_fcip_simulator()
   ├─ construct_baseline_business()
   ├─ demand_shock_elasticity_based()
   ├─ fcip_premium_rate_adjuster() [optional]
   └─ produces preliminary_outlook
      ↓
benchmark_arpc_fcip_outlook()
   └─ produces final benchmark roll-ups
```

## 📦 Reproducible Workflow

Outputs commonly saved under `data-raw/release/` include: -
`sob_data.rds` - `price_indices.rds` - `demand_elasticities_crop.rds` -
`historic_indemnification.rds` - `arpc_fcip_outlook_preliminary(.rds)` -
`arpc_fcip_outlook(.rds)`

## 🤝 Contributing

Contributions, issues, and feature requests are welcome. See [Code of
Conduct](code_of_conduct.md).

## 📬 Contact

Questions or collaboration ideas?  
Email **Francis Tsiboe** at <francis.tsiboe@ndsu.edu>.
