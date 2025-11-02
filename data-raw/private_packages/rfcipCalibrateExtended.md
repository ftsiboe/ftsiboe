rFarmPolicySim (US Farm Policy Simulator)
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rfcipCalibrateExtended/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rfcipCalibrateExtended/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rfcipCalibrateExtended/graph/badge.svg?token=323CT4QU2J)](https://codecov.io/gh/ftsiboe/rfcipCalibrateExtended)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![R \>= 4.0](https://img.shields.io/badge/R-%3E=4.0-blue)

<!-- badges: end -->

# Introduction

`rFarmPolicySim` provides a modular framework for simulating U.S. farm
policy outcomes. Built-in functions implement the Federal Crop Insurance
Program (FCIP), Noninsured Crop Disaster Assistance Program (NAP), Price
Loss Coverage (PLC), Agricultural Risk Coverage (ARC), and recent ad-hoc
disaster assistance initiatives, while an open API allows user-defined
program modules. Monte-Carlo engines evaluate alternative policy
scenarios and quantify impacts across a variety of representative
agents.

**Disclaimer:** This product uses data provided by the USDA, but is not
endorsed by or affiliated with USDA or the Federal Government.

# Installation

`rFarmPolicySim` can be installed directly from github using
`remotes::install_github("https://github.com/ftsiboe/rFarmPolicySim")`

# Supported Functionalities

Below is an at-a-glance guide to everything the package does today,
organized by conceptual “families.”  
Copy this section straight into your `README.Rmd` (or knit it on its
own) to give users a clear map of where to start.

------------------------------------------------------------------------

### FCIP Premium / Indemnity Calculators

- **`fcip_calculator`, `fcip_calculator_area`,
  `fcip_calculator_individual`** – Core engines that convert acreage,
  yield, and coverage choices into modeled premiums or indemnities.  
- **`calibrate_plan_residual_factor`** – Tunes residual‐loading factors
  so simulated loss experience matches history.  
- **`fcip_adm_aph`, `fcip_adm_index`** – Quick helpers to pull yield or
  index rating factors from RMA’s Actuarial Data Master (ADM).

------------------------------------------------------------------------

### FCIP Demand Predictors

- **`predict_initial_summary_of_business_crop`**,
  **`predict_final_summary_of_business_crop`** – Early- and late-season
  models that forecast producer take-up.  
- **`get_official_baseline_outcome`** – Retrieves USDA/RMA
  “ground-truth” SOBS datasets for benchmarking.

------------------------------------------------------------------------

### Producer Premium Subsidy Policy

- **`fcip_premium_subsidy_schedule`** – Current statutory subsidy tiers
  by coverage level, plan, and unit structure.  
- **`farmer_act_of_2024_premium_subsidy_adj`**,
  **`obbb_act_premium_subsidy_adj`** – Scenario toggles that layer
  proposed legislation onto the baseline schedule.

------------------------------------------------------------------------

### FCIP Re-insurance

- **`allocate_gain`, `allocate_loss`, `non_proportional_reinsurance`** –
  Allocates portfolio results into funds, then applies quota-share and
  stop-loss layers.  
- **`proportional_split_and_quota_share`,
  `fund_alocation_and_retention`** – Companion helpers that pick cession
  percentages and retention limits.  
- **`assign_state_group`, `fcip_reinsurance_dispatcher`,
  `reinsurance_control`, `revealed_aip_state_operation`** – Orchestrate
  state pooling and full-portfolio simulations.

------------------------------------------------------------------------

### Farm / Producer Revenue Calibration

- **`calibrate_yield`, `calibrate_farm_revenue`** – Bayesian/GLM tools
  that shrink farm-level variability toward county means.  
- **`get_calibration_data`, `rma_500_revenue_draw`** – Import and
  resample RMA unit-level data (Section 508(h) sample) for robust
  out-of-sample tests.

------------------------------------------------------------------------

### Policy Menu Construction & Evaluation

- **`construct_menu_option_fcip_basic`,
  `simulate_menu_revenue_fcip_basic`** – Build realistic coverage menus
  and simulate resulting revenue/payoff distributions.  
- **`fcip_menu_dispatcher`, `normalize_and_filter_menu`** – Pipeline
  utilities for sweeping large policy menus quickly.

------------------------------------------------------------------------

### Producer Preference Calibration

- **`calibrate_preferences`** – Recovers producer-level risk-preference
  parameters via maximum-likelihood estimation.  
- **`merit_function`, `merit_objective_function`,
  `merit_specification_catalog`** – Pre-built utility specs and wrappers
  for systematic model comparison.

------------------------------------------------------------------------

### Putting It All Together

Need a one-liner? Call **`fcip_reinsurance_dispatcher`** for a full
pipeline—from premium calculation, through subsidy application, to
re-insurance allocation—then layer on demand predictions with
**`predict_final_summary_of_business_crop`**.

All functions ship with detailed **Roxygen** docs and `@examples`; run
`?function_name` or browse `/man` for usage patterns and parameters.
