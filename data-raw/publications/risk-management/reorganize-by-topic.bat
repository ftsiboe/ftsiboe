@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  reorganize-by-topic.bat
REM  Moves the risk-management PDFs from output-type folders
REM  into broad topic-area folders.
REM
REM  HOW TO RUN: double-click this file, or from a Command Prompt
REM  cd into this folder and run:  reorganize-by-topic.bat
REM  Safe to re-run: files already in place are skipped.
REM ============================================================

set "BASE=%~dp0"
cd /d "%BASE%"
echo Working in: %BASE%
echo.

REM --- 1. Create topic folders ---
for %%T in (background-and-policy crop-insurance-demand crop-insurance-rating prevented-planting premium-and-interest-deferrals yield-modeling index-insurance impacts-of-crop-insurance safety-net-simulation climate-and-environment) do (
  if not exist "%BASE%%%T" md "%BASE%%%T"
)

set /a MOVED=0
set /a MISSING=0

REM --- 2. Move files (source type-folder  ->  topic folder) ---

REM Peer-reviewed
call :mv "peer-reviewed" "crop-insurance-rating"      "2022 Tsiboe & Tack - Utilizing Topographic and Soil Features to Improve Rating for Farm-level Insurance.pdf"
call :mv "peer-reviewed" "crop-insurance-demand"      "2022 Turner & Tsiboe - The Crop Insurance Demand Response to the Wildfire and Hurricane Indemnity.pdf"
call :mv "peer-reviewed" "crop-insurance-demand"      "2023 Tsiboe - Econometric Identification of Crop Insurance Participation.pdf"
call :mv "peer-reviewed" "index-insurance"            "2023 Tsiboe - Farm-level Evaluation of Area- and Agroclimatic-based Index Insurance.pdf"
call :mv "peer-reviewed" "crop-insurance-demand"      "2023 Tsiboe - The Crop Insurance Demand Response to Premium Subsidies (US).pdf"
call :mv "peer-reviewed" "yield-modeling"             "2024 Tsiboe - Utilizing Large-scale Insurance Data Sets to Calibrate Sub-county Level Crop Yields.pdf"
call :mv "peer-reviewed" "safety-net-simulation"      "2025 Gaku - Evaluation of Alternative Farm Safety Net Program Combination Strategies.pdf"
call :mv "peer-reviewed" "safety-net-simulation"      "2025 Tsiboe - Incorporating Buy-up Price Loss Coverage into the United States Farm Safety Net.pdf"
call :mv "peer-reviewed" "safety-net-simulation"      "2025 Tsiboe - Risk Reduction Impacts of Crop Insurance in the United States.pdf"
call :mv "peer-reviewed" "impacts-of-crop-insurance"  "2025 Turner - Crop Insurance Participation and Cover Crop Use.pdf"
call :mv "peer-reviewed" "crop-insurance-rating"      "2026 Tsiboe - Routine Actuarial Adjustments Cut Taxpayer Cost in Subsidized Agricultural Insurance.pdf"

REM USDA-ERS
call :mv "usda-ers" "background-and-policy" "2023 Baldwin - US Agricultural Policy Review 2021 (EIB-254).pdf"
call :mv "usda-ers" "background-and-policy" "2023 Baldwin - US Agricultural Policy Review 2022 (EIB-260).pdf"
call :mv "usda-ers" "background-and-policy" "2023 Turner - Federal Programs for Agricultural Risk Management (EIB-259).pdf"
call :mv "usda-ers" "background-and-policy" "2024 Baldwin - Recent Developments in Ad Hoc Assistance Programs for Agricultural Producers (EIB-278).pdf"

