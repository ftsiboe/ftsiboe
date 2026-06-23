rfcipPRF: Tools for RMA Pasture, Rangeland, and Forage (PRF) Insurance
Data and Policy Analysis
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rfcipPRF/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rfcipPRF/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rfcipPRF/graph/badge.svg?token=GLJOH2FR20)](https://codecov.io/gh/ftsiboe/rfcipPRF)
![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg) ![R
\>= 4.2](https://img.shields.io/badge/R-%3E=4.2-blue) [![Contributor
Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)
<!-- badges: end -->

**Acknowledgment:**  
The findings, methods, and code provided in this repository reflect the
views of the authors and not necessarily those of their institutions or
sponsors. This repository and its datasets are intended strictly for
research, educational, and analytical purposes.

------------------------------------------------------------------------

## Overview

The **`rfcipPRF`** package provides a reproducible framework for
**retrieving, cleaning, caching, and analyzing the USDA Risk Management
Agency’s Pasture, Rangeland, and Forage (PRF) insurance program
data**.  
These tools form the computational foundation for **actuarial research,
policy simulation, and economic evaluation** of weather-based risk
management products in the U.S. agricultural sector.

The PRF program provides coverage based on **Rainfall** and
**Vegetation** indices derived from NOAA and satellite data.
Understanding, replicating, and simulating these indices are critical
for evaluating risk exposure and program performance.

------------------------------------------------------------------------

## Key Features

- **Automated Data Discovery:**  
  Scrapes the official RMA PRF repository to build a manifest of all
  Rainfall, Vegetation, and Grid datasets available by year.

- **Official Grid Download:**  
  Fetches and extracts the authoritative PRF grid shapefile
  (`official_RMA_RI_grid.zip`) used to align rainfall and vegetation
  indices.

- **Index Retrieval and Cleaning:**  
  Identifies the latest rainfall index dataset, downloads, unzips, and
  standardizes it into a ready-to-use `.rds` file.

- **Cache Management:**  
  Manages a dedicated user cache directory for all PRF data; provides an
  easy `clear_rfcipPRF_cache()` helper.

- **Configuration Control:**  
  Customizable repository URLs and options for continuous integration or
  reproducible workflows through `rfcipPRF_control()`.

------------------------------------------------------------------------

## Motivation

Pasture, Rangeland, and Forage insurance is a cornerstone of the U.S.
agricultural risk management framework.  
However, PRF data—especially rainfall and vegetation indices—are
distributed across multiple file archives with complex naming
conventions.  
This package bridges that gap by offering:

- **A single reproducible access point** for PRF datasets.  
- **Clean data structures** for integration into econometric, actuarial,
  or GIS workflows.  
- **Reproducible caching** that minimizes redundant downloads.  
- **Integration-ready formats** for analysis in research centers,
  academic settings, or policy evaluations.

------------------------------------------------------------------------

## Installation

`rfcipPRF` can be installed directly from github using

``` r
# Demo-only installation of rfcipPRF from GitHub
# (chunk is set eval=FALSE so it will not actually run)
devtools::install_github(
  "ftsiboe/rfcipPRF",
  force      = TRUE,
  upgrade    = "never", auth_token = "insert token")
```

------------------------------------------------------------------------

## Settup for example Workflows

``` r

library(rfcipPRF)

# Wipe global environment (use with care in interactive sessions)
rm(list = ls(all = TRUE))

# Anchor the target year to "this year"
current_year <- as.numeric(format(Sys.Date(), "%Y"))

# Optional: clear rfcip package cache (Summary of Business / ADM cache)
rfcip::clear_rfcip_cache()

# Where we will write artifacts (RDS, TIFF, etc.)
output_directory <- "data-raw/example"
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}
```

## Example Workflow 01 - Basic PRF elements

``` r
library(rfcipPRF)
# Discover available PRF datasets (Rainfall, Vegetation, Grids)
prf_inventory <- fetch_prf_indices_urls()

# Download and extract the official PRF grid shapefile into output dir
fetch_official_prf_grid(
  output_directory = output_directory,
  official_prf_url = prf_inventory$rma_indices_repository_url)

# Step 3: Retrieve and save the latest Rainfall Index (.txt → cleaned .rds)
fetch_latest_prf_indices(
  rma_indices_inventory = prf_inventory$index_df,
  output_directory = output_directory)

# Create a PRF Grid-ID raster aligned to a CPC precipitation grid
rainfallIndicesRaster <- create_prf_raster(official_prf_grid_directory = output_directory)

# (Optional) Clear cache when done
clear_rfcipPRF_cache()
```

## Example Workflow 02 - Official PRF data from primary sources

``` r
library(rfcipPRF)
# Base rates/payment factors at grid level
res <-  get_prf_fcip_dataset(year=year, dataset = "rates", force = TRUE)

# Bring in county base value (price)
res <- res[
  get_prf_fcip_dataset(year=year, dataset = "county_base_value", force = TRUE), 
  on = c("commodity_year","state_code","county_code"),nomatch = 0, allow.cartesian=TRUE];gc()

# Smooth to mean values at the grid × interval × type × cov level
res <- res[
  , .(county_base_value = mean(county_base_value, na.rm= TRUE),
      base_rate = mean(base_rate, na.rm= TRUE),
      payment_factor = mean(payment_factor, na.rm= TRUE)), 
  by = .(commodity_year,state_code,county_code,grid_id,interval_code, type_code,coverage_level_percent)];gc()

# Attach PRF key dates by interval
res <- res[
  get_prf_fcip_dataset(year=year, dataset = "dates", force = TRUE), 
  on = c("commodity_year","state_code","county_code","type_code","interval_code"),nomatch = 0];gc()

# Attach subsidy percent by coverage level
res <- res[
  get_prf_fcip_dataset(year=year, dataset = "subsidy_percent", force = TRUE), 
  on = c("commodity_year","coverage_level_percent"),nomatch = 0];gc()

# (Optional) Clear cache when done
clear_rfcipPRF_cache()
```

------------------------------------------------------------------------

## Citation Metadata (for Grid Data)

**Originator:** Grazing Management Systems  
**Publication Date:** 8/22/2009  
**Title:** *official_RMA_RI_grid*  
**Edition:** 1.0  
**Geospatial Data Presentation Form:** vector digital data  
**Online Linkage:** <http://prfri-rma-map.tamu.edu/default.aspx>

**Abstract:**  
Official grid for the United States Department of Agriculture, Risk
Management Agency, Pasture, Rangeland and Forage Rainfall Index
Insurance program.  
Represents boundaries encompassing NOAA’s Unified Precipitation Database
daily rainfall rasters.

**Purpose:**  
Defines unique spatial cells where PRF rainfall and vegetation indices
are calculated for insurance rating and indemnity determination.

------------------------------------------------------------------------

## Intended Audience

- Agricultural economists and risk analysts  
- Policy researchers and academic collaborators  
- Graduate students studying agricultural insurance or weather-index
  modeling  
- Extension and outreach professionals working on USDA risk programs

------------------------------------------------------------------------

## Contributions and Collaboration

Community contributions are warmly welcomed!  
Please open [issues](https://github.com/ftsiboe/rfcipPRF/issues) or
submit pull requests.  
We especially welcome collaboration on: - PRF policy calibration
models, - Visualization of rainfall and vegetation indices, -
Integration with the broader **USFarmSafetyNetLab** tool ecosystem.

------------------------------------------------------------------------

## Acknowledgment

This package builds on public data published by the  
**USDA Risk Management Agency (RMA)** and the  
**NOAA Climate Prediction Center (CPC)**.  
All analyses, code, and derivatives must cite the RMA PRF data
repository.

------------------------------------------------------------------------

If you find this toolkit useful, please ⭐ star the project .
