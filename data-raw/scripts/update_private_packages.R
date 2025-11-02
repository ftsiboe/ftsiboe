


for(i in c("arpcFCIP","rfcipCalcPass","rfcipCalibrate","rAgroClimate ","rkfmaData",
           "rfcipCalibrateExtended","rfcipReSim","arpcPriceBasis","arpcCost","rfcipPRF")){
  file.copy(from=file.path(gsub("ftsiboe",i,getwd()),"README.md"),
            to = file.path("./data-raw/private_packages/",paste0(i,".md")),
            overwrite = TRUE, recursive = FALSE, copy.mode = TRUE)
}





