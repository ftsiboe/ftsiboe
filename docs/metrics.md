---
layout: single
title: "Research Metrics"
permalink: /metrics/
author_profile: true
---


<!-- Source for docs/metrics.md (GitHub Pages).
     The numbers are shown via dynamic shields.io badges that read
     data-raw/scholar-metrics.json at view time, so they stay current as long
     as the .github "Update Scholar Metrics" workflow keeps that JSON fresh,
     no site re-render needed when the metrics change. -->

Citation metrics from my [Google Scholar
profile](https://scholar.google.com/citations?user=ox2t_YIAAAAJ&hl=en).

![Citations](https://img.shields.io/badge/dynamic/json?label=Citations&query=$.citations&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=4285F4&style=for-the-badge)
![h-index](https://img.shields.io/badge/dynamic/json?label=h-index&query=$.h_index&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=brightgreen&style=for-the-badge)
![i10-index](https://img.shields.io/badge/dynamic/json?label=i10--index&query=$.i10_index&url=https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json&color=informational&style=for-the-badge)

## Citations per year

<style>
.cpy-chart{display:flex;align-items:flex-end;gap:4px;height:190px;border-bottom:1px solid var(--global-border-color);margin-top:1rem;}
.cpy-col{flex:1 1 0;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;}
.cpy-val{font-size:0.7rem;color:var(--global-text-color-light);margin-bottom:3px;}
.cpy-bar{width:72%;background:var(--global-link-color);border-radius:3px 3px 0 0;min-height:2px;}
.cpy-yrs{display:flex;gap:4px;margin:4px 0 0.5rem;}
.cpy-yr{flex:1 1 0;text-align:center;font-size:0.7rem;color:var(--global-text-color-light);}
.cpy-note{font-size:0.85rem;color:var(--global-text-color-light);}
</style>

<div id="cpy">

<p class="cpy-note">

Loading citations per year…
</p>

</div>

<script>
(function(){
  var url="https://raw.githubusercontent.com/ftsiboe/ftsiboe/main/data-raw/scholar-metrics.json";
  var el=document.getElementById("cpy");
  if(!el){return;}
  fetch(url,{cache:"no-store"}).then(function(r){return r.json();}).then(function(d){
    var data=d&&d.cites_per_year;
    if(!data||!Object.keys(data).length){
      el.innerHTML='<p class="cpy-note">The per-year chart will appear after the next Scholar metrics refresh.</p>';
      return;
    }
    var years=Object.keys(data).sort();
    var vals=years.map(function(y){return (+data[y])||0;});
    var max=Math.max.apply(null,vals)||1;
    var bars=years.map(function(y,i){
      var h=Math.max(2,Math.round(vals[i]/max*160));
      return '<div class="cpy-col"><div class="cpy-val">'+vals[i]+'</div>'+
             '<div class="cpy-bar" style="height:'+h+'px" title="'+y+': '+vals[i]+' citations"></div></div>';
    }).join("");
    var yrs=years.map(function(y){return '<div class="cpy-yr">'+y+'</div>';}).join("");
    el.innerHTML='<div class="cpy-chart">'+bars+'</div><div class="cpy-yrs">'+yrs+'</div>';
  }).catch(function(){
    el.innerHTML='<p class="cpy-note">Could not load citations per year right now.</p>';
  });
})();
</script>

## GitHub activity and achievements 🏅

[![Pull
Shark](https://img.shields.io/badge/GitHub-Pull_Shark-181717?logo=github&logoColor=white)](https://github.com/users/ftsiboe/achievements/pull-shark)
[![Pair
Extraordinaire](https://img.shields.io/badge/GitHub-Pair_Extraordinaire-181717?logo=github&logoColor=white)](https://github.com/users/ftsiboe/achievements/pair-extraordinaire)
[![YOLO](https://img.shields.io/badge/GitHub-YOLO-181717?logo=github&logoColor=white)](https://github.com/users/ftsiboe/achievements/yolo)

My public contributions over the last year (updates daily):

[![Francis Tsiboe’s GitHub contribution grid for the last
year](https://ghchart.rshah.org/ftsiboe)](https://github.com/ftsiboe)

## Honors & awards

- **2025.** JAAE Outstanding Journal Article of the Year, for
  “Mitigating Structural Inequities in U.S. Agricultural Risk
  Management” (*Journal of Agricultural and Applied Economics*).
- **2022.** Best Paper in Applied Risk Analysis, Agricultural & Applied
  Economics Association (AAEA), for my *American Journal of Agricultural
  Economics* paper incorporating soil and topographic data into
  crop-insurance rating.
- **2022.** Outstanding Published Research, Western Agricultural
  Economics Association (WAEA), for the same paper. —

[Home](https://ftsiboe.github.io/) ·
[Publications](https://ftsiboe.github.io/risk-management/) · [Working
Papers](https://ftsiboe.github.io/working-papers/) ·
[Software](https://ftsiboe.github.io/r-packages/) · [Replication
Packages](https://ftsiboe.github.io/replication-packages/)
