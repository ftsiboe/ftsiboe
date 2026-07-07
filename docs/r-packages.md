---
layout: single
title: "Software and Tools"
permalink: /r-packages/
author_profile: true
---


<!-- Source for docs/r-packages.md (GitHub Pages). Build with data-raw/scripts/render.R -->

Open-source and in-development R packages I maintain for U.S.
agricultural risk and policy analysis.

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

<input id="pkg-search" type="search" placeholder="Search packages&hellip;" aria-label="Search packages">
<select id="pkg-group" aria-label="Filter by group">
<option value="">All groups</option>
<option value="Public">Public</option>
<option value="Private">Private</option>
<option value="ARPC">ARPC</option> </select>
<select id="pkg-sort" aria-label="Sort packages">
<option value="featured">Sort: Featured</option>
<option value="group">Group: Public, Private, ARPC</option>
<option value="name-asc">Name (A–Z)</option>
<option value="name-desc">Name (Z–A)</option> </select>

</div>

<p id="pkg-count" class="data-count">

</p>

<div id="pkg-grid" class="data-grid">

<a class="data-card" data-name="USFarmSafetyNetLab" data-group="Public" href="https://github.com/ftsiboe/USFarmSafetyNetLab">
<i class="fa-solid fa-shield-halved" aria-hidden="true"></i>

<div class="t">

USFarmSafetyNetLab

</div>

<div class="d">

Analytical tools and resources dedicated to United States agricultural
safety net programs.

</div>

<div class="meta">

Public · Open source

</div>

</a>

<a class="data-card" data-name="rfcipDemand" data-group="Public" href="https://github.com/ftsiboe/rfcipDemand">
<i class="fa-solid fa-chart-line" aria-hidden="true"></i>

<div class="t">

rfcipDemand

</div>

<div class="d">

Tools to estimate Federal Crop Insurance Program (FCIP) demand.

</div>

<div class="meta">

Public · Open source

</div>

</a>

<a class="data-card" data-name="rexcelbridge" data-group="Public" href="https://github.com/ftsiboe/rexcelbridge">
<i class="fa-solid fa-file-excel" aria-hidden="true"></i>

<div class="t">

rexcelbridge

</div>

<div class="d">

Vendor-neutral helpers to evaluate Excel formulas from R via COM
automation.

</div>

<div class="meta">

Public · Open source

</div>

</a>

<a class="data-card" data-name="okwaayeli" data-group="Public" href="https://github.com/ftsiboe/okwaayeli">
<i class="fa-solid fa-tractor" aria-hidden="true"></i>

<div class="t">

okwaayeli

</div>

<div class="d">

Agricultural productivity analysis in Ghana — farmer technical
inefficiency and technology gaps using harmonized Ghana Living Standards
Survey (GLSS) data.

</div>

<div class="meta">

Public · Open source

</div>

</a>

<a class="data-card" data-name="rfcipCalcPass" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rfcipCalcPass.md">
<i class="fa-solid fa-calculator" aria-hidden="true"></i>

<div class="t">

rfcipCalcPass

</div>

<div class="d">

R implementations of FCIP premium and indemnity calculators.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rfcipCalibrate" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rfcipCalibrate.md">
<i class="fa-solid fa-sliders" aria-hidden="true"></i>

<div class="t">

rfcipCalibrate

</div>

<div class="d">

R tools for calibrating yield and preference models for farm-level FCIP
experience.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rfcipCalibrateExtended" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rfcipCalibrateExtended.md">
<i class="fa-solid fa-layer-group" aria-hidden="true"></i>

<div class="t">

rfcipCalibrateExtended

</div>

<div class="d">

Extended tools for rfcipCalibrate.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rfcipReSim" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rfcipReSim.md">
<i class="fa-solid fa-arrows-rotate" aria-hidden="true"></i>

<div class="t">

rfcipReSim

</div>

<div class="d">

R modular simulator for FCIP reinsurance outcomes.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rfcipPRF" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rfcipPRF.md">
<i class="fa-solid fa-cloud-rain" aria-hidden="true"></i>

<div class="t">

rfcipPRF

</div>

