<#
  reorganize-by-topic.ps1
  Reorganizes the risk-management publications from output-type folders
  into broad topic-area folders.

  HOW TO RUN:
    1. Make sure the PDFs are downloaded locally (in Dropbox, right-click the
       risk-management folder -> "Make available offline") — or just run this;
       PowerShell will materialize them as it moves.
    2. Right-click this file -> "Run with PowerShell"
       (or in a PowerShell window:  cd to this folder, then  .\reorganize-by-topic.ps1)

  It is safe to re-run: already-moved files are simply skipped.
#>

$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
if (-not $base) { $base = (Get-Location).Path }
Write-Host "Working in: $base`n"

# --- 1. Topic folders to create ---
$topics = @(
  'background-and-policy','crop-insurance-demand','crop-insurance-rating',
  'prevented-planting','premium-and-interest-deferrals','yield-modeling',
  'index-insurance','impacts-of-crop-insurance','safety-net-simulation',
  'climate-and-environment'
)
foreach ($t in $topics) {
  $p = Join-Path $base $t
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

# --- 2. filename -> destination topic ---
$map = [ordered]@{
  '2022 Tsiboe & Tack - Utilizing Topographic and Soil Features to Improve Rating for Farm-level Insurance.pdf' = 'crop-insurance-rating'
  '2022 Turner & Tsiboe - The Crop Insurance Demand Response to the Wildfire and Hurricane Indemnity.pdf'        = 'crop-insurance-demand'
  '2023 Tsiboe - Econometric Identification of Crop Insurance Participation.pdf'                                 = 'crop-insurance-demand'
  '2023 Tsiboe - Farm-level Evaluation of Area- and Agroclimatic-based Index Insurance.pdf'                      = 'index-insurance'
  '2023 Tsiboe - The Crop Insurance Demand Response to Premium Subsidies (US).pdf'                               = 'crop-insurance-demand'
  '2024 Tsiboe - Utilizing Large-scale Insurance Data Sets to Calibrate Sub-county Level Crop Yields.pdf'        = 'yield-modeling'
  '2025 Gaku - Evaluation of Alternative Farm Safety Net Program Combination Strategies.pdf'                     = 'safety-net-simulation'
  '2025 Tsiboe - Incorporating Buy-up Price Loss Coverage into the United States Farm Safety Net.pdf'            = 'safety-net-simulation'
  '2025 Tsiboe - Risk Reduction Impacts of Crop Insurance in the United States.pdf'                              = 'safety-net-simulation'
  '2025 Turner - Crop Insurance Participation and Cover Crop Use.pdf'                                            = 'impacts-of-crop-insurance'
  '2026 Tsiboe - Routine Actuarial Adjustments Cut Taxpayer Cost in Subsidized Agricultural Insurance.pdf'       = 'crop-insurance-rating'

  '2023 Baldwin - US Agricultural Policy Review 2021 (EIB-254).pdf'                                              = 'background-and-policy'
  '2023 Baldwin - US Agricultural Policy Review 2022 (EIB-260).pdf'                                              = 'background-and-policy'
  '2023 Turner - Federal Programs for Agricultural Risk Management (EIB-259).pdf'                                = 'background-and-policy'
  '2024 Baldwin - Recent Developments in Ad Hoc Assistance Programs for Agricultural Producers (EIB-278).pdf'    = 'background-and-policy'

  'ARPC Brief 2025-01 - Crop Insurance Generally Improves Farm Revenues but Effects Vary by Policy Type.pdf'     = 'impacts-of-crop-insurance'
  'ARPC Brief 2025-09 - Crop Insurance Premium and Interest Deferrals in a Time of Rising Farm Costs.pdf'        = 'premium-and-interest-deferrals'
  'ARPC Brief 2025-11 - Rising Costs, Falling Prices - Regional Disparities Deepen Farm Financial Stress.pdf'    = 'background-and-policy'
  'ARPC Brief 2025-12 - What Repeated Crop Insurance Premium Interest Deferrals Mean for Farmers.pdf'            = 'premium-and-interest-deferrals'
  'ARPC Brief 2025-13 - Evolution of US Federal Crop-Insurance Plans.pdf'                                        = 'background-and-policy'
  'ARPC Brief 2025-14 - A Horse Race Comparison of County-Level Crop Yield Prediction Methods.pdf'               = 'yield-modeling'
  'ARPC Brief 2025-16 - Pasture, Rangeland, and Forage (PRF) Insurance Expansion and Emerging Limits to Growth.pdf' = 'crop-insurance-demand'
  'ARPC Brief 2025-18 - Prevented Planting Buy-Up Coverage - Payments and Policy Changes.pdf'                    = 'prevented-planting'
  'ARPC Brief 2026-01 - The Actuarial Performance of Prevented Planting Buy-Up Coverage.pdf'                     = 'prevented-planting'
  'ARPC Brief 2026-02 - Ending Prevented Planting Buy-Ups Changes Insurance Choices and Expands Program Risk.pdf' = 'prevented-planting'
  "ARPC Brief 2026-03 - What Ending Prevented Planting Buy-Ups Means for Farmers' Insurance Costs.pdf"           = 'prevented-planting'
  'ARPC Brief 2026-06 - Routine Pricing Adjustments Help Keep Crop Insurance Costs in Check.pdf'                 = 'crop-insurance-rating'
  'ARPC Brief 2026-07 - Are Crop Yields Becoming More Stable and Higher Evidence from US County-Level Data Since 1980.pdf' = 'yield-modeling'
  'ARPC Brief 2026-08 - Continued Pasture, Rangeland, and Forage (PRF) Insurance Expansion in 2026.pdf'          = 'crop-insurance-demand'
  'ARPC Brief 2026-12 - Early Signals for Supplemental Crop Insurance Adoption Under Partial OBBBA Implementation.pdf' = 'crop-insurance-demand'

  'ARPC Report 2026-01 - Size and Growth of the United States Crop Insurance Portfolio, 2025.pdf'                = 'background-and-policy'

  'ARPC White Paper 2025-04 - When Disaster Strikes the Billing Date - A Scoping Review of Crop Insurance Interest Deferrals.pdf' = 'premium-and-interest-deferrals'
  'ARPC White Paper 2026-01 - Prevented Planting After Buy-Up Elimination - Coverage Level Substitution, Producer Costs, and Enhanced Premium Subsidies (OBBB).pdf' = 'prevented-planting'
  'ARPC White Paper 2026-02 - Prevented Planting Buy-Up Elimination - Adoption, Actuarial Performance, and Pre-Planting Risk Management Options.pdf' = 'prevented-planting'
  'ARPC White Paper 2026-08 - Crop Insurance and Nitrogen Reduction Under Elevated Fertilizer Prices.pdf'        = 'climate-and-environment'

  'ARPC Working Paper 2026-03 - Agricultural Insurance Association with Farm Technology and Technical Efficiency.pdf' = 'impacts-of-crop-insurance'
}

# --- 3. Move files ---
$moved = 0; $already = 0; $missing = @()
foreach ($name in $map.Keys) {
  $destDir  = Join-Path $base $map[$name]
  $destPath = Join-Path $destDir $name
  if (Test-Path -LiteralPath $destPath) { $already++; continue }

  $src = Get-ChildItem -Path $base -Recurse -File -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -eq $name } | Select-Object -First 1
  if ($src) {
    Move-Item -LiteralPath $src.FullName -Destination $destPath -Force
    Write-Host ("  moved -> {0}\{1}" -f $map[$name], $name)
    $moved++
  } else {
    $missing += $name
  }
}

# --- 4. Remove now-empty output-type folders (keeps conference-papers) ---
foreach ($old in 'peer-reviewed','usda-ers','arpc-briefs','arpc-reports','arpc-white-papers','arpc-working-papers','_incoming') {
  $op = Join-Path $base $old
  if (Test-Path $op) {
    $remaining = Get-ChildItem -Path $op -Recurse -File -ErrorAction SilentlyContinue
    if (-not $remaining) { Remove-Item -LiteralPath $op -Recurse -Force }
  }
}

# --- 5. Summary ---
Write-Host ""
Write-Host "Done. Moved: $moved | Already in place: $already | Not found: $($missing.Count)"
if ($missing.Count) {
  Write-Host "`nNot found (check these names):" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host "  $_" }
}
Write-Host "`nTip: re-knit README.Rmd to refresh the topic index."