REM ARPC Briefs
call :mv "arpc-briefs" "impacts-of-crop-insurance"      "ARPC Brief 2025-01 - Crop Insurance Generally Improves Farm Revenues but Effects Vary by Policy Type.pdf"
call :mv "arpc-briefs" "premium-and-interest-deferrals" "ARPC Brief 2025-09 - Crop Insurance Premium and Interest Deferrals in a Time of Rising Farm Costs.pdf"
call :mv "arpc-briefs" "background-and-policy"           "ARPC Brief 2025-11 - Rising Costs, Falling Prices - Regional Disparities Deepen Farm Financial Stress.pdf"
call :mv "arpc-briefs" "premium-and-interest-deferrals" "ARPC Brief 2025-12 - What Repeated Crop Insurance Premium Interest Deferrals Mean for Farmers.pdf"
call :mv "arpc-briefs" "background-and-policy"           "ARPC Brief 2025-13 - Evolution of US Federal Crop-Insurance Plans.pdf"
call :mv "arpc-briefs" "yield-modeling"                 "ARPC Brief 2025-14 - A Horse Race Comparison of County-Level Crop Yield Prediction Methods.pdf"
call :mv "arpc-briefs" "crop-insurance-demand"          "ARPC Brief 2025-16 - Pasture, Rangeland, and Forage (PRF) Insurance Expansion and Emerging Limits to Growth.pdf"
call :mv "arpc-briefs" "prevented-planting"             "ARPC Brief 2025-18 - Prevented Planting Buy-Up Coverage - Payments and Policy Changes.pdf"
call :mv "arpc-briefs" "prevented-planting"             "ARPC Brief 2026-01 - The Actuarial Performance of Prevented Planting Buy-Up Coverage.pdf"
call :mv "arpc-briefs" "prevented-planting"             "ARPC Brief 2026-02 - Ending Prevented Planting Buy-Ups Changes Insurance Choices and Expands Program Risk.pdf"
call :mv "arpc-briefs" "prevented-planting"             "ARPC Brief 2026-03 - What Ending Prevented Planting Buy-Ups Means for Farmers' Insurance Costs.pdf"
call :mv "arpc-briefs" "crop-insurance-rating"          "ARPC Brief 2026-06 - Routine Pricing Adjustments Help Keep Crop Insurance Costs in Check.pdf"
call :mv "arpc-briefs" "yield-modeling"                 "ARPC Brief 2026-07 - Are Crop Yields Becoming More Stable and Higher Evidence from US County-Level Data Since 1980.pdf"
call :mv "arpc-briefs" "crop-insurance-demand"          "ARPC Brief 2026-08 - Continued Pasture, Rangeland, and Forage (PRF) Insurance Expansion in 2026.pdf"
call :mv "arpc-briefs" "crop-insurance-demand"          "ARPC Brief 2026-12 - Early Signals for Supplemental Crop Insurance Adoption Under Partial OBBBA Implementation.pdf"

REM ARPC Report
call :mv "arpc-reports" "background-and-policy" "ARPC Report 2026-01 - Size and Growth of the United States Crop Insurance Portfolio, 2025.pdf"

REM ARPC White Papers
call :mv "arpc-white-papers" "premium-and-interest-deferrals" "ARPC White Paper 2025-04 - When Disaster Strikes the Billing Date - A Scoping Review of Crop Insurance Interest Deferrals.pdf"
call :mv "arpc-white-papers" "prevented-planting"             "ARPC White Paper 2026-01 - Prevented Planting After Buy-Up Elimination - Coverage Level Substitution, Producer Costs, and Enhanced Premium Subsidies (OBBB).pdf"
call :mv "arpc-white-papers" "prevented-planting"             "ARPC White Paper 2026-02 - Prevented Planting Buy-Up Elimination - Adoption, Actuarial Performance, and Pre-Planting Risk Management Options.pdf"
call :mv "arpc-white-papers" "climate-and-environment"        "ARPC White Paper 2026-08 - Crop Insurance and Nitrogen Reduction Under Elevated Fertilizer Prices.pdf"

REM ARPC Working Paper
call :mv "arpc-working-papers" "impacts-of-crop-insurance" "ARPC Working Paper 2026-03 - Agricultural Insurance Association with Farm Technology and Technical Efficiency.pdf"

REM --- 3. Remove now-empty output-type folders (keeps conference-papers) ---
for %%D in (peer-reviewed usda-ers arpc-briefs arpc-reports arpc-white-papers arpc-working-papers _incoming) do (
  if exist "%BASE%%%D" rd "%BASE%%%D" 2>nul
)

echo.
echo Done. Moved: !MOVED!   Not found: !MISSING!
echo Tip: re-knit README.Rmd to refresh the topic index.
echo.
pause
goto :eof

REM ============================================================
REM  :mv  <source-subfolder>  <dest-topic>  <filename>
REM ============================================================
:mv
set "SRC=%BASE%%~1\%~3"
set "DST=%BASE%%~2\%~3"
if exist "%DST%" goto :eof
if exist "%SRC%" (
  move "%SRC%" "%BASE%%~2\" >nul
  echo   moved -^> %~2\%~3
  set /a MOVED+=1
) else (
  echo   MISSING: %~1\%~3
  set /a MISSING+=1
)
goto :eof
