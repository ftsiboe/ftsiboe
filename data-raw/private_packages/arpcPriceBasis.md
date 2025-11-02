Tools for Price and basis by Commodity and County
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/arpcPriceBasis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/arpcPriceBasis/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/arpcPriceBasis/graph/badge.svg?token=SHLOV6SJ8Y)](https://codecov.io/gh/ftsiboe/arpcPriceBasis)
![R \>= 4.1](https://img.shields.io/badge/R-%3E=4.1-blue) [![Contributor
Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
<!-- badges: end -->

# 📦 arpcPriceBasis

`arpcPriceBasis` provides tools to **download, harmonize, and analyze
agricultural price and basis data** at the **commodity** and **county**
level. It integrates multiple data sources (e.g., **DTN ProphetX**,
**USDA NASS Quick Stats**) and applies **econometric** and **spatial
calibration** methods to support **policy evaluation**,
**risk-management research**, and **farm-level decision tools**.

Key capabilities:

- 📥 **Acquisition**: automate DTN ProphetX retrieval (via Excel
  RTD/COM) and cache large NASS datasets.
- 🧼 **Cleaning**: convert DTN Excel extracts into tidy long/wide
  formats with safe date parsing.
- 📈 **Computation**: reconstruct futures from cash & basis, compute
  basis in cents, and align units.
- 🗺️ **Geospatial**: geocode elevator locations (ZIP-centroid + optional
  Census fallback); run **GWSS** to smooth and impute county-level gaps.
- 🔧 **Helpers**: build ProphetX and Bloomberg RTD formulas; chunk
  queries; create reproducible weekly/daily pipelines.

> Windows note: DTN ProphetX access relies on Excel RTD via COM (see
> examples below).  
> Pure R workflows (NASS processing, geocoding, GWSS, date utilities)
> work cross-platform.

------------------------------------------------------------------------

## Installation

``` r
# Install devtools if needed
# install.packages("devtools")

# Install from GitHub
devtools::install_github("ftsiboe/arpcPriceBasis", upgrade = "never")

# Optionally install suggested tools for COM on Windows
# (RDCOMClient is pulled via Remotes; ensure Office + R bitness match)
```

------------------------------------------------------------------------

## 🔎 Quick tour

### 1) Build a weekday date range (previous week, Mon–Fri)

``` r
library(arpcPriceBasis)

get_previous_weekdays_range("2025-10-12")
# $start_date
# [1] "2025-09-29"
# $end_date
# [1] "2025-10-03"
```

### 2) Download weekly DTN price files (sharded workload)

``` r
download_dtn_weekly_prices(
  crop             = c("soy", "corn"),
  market           = c("forward", "spot"),
  start_date       = as.Date("2025-09-22"),
  end_date         = as.Date("2025-09-26"),
  output_directory = "data-raw/fastscratch",
  work_station     = 1L,
  number_of_stations = 5L
)
```

> This generates a worklist of crop × date × market and saves daily
> `.rds` results under ISO year/week folders. Use
> `work_station`/`number_of_stations` for parallel sharding across
> machines.

### 3) Pull DTN prices programmatically (Excel RTD/COM on Windows)

``` r
dt <- get_dtn_price(
  crop       = "soy",
  market     = "forward",
  start_date = as.Date("2025-09-22"),
  end_date   = as.Date("2025-09-26")
)

# Columns include:
#   cash_price_open/close (USD), futures_price_open/close (USD),
#   basis_open/close (cents), geocode fields, and IDs (commodity/market/date).
```

### 4) Geocode market locations (ZIP centroid + optional Census)

``` r
geo <- geocode_locations(
  data         = dt,
  location_col = location_name,
  use_fallback = TRUE  # Census API for rows without ZIP match
)
```

### 5) Spatial smoothing / imputation by county (GWSS)

``` r
set.seed(123)
gw <- estimate_gwss_by_county(
  data        = data.table::as.data.table(geo),
  fip_col     = "county_fips",
  variable    = "basis_close",
  distance_metric = "Euclidean",
  kernel      = "gaussian",
  target_crs  = 5070,   # NAD83 / CONUS Albers
  draw_rate   = 0.5,    # CV sample fraction
  approach    = "CV",
  adaptive    = TRUE
)

# Merge a smoothed mean back to counties (example)
# counties_sf |>
#   dplyr::left_join(gw[, c("county_fips","value_LM")], by = "county_fips")
```

------------------------------------------------------------------------

## 🧰 Function map (selected)

- **Acquisition**
  - `download_dtn_weekly_prices()`
  - `downloaded_nass_large_datasets()`
- **DTN utilities**
  - `build_dtn_queries()`, `get_dtn_price()`,
    `get_dtn_price_by_symbol()`
  - `get_target_dates()`
- **Excel RTD helpers**
  - `dtn_prophetX_formula()`, `bloomberg_bds_formula()`
- **Geospatial & smoothing**
  - `estimate_gwss_by_county()`
- **Date/logic helpers**
  - `get_previous_weekdays_range()`, `first_trading_days()`,
    `is_weekend()`
- **Infra**
  - `arpcPriceBasis_control()`, `split_into_chunks()`,
    `clear_arpcPriceBasis_cache()`

------------------------------------------------------------------------

## ⚙️ Platform & prerequisites

- **Windows + Excel** required for RTD/COM workflows (DTN ProphetX,
  Bloomberg).
  - Ensure **R and Office bitness match** (both 64-bit recommended).
  - Sign into vendor add-ins with proper entitlements.
- **Cross-platform** workflows:
  - NASS downloads/processing, geocoding (ZIP centroid), GWSS, date
    utilities.

------------------------------------------------------------------------

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Please review the [Code of Conduct](code_of_conduct.md) and open an
issue or PR.

------------------------------------------------------------------------

## 🙏 Acknowledgments

This package grew out of workflow needs at the **Agricultural Risk
Policy Center (ARPC)** to bridge **Excel RTD** market data providers
(e.g., **DTN ProphetX**, **Bloomberg**) with reproducible **R**
pipelines, and to integrate USDA datasets for policy-relevant analysis.
