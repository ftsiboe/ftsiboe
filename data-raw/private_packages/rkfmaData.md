Tools for Kansas Farm Management Data Bank
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/ftsiboe/rkfmaData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ftsiboe/rkfmaData/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/ftsiboe/rkfmaData/graph/badge.svg?token=F3WBUUB4IA)](https://codecov.io/gh/ftsiboe/rkfmaData)
![R \>= 4.1](https://img.shields.io/badge/R-%3E=4.1-blue) [![Contributor
Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
<!-- badges: end -->

## 📦 Overview

`rkfmaData` provides reproducible tools for importing, cleaning, and
harmonizing the **Kansas Farm Management Association (KFMA)** databank.
It helps researchers and policy analysts standardize and assemble KFMA
records for cross-year, cross-region, and cross-survey analysis of farm
financial, production, and risk management data.

The package is designed to: - Build **consistent panel datasets** from
raw KFMA databank archives.  
- Compute **derived financial indicators** such as revenue, cost, and
insurance metrics.  
- Provide **standardized metadata** and location lookups across KFMA
associations.  
- Facilitate **reproducible research pipelines** for agricultural
economics and risk policy.

------------------------------------------------------------------------

## 🔒 Access and Acknowledgments

The **Kansas Farm Management Data Bank** is a **proprietary dataset**
hosted by the **Kansas State University Department of Agricultural
Economics**.  
Access to the databank requires direct permission from the department.

The tools and resources in the **rkfmaData** package were developed by
**Francis Tsiboe** during his **Ph.D. studies at Kansas State
University** and through ongoing collaborations with **Dr. Jesse Tack**
and **Dr. Jisang Yu**.  
These utilities are provided for reproducibility, transparency, and to
support future research collaborations using approved KFMA data access.

------------------------------------------------------------------------

## 🧩 Related Works Using KFMA Data

My research leveraging the Kansas Farm Management Data Bank and related
analytical tools includes:

- **Tsiboe, F., Turner, D., & Yu, J. (2025).** [*Utilizing large‐scale
  insurance data sets to calibrate sub‐county level crop
  yields.*](https://doi.org/10.1111/jori.12494) *Journal of Risk and
  Insurance,* 92(1), 139–165.  
- **Gaku, S., & Tsiboe, F. (2025).** [*Evaluation of alternative farm
  safety net program combination
  strategies.*](https://doi.org/10.1108/AFR-11-2023-0150) *Agricultural
  Finance Review,* 85(2), 254–273.  
- **Tsiboe, F., Tack, J., & Yu, J. (2024).** [*Farm‐level evaluation of
  area‐ and agroclimatic‐based index
  insurance.*](https://doi.org/10.1002/jaa2.77) *Journal of the
  Agricultural and Applied Economics Association,* 2(4), 616–633.  
- **Tsiboe, F., & Tack, J. (2024).** [*Utilizing Topographic and Soil
  Features to Improve Rating for Farm-Level Insurance
  Products.*](https://doi.org/10.1111/ajae.12218) *American Journal of
  Agricultural Economics,* 104(1), 52–69.

These studies illustrate how KFMA data, when carefully anonymized and
analyzed within approved protocols, can inform advances in crop
insurance design, yield modeling, and risk management at fine spatial
scales.

------------------------------------------------------------------------

## Installation

``` r
# Install devtools if needed
# install.packages("devtools")

# Install from GitHub
devtools::install_github("ftsiboe/rkfmaData", upgrade = "never")
```

------------------------------------------------------------------------

## 🔎 Quick tour

``` r
library(rkfmaData)

# Load the KFMA databank (unzipped CSVs within an archive directory)
kfmaDatabank <- load_kfma_databank("data-raw/databank_archive")

# Build farm-level characteristics panel
farmCharacteristics <- farm_characteristics(kfma_databank = kfmaDatabank)

# Extract insurance-related summaries
InsuranceCharacteristics  <- insurance(kfma_databank = kfmaDatabank)

# Extract Crop acreage, production, and price/yield 
cropProduction <- crop_acreage_production_price(kfma_databank = kfmaDatabank)

# Extract Accrual Crop Income   
accrualCropIncome <- accrual_crop_income(kfma_databank = kfmaDatabank)

# Extract Accrual Livestock Income
accrualIivestockIncome <- accrual_livestock_income(kfma_databank = kfmaDatabank)

# Extract Accrual Miscellaneous Farm Income
accrualMiscellaneousFarmIncome <- accrual_misc_farm_income(kfma_databank = kfmaDatabank)

# Extract Accrued Farm Income  
accrualFarmIncome <- accrual_farm_income(kfma_databank = kfmaDatabank)

# Crop Sales and Cash Income  
cropSalesCashIncome <- crop_sales_cash_income(kfma_databank = kfmaDatabank)

# Extract Cash Livestock Income and Purchases 
cashLivestockIncomeAndPurchases <- cash_livestock_income_and_purchases(kfma_databank = kfmaDatabank)

# Extract Accrual Farm Expense  
accrualFarmExpense <- accrual_farm_expense(kfma_databank = kfmaDatabank)
```

------------------------------------------------------------------------

## 📚 Package Structure

| Function | Purpose |
|----|----|
| `load_kfma_databank()` | Unzips and reads KFMA archive CSVs into structured tables |
| `farm_characteristics()` | Builds harmonized panel of farm attributes and revenue/cost variables |
| `insurance()` | Extracts and aggregates insurance-related income and expense metrics |
| `crop_acreage_production_price()` | Extract Crop acreage, production, and price/yield |
| `accrual_crop_income()` | Extract Accrual Crop Income |
| `accrual_livestock_income()` | Extract Accrual Livestock Income |
| `accrual_misc_farm_income()` | Extract Accrual Miscellaneous Farm Income |
| `accrual_farm_income()` | Extract Accrued Farm Income |
| `crop_sales_cash_income()` | Crop Sales and Cash Income |
| `cash_livestock_income_and_purchases()` | Extract Cash Livestock Income and Purchases |
| `accrual_farm_expense()` | Extract Accrual Farm Expense |
| `rkfmaData_control()` | Returns internal constants and reference mappings (crop codes, units, conversion factors) |
| `under development` | Returns internal constants and reference mappings (crop codes, units, conversion factors) |
| `under development` | Cash Miscellaneous Farm Income |
| `under development` | Accrued Farm Expense |
| `under development` | Cash Farm Expense |
| `under development` | Depreciation & Opportunity Cost Charges |
| `under development` | Asset Sales and Purchases |
| `under development` | Crop Inventories |
| `under development` | Livestock Inventories |
| `under development` | Miscellaneous Current Asset Inventories |
| `under development` | Non-Current Assets |
| `under development` | Liabilities |
| `under development` | Financial Ratios |
| `under development` | Family Living Expenses |
| `under development` | Family Nonfarm Income |
| `under development` | Family Nonfarm Expense |
| `under development` | Nonfarm Assets and Liabilities |

------------------------------------------------------------------------

## 🤝 Contributing

Contributions are very welcome!  
To propose a fix or feature, open an issue or pull request at: 🔗
<https://github.com/ftsiboe/rkfmaData/issues>

------------------------------------------------------------------------

## 📄 License

This package is released under the **GPL-3 License**. See the `LICENSE`
file for full details.

------------------------------------------------------------------------
