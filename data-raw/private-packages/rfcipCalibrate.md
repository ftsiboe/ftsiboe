rfcipCalibrate: Tools for FCIP Calibrations
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rfcipCalibrate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rfcipCalibrate/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rfcipCalibrate/graph/badge.svg?token=NQCHWZQOMX)](https://codecov.io/gh/ftsiboe/rfcipCalibrate)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![R \>= 4.0](https://img.shields.io/badge/R-%3E=4.0-blue)

<!-- badges: end -->

# Introduction

`rfcipCalibrate` provides tools to **calibrate yields** and **infer
producer preferences** from farm-level Federal Crop Insurance Program
(FCIP) experience data. It implements methods from the recent literature
(see **Citation** below) to:

- convert revenue policies to yield-equivalent quantities,
- invert the RMA rating pipeline to recover **rate yields**,
- simulate **correlated yield–price** scenarios consistent with
  ADM/M-13,
- construct and evaluate producers’ **insurance menus**, and
- estimate **preference parameters** via quasi–revealed preference.

**Disclaimer:** This product uses data provided by USDA/RMA but is
neither endorsed by nor affiliated with USDA or the U.S. Government.

## Why this package?

- End-to-end FCIP calibration workflow, from raw SOB/ADM to calibrated
  yields and preferences.  
- Strict alignment with RMA procedures (e.g., M-13 yield/price
  simulation, plan-specific harvest-price rules).  
- Designed for **representative producer** analysis with transparent,
  reproducible steps.

## Requirements

- **R ≥ 4.0**

- Upstream FCIP related package dependency:

  - **`rfcip`** Accessing data from the FCIP
  - **`rfcipCalcPass`** Calculators and tables used in FCIP Policy
    Acceptance and Storage System (PASS)
  - **`rfcipDemand`** Tools to estimate FCIP demand
  - **`USFarmSafetyNetLab`** Centralized research outputs, analytical
    tools, and resources dedicated to U.S agricultural safety net
    programs

- Internet or local access to the requisite ADM/SOB sources (as
  configured in `rfcipCalcPass` controls)

# Installation

Install the development version from GitHub:

``` r
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
remotes::install_github("ftsiboe/rfcipCalibrate")
```

# 🚀 Quick Start

## Concept of Representative Agents

**Representative producers.**  
Defined by FCIP **Summary of Business by Type, Practice, Unit (SOBTPU)**
entries for continuously rated plans (YP, APH, RP, RP-HPE). Each SOBTPU
aggregates loss experience for producer groups sharing:

- contract choice (plan, coverage level, unit structure),
- insurance pool (county, crop, type, practice), and
- crop year.

This ensures producers within a SOBTPU faced identical policy menus and
rating parameters.

**Representative insurance agents** – coming soon.  
**Representative AIPs** – coming soon.  
**Representative Government** – coming soon.

------------------------------------------------------------------------

## Functionality 1: Calibrating yields for observed FCIP transactions

*The workflow for this functionality is drawn from [Tsiboe et
al. (2025)](https://onlinelibrary.wiley.com/doi/10.1111/jori.12494).*

For a target year, we pull SOB transactions (coverage type “A”, plans
1/2/3/90) and join matching ADM parameters; missing harvest prices for
yield plans are backfilled with the projected price. Revenue policies
(plans 2, 3) are converted to **yield-equivalent** values via
`adjust_revenue_to_yield_equivalence()`, rescaling liability by
projected/harvest price, using the higher price in plan-2 guarantees,
and recomputing indemnities with a zero floor. From these yield-basis
amounts we compute per-acre indemnified yield, an adjusted base premium
rate, and the approved yield implied by coverage.

We then **invert the rating step** with
`prepare_yield_calibration_data()`: `DEoptim` searches for the **rate
yield** that makes `rfcipCalcPass::calc_base_premium_rate()` match the
observed base rate (`rate_yield_optimizer()` provides the objective),
and we form α and δ from ADM rate components. In the calibration pass,
`calibrate_yield()` aligns the prepared current-year table with the
following year’s table and, for each match, selects production-history
lengths $T_0 \in [2,10]$, $T_1 \in [3,10]$ (with $T_1 \ge T_0$) and a
nonnegative yield offset $dy_{\text{Opt}}$ to minimize the next year’s
base-rate error. This implies an **initial calibrated yield**:
coverage×approved minus indemnified yield if there was a loss, or
coverage×approved plus the optimized offset otherwise.

Finally, we benchmark the no-indemnity subset to official historical
yields at three scopes—insurance pool, state×commodity×type×practice,
and commodity×type×practice—scaling to match group means while enforcing
a floor at coverage×approved. We coalesce these adjusted candidates
(pool → state → commodity), fall back to the initial value if needed,
and aggregate to producer-level contracts with weights and budgets.

``` r

# Download relevant SOB data 
sobtpu0 <- get_sob_data_extended(
  year = year, 
  state = "IA",
  crop = c(41,21,81,18,11,51), 
  control = quick_start_control
)
saveRDS(sobtpu0, file.path(dir_project, paste0(calibration_name,"_sobtpu_current.rds")))

sobtpu1 <- get_sob_data_extended(
  year = year + 1, 
  state = "IA",
  crop = c(41,21,81,18,11,51), 
  control = quick_start_control
)
saveRDS(sobtpu1, file.path(dir_project, paste0(calibration_name,"_sobtpu_subsequent.rds")))

# Prepare data for yield calibration  
sobtpu0_preped <- prepare_yield_calibration_data(sobtpu = sobtpu0, control = quick_start_control)
saveRDS(sobtpu0_preped, file.path(dir_project, paste0(calibration_name,"_sobtpu_preped_current.rds")))

sobtpu1_preped <- prepare_yield_calibration_data(sobtpu = sobtpu1, control = quick_start_control)
saveRDS(sobtpu1_preped, file.path(dir_project, paste0(calibration_name,"_sobtpu_preped_subsequent.rds")))

# Calibrate yields from observed insurance transactions
cal_yield <- calibrate_yield(
  sobtpu_current   = sobtpu0_preped, 
  sobtpu_subsequent= sobtpu1_preped, 
  control          = quick_start_control
)
saveRDS(cal_yield, file.path(dir_project, paste0(calibration_name,"_cal_yield.rds")))
```

------------------------------------------------------------------------

## Functionality 2: Generate 500 correlated revenue scenarios for Producer Revenue simulation

We generate **500 joint yield–price scenarios per producer** using the
RMA M-13 framework and ADM parameters so every menu alternative is
evaluated under the **same** stochastic outcomes. We first create a
proxy lookup rate: set `rate_yield` to the average of the contract’s
`rate_yield` and `calibrated_yield`, run
`rfcipCalcPass::fcip_calculator()` with indemnities off, and retain the
resulting `revenue_lookup_rate` as `rma_draw_lookup_rate`.

We then join ADM components—`beta_id` from **A00030_InsuranceOffer**,
`price_volatility_factor` and `harvest_price` from **A00810_Price**, and
combo revenue factors from **A01030_ComboRevenueFactor** (keyed on
`lookup_rate`, rounded to four decimals). M-13 primitives are computed
as `AdjMean = approved_yield * mean_quantity / 100`,
`AdjStdDev = approved_yield * standard_deviation_quantity / 100`, and
`LnMean = log(harvest_price) − (price_volatility_factor^2 / 2)`. From
**A01020_Beta** we retrieve 500-draw vectors for yield and price by
`beta_id`, then form **yield draws**
`pmax(0, draw * AdjStdDev + AdjMean)` and **price draws**
`pmin(2 * harvest_price, exp(draw * price_volatility_factor + LnMean))`.

To preserve cross-alternative correlation and provide common anchors, we
also compute the **pool-average yield path** (`rma_draw_yield_pool`) and
the **state–commodity–type–practice average price path**
(`rma_draw_price_pool`) for each draw. The result is one row per
producer with list-columns containing sequence numbers, farm-level yield
and price draws, pool/group paths, and the mean lookup rate.

``` r
revenue_draw <- rma_500_revenue_draw(
  farmdata         = cal_yield, 
  farm_identifiers = c("producer_id"), 
  control          = quick_start_control
)
saveRDS(revenue_draw, file.path(dir_project, paste0(calibration_name,"_revenue_draw.rds")))
```

------------------------------------------------------------------------

## Functionality 3: Construct insurance menu options with simulated revenues

For each producer, we **construct the feasible FCIP menu** for the study
year/location and **simulate revenues for every alternative** on the
**same 500 correlated** scenarios from Functionality 2.

`construct_menu_option_fcip()` tags records with `commodity_year`,
creates `producer_id` if needed, verifies required fields, and pulls the
ADM offerings. It assembles:  
(i) **none** – a no-insurance option (zero premium, full subsidy);  
(ii) **group/area plans** (AY `04`, AR `05`, AR-HPE `06`, MP `16`,
MP-HPE `17`) by averaging area rates, merging index/subsidy parameters,
and computing `menu_premium_per_liability`, `menu_subsidy_per_premium`,
`menu_subsidy_percent` (capped at 1);  
(iii) **individual plans** (YP `01`, RP `02`, RP-HPE `03`, APH `90`) by
merging farm yields with ADM eligibility/rate tables and calling
`rfcipCalcPass::fcip_calculator_individual()` per election.

`simulate_menu_revenue_fcip()` joins the menu to simulated draws, flags
the **observed** and **no-insurance** choices, attaches ADM
`projected_price`, and for each alternative/draw computes expected and
final yields (farm vs. area), **guaranteed yield**, **liability**,
**premium/subsidy**, plan-specific **harvest liability** rules,
**revenue count**, **indemnity**, and **net revenue**. It then
summarizes moments/risk metrics (`calculate_revenue_moments()`), orders
options within producers (observed → other insured → none), and returns
list-columns of indices, attributes, premiums/subsidies, liabilities,
and distribution summaries.

**Supported plans:**

- Yield Protection (YP) (code = 01)
- Actual Production History (APH) (code = 90)
- Revenue Protection (RP) (code = 02)
- Revenue Protection with Harvest Price Exclusion (RP-HPE) (code = 03)
- Area Yield Protection (AY) (code = 04)
- Area Revenue Protection (AR) (code = 05)
- Area Revenue Protection with Harvest Price Exclusion (AR-HPE) (code =
  06)
- Margin Protection (MP) (code = 16)
- Margin Protection with Harvest Price Exclusion(code = 17)

``` r
# Merge yield calibration with revenue simulations and rename revealed elections
revenue_draw <- readRDS(file.path(dir_project, paste0(calibration_name,"_revenue_draw.rds")))
cal_yield <- readRDS(file.path(dir_project, paste0(calibration_name,"_cal_yield.rds")))

cal_revenue <- cal_yield[revenue_draw, on = intersect(names(revenue_draw), names(cal_yield)), nomatch = 0]
setnames(cal_revenue, old = FCIP_INSURANCE_ELECTION, new = paste0("revealed_", FCIP_INSURANCE_ELECTION))
saveRDS(cal_revenue, file.path(dir_project, paste0(calibration_name,"_cal_revenue.rds")))

# Construct insurance menu options
menu_option <- construct_menu_option_fcip(
  farmdata         = cal_revenue,
  farm_identifiers = c("producer_id"), 
  year             = year, 
  control          = quick_start_control
)
saveRDS(menu_option, file.path(dir_project, paste0(calibration_name,"_menu_option.rds")))

# Simulate revenues for all available menu options on the same 500 draws
cal_menu <- simulate_menu_revenue_fcip(
  farmdata         = cal_revenue,
  menu_option      = menu_option,
  farm_identifiers = c("producer_id"),
  year             = year, 
  control          = quick_start_control
)
saveRDS(cal_menu, file.path(dir_project, paste0(calibration_name,"_cal_menu.rds")))
```

------------------------------------------------------------------------

## Functionality 4: Producer Preference Calibration

We recover how each producer trades off **expected revenue** and
**risk** by fitting a user-specified merit (utility) function to the
**observed insurance choice**. From Functionality 3 we take option-wise
expected revenue (`menu_mu`) as $\text{ret}$ and a risk measure
(`menu_vr`) as $\text{risk}$. Given a one-sided formula (default
translog in logs of `ret` and `risk`), `calibrate_preferences()` uses
Differential Evolution to search parameters $\theta \in [-10,10]^K$ that
minimize a composite loss with five components: (1) the **observed**
option (first) ranks highest; (2) the **no-insurance** option (last)
ranks lowest; (3) $\partial U/\partial \text{ret} > 0$ on average; (4)
$\partial U/\partial \text{risk} < 0$ on average; (5) a quadratic
penalty when the implied **MRS**
$= |\partial U/\partial \text{ret}| / |\partial U/\partial \text{risk}|$
exceeds 10.

With the optimal parameters, we evaluate utilities and derivatives at
each option, compute **percentile ranks** for observed and no-insurance
choices, report the parameter vector, marginal effects, elasticities,
**MRS**, and an **agent-type** label (“revenue maximizing and risk
averse/seek­ing” or “revenue minimizing …”). We also carry revealed
budget and acres to form a per-acre **free-acres cost** proxy and record
**divergence metrics** vs. max-return, min-risk, max-liability,
max-subsidy, min-premium, and min-paid options.

``` r

cal_menu <- readRDS(file.path(dir_project, paste0(calibration_name,"_cal_menu.rds")))
cal_revenue <- readRDS(file.path(dir_project, paste0(calibration_name,"_cal_revenue.rds")))

# Calibrate producer preferences via a translog merit function in log(ret) and log(risk)
cal_preference <- calibrate_preferences(
  agent_data      = merge(cal_revenue, cal_menu, by = c("producer_id"), all = FALSE),
  functional_form = ~ b0 + b1 * log(ret) + b2 * log(risk) +
                       b3 * log(ret)^2 + b4 * log(risk)^2 + b5 * log(ret) * log(risk)
)
saveRDS(cal_preference, file.path(dir_project, paste0(calibration_name,"_cal_preference.rds")))
```

# 📚 Citation

If you use **`rfcipCalibrate`** in your research, please cite:

- Tsiboe, Turner, & Yu (2025). [Utilizing large‐scale insurance data
  sets to calibrate sub-county level crop
  yields](https://onlinelibrary.wiley.com/doi/10.1111/jori.12494).
  *JRI*.
- Tsiboe & Turner (2025). [Incorporating buy-up price loss coverage into
  the United States farm safety
  net](https://onlinelibrary.wiley.com/doi/full/10.1002/aepp.13536).
  *AEPP*.
- Tsiboe et al. (2025). [Risk reduction impacts of crop insurance in the
  United
  States](https://onlinelibrary.wiley.com/doi/full/10.1002/aepp.13513#:~:text=In%20other%20words%2C%20on%20average,%2Dcrop%2Dyear%20revenue%20variability).
  *AEPP*.
- Gaku & Tsiboe (2024). [Evaluation of alternative farm safety net
  program combination
  strategies](https://www.emerald.com/insight/content/doi/10.1108/afr-11-2023-0150/full/html).
  *AFR*.
- Tsiboe et al. *Pseudo-Revealed Calibration of Farmer Preferences Over
  Agricultural Insurance Products* (working paper).

------------------------------------------------------------------------

# 🤝 Contributing

Contributions, issues, and feature requests are welcome. Please see the
[Code of Conduct](code_of_conduct.md).

------------------------------------------------------------------------

# 📬 Contact

Questions or collaboration ideas?  
Email **Francis Tsiboe** at <ftsiboe@hotmail.com>.  
If you find this useful, please ⭐ the repo!