<div class="d">

Tools for RMA Pasture, Rangeland, and Forage (PRF) insurance data and
policy analysis.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rkfmaData" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rkfmaData.md">
<i class="fa-solid fa-database" aria-hidden="true"></i>

<div class="t">

rkfmaData

</div>

<div class="d">

Tools for the Kansas Farm Management Data Bank.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="rAgroClimate" data-group="Private" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/rAgroClimate.md">
<i class="fa-solid fa-temperature-half" aria-hidden="true"></i>

<div class="t">

rAgroClimate

</div>

<div class="d">

Agroclimatic and environmental datasets for agricultural research.

</div>

<div class="meta">

Private

</div>

</a>

<a class="data-card" data-name="arpcPriceBasis" data-group="ARPC" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/arpcPriceBasis.md">
<i class="fa-solid fa-tags" aria-hidden="true"></i>

<div class="t">

arpcPriceBasis

</div>

<div class="d">

R tools for price and basis by commodity and county/elevator.

</div>

<div class="meta">

ARPC · Private

</div>

</a>

<a class="data-card" data-name="arpcCost" data-group="ARPC" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/arpcCost.md">
<i class="fa-solid fa-money-bill-wave" aria-hidden="true"></i>

<div class="t">

arpcCost

</div>

<div class="d">

R tools to calibrate and harmonize agricultural production costs by
commodity and county.

</div>

<div class="meta">

ARPC · Private

</div>

</a>

<a class="data-card" data-name="arpcFCIP" data-group="ARPC" href="https://github.com/ftsiboe/ftsiboe/tree/main/data-raw/private-packages/arpcFCIP.md">
<i class="fa-solid fa-flask" aria-hidden="true"></i>

<div class="t">

arpcFCIP

</div>

<div class="d">

Simulate and benchmark Federal Crop Insurance Program (FCIP) outcomes.

</div>

<div class="meta">

ARPC · Private

</div>

</a>

</div>

<p id="pkg-empty" class="data-empty" hidden>

No packages match your search.
</p>

<script>
(function(){
  var grid=document.getElementById('pkg-grid');
  if(!grid){return;}
  var GRANK={Public:0,Private:1,ARPC:2};
  var cards=Array.prototype.slice.call(grid.querySelectorAll('.data-card'));
  cards.forEach(function(c,i){c.dataset.order=i;});
  var search=document.getElementById('pkg-search');
  var group=document.getElementById('pkg-group');
  var sort=document.getElementById('pkg-sort');
  var count=document.getElementById('pkg-count');
  var empty=document.getElementById('pkg-empty');
  function apply(){
    var q=(search.value||'').toLowerCase().trim();
    var grp=group.value;
    var visible=cards.filter(function(c){
      var okQ=!q||c.textContent.toLowerCase().indexOf(q)>-1;
      var okG=!grp||c.dataset.group===grp;
      c.style.display=(okQ&&okG)?'':'none';
      return okQ&&okG;
    });
    var s=sort.value;
    visible.sort(function(a,b){
      if(s==='name-asc'){return a.dataset.name.localeCompare(b.dataset.name);}
      if(s==='name-desc'){return b.dataset.name.localeCompare(a.dataset.name);}
      if(s==='group'){
        var d=GRANK[a.dataset.group]-GRANK[b.dataset.group];
        return d!==0?d:(a.dataset.order-b.dataset.order);
      }
      return a.dataset.order-b.dataset.order;
    });
    visible.forEach(function(c){grid.appendChild(c);});
    count.textContent=visible.length+' of '+cards.length+' packages';
    empty.hidden=visible.length>0;
  }
  search.addEventListener('input',apply);
  group.addEventListener('change',apply);
  sort.addEventListener('change',apply);
  apply();
})();
</script>

------------------------------------------------------------------------

[Home](https://ftsiboe.github.io/) ·
[Publications](https://ftsiboe.github.io/risk-management/) · [Working
Papers](https://ftsiboe.github.io/working-papers/) · [Replication
Packages](https://ftsiboe.github.io/replication-packages/) · [Research
Metrics](https://ftsiboe.github.io/metrics/)
