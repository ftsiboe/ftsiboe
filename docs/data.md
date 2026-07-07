---
layout: single
title: "Data"
permalink: /data/
author_profile: true
---


<!-- Source for docs/data.md (GitHub Pages). Build with data-raw/scripts/render.R -->

Research-ready data products for U.S. agricultural risk and policy
analysis, spanning USDA sources and my own calibrated and synthetic
datasets. Each card links to a public GitHub release that documents the
included files, methodology, and recommended citation; most files are
`.rds` objects downloadable directly in R with `piggyback`.

<style>
.data-controls{display:flex;flex-wrap:wrap;gap:0.6rem;align-items:center;margin:1.25rem 0 0.25rem;}
.data-controls input,.data-controls select{font:inherit;padding:0.45rem 0.6rem;border:1px solid var(--global-border-color);border-radius:8px;background:transparent;color:var(--global-text-color);}
.data-controls input{flex:1 1 220px;min-width:180px;}
.data-count{font-size:0.8rem;color:var(--global-text-color-light);margin:0.35rem 0 0;}
.data-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:0.9rem;margin:0.75rem 0 1.25rem;}
.data-card{display:block;text-decoration:none;border:1px solid var(--global-border-color);border-radius:10px;padding:1rem 1.1rem;color:var(--global-text-color);transition:border-color .15s ease,transform .15s ease;}
.data-card:hover{border-color:var(--global-link-color);transform:translateY(-2px);}
.data-card i{font-size:1.3rem;color:var(--global-link-color);}
.data-card .t{font-weight:700;margin-top:0.45rem;}
.data-card .d{font-size:0.85rem;color:var(--global-text-color-light);margin-top:0.25rem;line-height:1.5;}
.data-card .meta{font-size:0.72rem;color:var(--global-text-color-light);margin-top:0.6rem;text-transform:uppercase;letter-spacing:0.03em;}
.data-empty{color:var(--global-text-color-light);font-style:italic;margin:0.5rem 0 1.25rem;}
</style>

<div class="data-controls">

<input id="data-search" type="search" placeholder="Search datasets&hellip;" aria-label="Search datasets">
<select id="data-source" aria-label="Filter by source">
<option value="">All sources</option> <option value="RMA">USDA
RMA</option> <option value="NASS">USDA NASS</option>
<option value="FSA">USDA FSA</option>
<option value="PRISM">PRISM</option> <option value="GLSS">Ghana
GLSS</option> </select>
<select id="data-sort" aria-label="Sort datasets">
<option value="featured">Sort: Featured</option>
<option value="name-asc">Name (A–Z)</option>
<option value="name-desc">Name (Z–A)</option>
<option value="date-desc">Newest updated</option>
<option value="date-asc">Oldest updated</option> </select>

</div>

<p id="data-count" class="data-count">

</p>

<div id="data-grid" class="data-grid">

<a class="data-card" data-name="Pasture, Rangeland, Forage (PRF)" data-source="RMA" data-date="2026-03-27" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/prf">
<i class="fa-solid fa-cloud-rain" aria-hidden="true"></i>

<div class="t">

Pasture, Rangeland, Forage (PRF)

</div>

<div class="d">

Analysis-ready PRF Pilot Insurance data: county- and grid-level
actuarial files, RMA rainfall index values, CPC precipitation, and
derived potential-area and county penetration measures.

</div>

<div class="meta">

USDA RMA · Updated Mar 2026

</div>

</a>

<a class="data-card" data-name="PRISM Weather Data" data-source="PRISM" data-date="2026-01-05" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/prism">
<i class="fa-solid fa-temperature-half" aria-hidden="true"></i>

<div class="t">

PRISM Weather Data

</div>

<div class="d">

County-level daily degree days and precipitation from the PRISM gridded
dataset, aggregated over crop growing seasons following the Schlenker &
Roberts (2009) and Tack et al. (2015) procedures.

</div>

<div class="meta">

PRISM · Updated Jan 2026

</div>

</a>

<a class="data-card" data-name="Summary of Business" data-source="RMA" data-date="2026-03-02" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/sob">
<i class="fa-solid fa-table-list" aria-hidden="true"></i>

<div class="t">

Summary of Business

