rfcipCalcPass (FCIP PASS-Based Calculators and Tools)
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rfcipCalcPass/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rfcipCalcPass/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rfcipCalcPass/graph/badge.svg?token=5PP9O74NZC)](https://codecov.io/gh/ftsiboe/rfcipCalcPass)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![R \>= 4.0](https://img.shields.io/badge/R-%3E=4.0-blue)
<!-- badges: end -->

# Introduction

`rfcipCalcPass` provides R implementations of calculators and tables
used in the Federal Crop Insurance Program’s (FCIP) Policy Acceptance
and Storage System (PASS). Includes tools for working with APH yields,
area and individual plan pricing, premium subsidies, and ADM-based
structures. Designed for use alongside the
[`rmaADM`](https://github.com/dylan-turner25/rmaADM) package. Functions
are based on formulas published in USDA Risk Management Agency (RMA),
Appendix III.M.13 Handbooks.

**Disclaimer:** This product uses data provided by the USDA, but is not
endorsed by or affiliated with USDA or the Federal Government.

See the
[LICENSE](https://github.com/ftsiboe/rfcipCalcPass/blob/main/LICENSE)
file in the repository’s root for details.

# Installation

`rfcipCalcPass` can be installed directly from github using

``` r
# Demo-only installation of rfcipCalcPass from GitHub
# (chunk is set eval=FALSE so it will not actually run)
devtools::install_github(
  "ftsiboe/rfcipCalcPass",
  force      = TRUE,
  upgrade    = "never", auth_token = "insert token")
```

# Supported Functionalities

Routes farm-level data to the appropriate FCIP premium (and optional
indemnity) calculator based on insurance plan codes. Currently supports

**Individual based basic plans**

- Yield Protection (YP) (code = 01)
- Actual Production History (APH) (code = 90)
- Revenue Protection (RP) (code = 02)
- Revenue Protection with Harvest Price Exclusion (RP-HPE) (code = 03)

**Group based basic plans**

- Area Yield Protection (AY) (code = 04)
- Area Revenue Protection (AR) (code = 05)
- Area Revenue Protection with Harvest Price Exclusion (AR-HPE) (code =
  06)
- Margin Protection (MP) (code = 16)
- Margin Protection with Harvest Price Exclusion(code = 17)

**Supplemental plans**

- Supplemental Coverage Option (SCO) (code = 31, 32 ,33)
- Enhanced Coverage Option (ECO) (code = 87, 88 ,89)

# Examples

**NOTE:** In all examples we use
`control = rfcipCalcPass_control(continuous_integration_session = TRUE)`
which instructs the code to load a small, deterministic subset of the
Actuarial Data Master (ADM) YTD ZIP archive—ideal for fast, safe
continuous-integration testing.

**Do not use** `continuous_integration_session = TRUE` in your own
projects. Instead, omit that argument (or set it to `FALSE`) so that the
functions pull in the full ADM dataset. See `?rfcipCalcPass_control` for
details.

These example are for illustrative purposes; actual figures depend on
location-specific actuarial documents.

Throughout these examples we assume that;

- The producer has 100% interest in the reported/planted area
- The producer prefers a price election percent of 100%

## Example 1: Calculations for individual-based basic crop insurance plans

This example shows how to calculate **liabilities**, **premiums**,
**subsidies**, and **indemnities** using individual-based basic crop
insurance plans.

We’ll use sample data for **Producer A**, who grows grain corn in
**Adair County, Iowa** during the **2020 crop year**.

*Key Information*

``` r
# Create a table of key information
producerA_info <- c(
  "Farm size (acres)"        = 100, 
  "Approved yield (bu/acre)" = 154.6,
  "Rate yield (bu/acre)"     = 120.8, 
  "Actual yield (bu/acre)"   = 80,
  "Actual price ($/bu)"      = 3.9)

# Display as a transposed table
knitr::kable(producerA_info, col.names = c("Value"), caption = "Key Figures for Producer A")
```

|                          | Value |
|:-------------------------|------:|
| Farm size (acres)        | 100.0 |
| Approved yield (bu/acre) | 154.6 |
| Rate yield (bu/acre)     | 120.8 |
| Actual yield (bu/acre)   |  80.0 |
| Actual price (\$/bu)     |   3.9 |

Key Figures for Producer A

**➡️ Next Steps: Plan and Coverage Comparison**

We’ll explore different combinations of:

- **Individual-based insurance plans: ** YP, APH, RP, and RP-HPE
- **Coverage levels: ** 50% to 85% in 5% increments

All under a Basic Unit (BU) structure — meaning the entire insured
acreage is treated as one unit for insurance purposes.

We will prepare a data table that includes:

- Producer A’s crop and location
- Insurance options (plans and coverage levels)
- The key figures listed above

This will help us compare how insurance choices affect financial
outcomes..

``` r

# Subset and prepare the insurance plan data for Producer A
producerA_farmdata1 <- copy(plan_comparison)[
  insurance_plan_code %in% c(1:3), 
  c("producer_id",FCIP_INSURANCE_POOL,FCIP_INSURANCE_ELECTION), with = FALSE]

# Add additional farm-specific information
producerA_farmdata1[, `:=`(
  commodity_year = 2020,
  reported_acres = producerA_info[["Farm size (acres)"]],
  rate_yield     = producerA_info[["Rate yield (bu/acre)"]],
  approved_yield = producerA_info[["Approved yield (bu/acre)"]],
  farm_yield     = producerA_info[["Actual yield (bu/acre)"]]
)]

# View structure (optional)
# knitr::kable(producerA_farmdata1, caption = "Producer A's Insurance Plan Data")
```

**🧮 Running the Insurance Calculator**

We now run the FCIP calculator using the prepared data to compute the
financial outcomes under different plans.

``` r

# Execute calculation using the FCIP calculator function
producerA_outcomes1 <- fcip_calculator(
  farmdata = producerA_farmdata1,
  calculate_indemnity = TRUE,
  control = rfcipCalcPass_control(continuous_integration_session=TRUE,adm_decoy_state_abb = "IA"))

producerA_outcomes1[,final_revenue := 
                      producerA_info[["Farm size (acres)"]]*
                      producerA_info[["Actual yield (bu/acre)"]]*
                      producerA_info[["Actual price ($/bu)"]] + 
                      indemnity_amount - producer_premium_amount]

write.csv(producerA_outcomes1,"data-raw/examples/producerA_outcomes1.csv")

# Optionally preview results
# knitr::kable(producerA_outcomes1, caption = "FCIP Calculation Results")
```

**📊 Discussion of Results**

The dataset (`producerA_outcomes1`) summarizes crop insurance outcomes
for Producer A under various insurance plan and coverage level
combinations. Key variables include:

- **Liability Amount**: Maximum insured value based on yield and price.
- **Total Premium & Subsidy**: The full premium and the government-paid
  portion.
- **Producer Premium**: The cost borne by the farmer.
- **Indemnity Amount**: The payout when actual revenue falls below the
  insured level.
- **Final Revenue**: Actual revenue based on realized yield and market
  price.

*Key Insights*:

- Premiums increase as coverage levels or liability increase — higher
  insurance protection costs more.
- Subsidies reduce the producer’s out-of-pocket costs significantly.
- Indemnities are triggered when final revenue is below liability — this
  occurs only for some combinations.
- Higher coverage levels generally result in higher premiums but also
  higher indemnities in low-yield years, offering greater protection.

``` r
# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
#> 
#> Attaching package: 'tidyr'
#> The following object is masked from 'package:testthat':
#> 
#>     matches
source("data-raw/stashedcodes/plot_themes.R")
# Prepare data
outcomes_df <- producerA_outcomes1 %>%
  mutate(
    Coverage_Level = coverage_level_percent * 100,
    Plan = case_when(
      insurance_plan_code == 1  ~ "Yield Protection (YP)",
      insurance_plan_code == 2  ~ "Revenue Protection (RP)",
      insurance_plan_code == 3  ~ "RP with Harvest Price Exclusion (RP-HPE)",
      TRUE ~ as.character(insurance_plan_code)
    ),
    Liability_per_acre = liability_amount / insured_acres,
    Indemnity_per_acre = indemnity_amount / insured_acres,
    Final_Revenue_per_acre = final_revenue / insured_acres,
    # Total_Premium_per_acre = total_premium_amount / insured_acres,
    Premium_Rate = premium_rate * 100,
    Subsidy_Rate = (subsidy_amount / total_premium_amount) * 100,
    Premium_Paid_Rate = (producer_premium_amount / total_premium_amount) * 100
  )

# Select and reshape for faceting
plot_data <- outcomes_df %>%
  select(Coverage_Level, Plan,
         Liability_per_acre,
         # Total_Premium_per_acre,
         Premium_Rate,
         Subsidy_Rate,
         Premium_Paid_Rate,
         Indemnity_per_acre,
         Final_Revenue_per_acre) %>%
  pivot_longer(
    cols = -c(Coverage_Level, Plan),
    names_to = "Metric",
    values_to = "Value"
  )

# Clean labels for readability
metric_labels <- c(
  Liability_per_acre = "(a) Liability per Acre ($)",
  Premium_Rate = " (b) Total Premium Rate (%)",
  Subsidy_Rate = " (c) Subsidy Rate (%)",
  Premium_Paid_Rate = " (d) Premium Paid Rate (%)",
  Indemnity_per_acre = " (e) Indemnity per Acre ($)",
  Final_Revenue_per_acre = " (f) Final Revenue per Acre ($)"
)

# Apply factor level order to ensure panels appear in sorted order
plot_data$Metric <- factor(plot_data$Metric, levels = names(metric_labels), labels = metric_labels)

# Define custom color mapping
custom_colors <- c(
  "Yield Protection (YP)" = "#00583d",
  "Revenue Protection (RP)" = "#FFC425",
  "RP with Harvest Price Exclusion (RP-HPE)" = "#51ABA0"
)

# Plot with facets
ggplot(plot_data, aes(x = Coverage_Level, y = Value, color = Plan)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
facet_wrap(~ Metric, scales = "free_y", labeller = labeller(Metric = metric_labels)) +
   scale_color_manual(values = custom_colors) +
  labs(
    title = "Insurance and Revenue Metrics by Coverage Level and Plan",
    x = "Coverage Level (%)",
    y = NULL,
    color = "Insurance Plan"
  ) +
plot_themes() + 
  theme(legend.title=element_text(size=8),
        legend.text=element_text(size=8),
        legend.position="bottom",
        strip.background = element_blank(),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10))
```

## <img src="man/figures/producerA_figure1-1.png" width="100%" />

## Example 2: Calculations for group-based basic crop insurance plans

This example demonstrates how to calculate **liabilities**,
**premiums**, **subsidies**, and **indemnities** using **group-based
crop insurance plans**.

We’ll continue with the same sample data for **Producer A**, who farms
grain corn in Adair County, Iowa.

In this example, we explore various combinations of:

- **Group-based insurance plans :** AYP, ARP, ARP-HPE, MP, and MP-HPE
- **Coverage levels :** 65% to 95% in 5% increments depending on the
  plan.

All under an **Optional Unit (OU) structure** — where the individual
plots that make up the farm are treated as separate units for insurance
purposes, rather than combined into a single block as in the Basic Unit
(BU) structure.

We will construct a data table similar to the one used in **Example 1**.

``` r

# Subset and prepare the insurance plan data for Producer A
producerA_farmdata2 <- copy(plan_comparison)[
  insurance_plan_code %in% c(4:6,16,17), 
  c("producer_id",FCIP_INSURANCE_POOL,FCIP_INSURANCE_ELECTION), with = FALSE]

# Add additional farm-specific information
producerA_farmdata2[, `:=`(
  commodity_year = 2020,
  reported_acres = producerA_info[["Farm size (acres)"]]
)]

# View structure (optional)
# knitr::kable(producerA_farmdata, caption = "Producer A's Insurance Plan Data")
```

**🧮 Running the Insurance Calculator**

``` r

# Execute calculation using the FCIP calculator function
producerA_outcomes2 <- fcip_calculator(
  farmdata = producerA_farmdata2,
  calculate_indemnity = TRUE,
  control = rfcipCalcPass_control(continuous_integration_session=TRUE,adm_decoy_state_abb = "IA"))

producerA_outcomes2[,final_revenue := 
                      producerA_info[["Farm size (acres)"]]*
                      producerA_info[["Actual yield (bu/acre)"]]*
                      producerA_info[["Actual price ($/bu)"]] + 
                      indemnity_amount - producer_premium_amount]

write.csv(producerA_outcomes2,"data-raw/examples/producerA_outcomes2.csv")

# Optionally preview results
# knitr::kable(producerA_outcomes2, caption = "FCIP Calculation Results")
```

------------------------------------------------------------------------

## Example 3: Calculations for individual-based basic crop insurance plans layered with a supplemental plan

<https://www.rma.usda.gov/sites/default/files/spotlights/Supplemental-Coverage-Option-20-SCO.pdf>

# 📚 Citation

If you find it useful, please consider staring the repository and citing
the following studies

- Tsiboe, F. and Turner, D. (2025). [Incorporating buy‐up price loss
  coverage into the United States farm safety
  net](https://onlinelibrary.wiley.com/doi/full/10.1002/aepp.13536).
  Applied Economic Perspectives and Policy.
- Tsiboe, F., et al. (2025). [Risk reduction impacts of crop insurance
  in the United
  States](https://onlinelibrary.wiley.com/doi/full/10.1002/aepp.13513#:~:text=In%20other%20words%2C%20on%20average,%2Dcrop%2Dyear%20revenue%20variability).
  Applied Economic Perspectives and Policy.
- Gaku, S. and Tsiboe, F. (2024). [Evaluation of alternative farm safety
  net program combination
  strategies](https://www.emerald.com/insight/content/doi/10.1108/afr-11-2023-0150/full/html).
  Agricultural Finance Review.

# 📬 Contact

Constructive feedback is highly appreciated, and collaborations using
this package are actively encouraged. Please reach out by sending emails
to Francis Tsiboe (<ftsiboe@hotmail.com>).