</div>

<div class="d">

FCIP participation and loss experience aggregated at three levels:
contract choice × pool (sobtpu), coverage level × county × commodity
(sobcov), and county × commodity (sobscc).

</div>

<div class="meta">

USDA RMA · Updated Mar 2026

</div>

</a>

<a class="data-card" data-name="Cause of Loss" data-source="RMA" data-date="2026-03-02" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/col">
<i class="fa-solid fa-triangle-exclamation" aria-hidden="true"></i>

<div class="t">

Cause of Loss

</div>

<div class="d">

FCIP participation, liability, and indemnities broken out by peril,
letting losses be attributed to specific causes of loss.

</div>

<div class="meta">

USDA RMA · Updated Mar 2026

</div>

</a>

<a class="data-card" data-name="FCIP Calibrated Yield" data-source="RMA" data-date="2026-07-05" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/calibrated_yield">
<i class="fa-solid fa-seedling" aria-hidden="true"></i>

<div class="t">

FCIP Calibrated Yield

</div>

<div class="d">

Calibrated sub-county yields for every observed FCIP aggregated
transaction (Tsiboe, Turner & Yu 2025, <em>Journal of Risk and
Insurance</em> 92(1):139–165).

</div>

<div class="meta">

USDA RMA (derived) · Updated Jul 2026

</div>

</a>

<a class="data-card" data-name="FCIP Calibration Data" data-source="RMA" data-date="2026-07-05" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/calibration_data">
<i class="fa-solid fa-sliders" aria-hidden="true"></i>

<div class="t">

FCIP Calibration Data

</div>

<div class="d">

Standardized FCIP transaction records: Summary of Business experience
joined to ADM rating parameters, converted to yield-equivalent terms
with inverted rate yields. One file per crop year, 2011–present.

</div>

<div class="meta">

USDA RMA (derived) · Updated Jul 2026

</div>

</a>

<a class="data-card" data-name="Supplemental Insurance" data-source="RMA" data-date="2026-03-14" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/data_supplemental_insurance">
<i class="fa-solid fa-layer-group" aria-hidden="true"></i>

<div class="t">

Supplemental Insurance

</div>

<div class="d">

Availability and adoption of SCO/ECO supplemental products: cleaned
Summary of Business, annual ADM tables, agent-level datasets, an
offering-and-adoption panel, and OBBBA-recalibrated ADM.

</div>

<div class="meta">

USDA RMA (derived) · Updated Mar 2026

</div>

</a>

<a class="data-card" data-name="FCIP Revenue Draws" data-source="RMA" data-date="2026-07-05" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/revenue_draw">
<i class="fa-solid fa-dice" aria-hidden="true"></i>

<div class="t">

FCIP Revenue Draws

</div>

<div class="d">

500 correlated yield–price scenarios per producer under RMA’s M-13
framework, generated with common random numbers across all contract
alternatives.

</div>

<div class="meta">

USDA RMA (derived) · Updated Jul 2026

</div>

</a>

<a class="data-card" data-name="Synthetic FCIP Research Inputs" data-source="RMA" data-date="2026-07-06" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/synthetic_fcip">
<i class="fa-solid fa-flask" aria-hidden="true"></i>

<div class="t">

Synthetic FCIP Research Inputs

</div>

<div class="d">

Pseudo-producer panels built from unit-level experience, with loss
attribution across the full peril taxonomy, cell-level peril
probabilities, and RI-grid placement (apportioned and sampled).

</div>

<div class="meta">

USDA RMA (derived) · Updated Jul 2026

</div>

</a>

<a class="data-card" data-name="USDA NASS Extracts" data-source="NASS" data-date="2025-12-01" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/nass_extracts">
<i class="fa-solid fa-chart-column" aria-hidden="true"></i>

<div class="t">

USDA NASS Extracts

</div>

<div class="d">

Assorted county- and state-level series aggregated from USDA National
Agricultural Statistics Service (NASS) data.

</div>

<div class="meta">

USDA NASS · Updated Dec 2025

</div>

</a>

<a class="data-card" data-name="Insurance Control Elements" data-source="RMA" data-date="2025-12-01" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/ice">
<i class="fa-solid fa-gears" aria-hidden="true"></i>

<div class="t">

Insurance Control Elements

</div>

<div class="d">

Assorted items aggregated from the FCIP’s Insurance Control Elements
(ICE).

</div>

<div class="meta">

USDA RMA · Updated Dec 2025

</div>

</a>

<a class="data-card" data-name="USDA FSA Extracts" data-source="FSA" data-date="2025-12-01" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/fsa_extracts">
<i class="fa-solid fa-building-columns" aria-hidden="true"></i>

<div class="t">

USDA FSA Extracts

</div>

<div class="d">

Assorted series aggregated from USDA Farm Service Agency (FSA) program
data.

</div>

<div class="meta">

USDA FSA · Updated Dec 2025

</div>

</a>

<a class="data-card" data-name="Actuarial Data Master - Legacy" data-source="RMA" data-date="2025-12-01" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/adm_legacy">
<i class="fa-solid fa-box-archive" aria-hidden="true"></i>

<div class="t">

Actuarial Data Master — Legacy

</div>

<div class="d">

The FCIP’s Actuarial Data Master (ADM) for 1996–2010, covering the
pre-modern rating years.

</div>

<div class="meta">

USDA RMA · Updated Dec 2025

</div>

</a>

<a class="data-card" data-name="Actuarial Data Master - Extracts" data-source="RMA" data-date="2025-12-01" href="https://github.com/ftsiboe/USFarmSafetyNetLab/releases/tag/adm_extracts">
<i class="fa-solid fa-database" aria-hidden="true"></i>

<div class="t">

Actuarial Data Master — Extracts

</div>

<div class="d">

Assorted rating and program parameters aggregated from the FCIP’s
Actuarial Data Master (ADM).

</div>

<div class="meta">

USDA RMA · Updated Dec 2025

</div>

</a>

<a class="data-card" data-name="Ghana GLSS Harmonized Household Data" data-source="GLSS" data-date="2026-04-05" href="https://github.com/ftsiboe/okwaayeli/releases/tag/hh_data">
<i class="fa-solid fa-globe-africa" aria-hidden="true"></i>

<div class="t">

Ghana GLSS Harmonized Household Data

</div>

<div class="d">

Harmonized farmer- and community-level datasets from all seven rounds of
the Ghana Living Standards Survey (GLSS1 1987/88 – GLSS7 2016/17),
supporting agricultural productivity research.

</div>

<div class="meta">

Ghana Statistical Service · Updated Apr 2026

</div>

</a>

</div>

<p id="data-empty" class="data-empty" hidden>

No datasets match your search.
</p>

<script>
(function(){
  var grid=document.getElementById('data-grid');
  if(!grid){return;}
  var cards=Array.prototype.slice.call(grid.querySelectorAll('.data-card'));
  cards.forEach(function(c,i){c.dataset.order=i;});
  var search=document.getElementById('data-search');
  var source=document.getElementById('data-source');
  var sort=document.getElementById('data-sort');
  var count=document.getElementById('data-count');
  var empty=document.getElementById('data-empty');
  function apply(){
    var q=(search.value||'').toLowerCase().trim();
    var src=source.value;
    var visible=cards.filter(function(c){
      var okQ=!q||c.textContent.toLowerCase().indexOf(q)>-1;
      var okS=!src||c.dataset.source===src;
      c.style.display=(okQ&&okS)?'':'none';
      return okQ&&okS;
    });
    var s=sort.value;
    visible.sort(function(a,b){
      if(s==='name-asc'){return a.dataset.name.localeCompare(b.dataset.name);}
      if(s==='name-desc'){return b.dataset.name.localeCompare(a.dataset.name);}
      if(s==='date-desc'){return b.dataset.date.localeCompare(a.dataset.date);}
      if(s==='date-asc'){return a.dataset.date.localeCompare(b.dataset.date);}
      return a.dataset.order-b.dataset.order;
    });
    visible.forEach(function(c){grid.appendChild(c);});
    count.textContent=visible.length+' of '+cards.length+' datasets';
    empty.hidden=visible.length>0;
  }
  search.addEventListener('input',apply);
  source.addEventListener('change',apply);
  sort.addEventListener('change',apply);
  apply();
})();
</script>
