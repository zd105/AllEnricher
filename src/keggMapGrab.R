#!/usr/bin/Rscript

args<-commandArgs(TRUE)
library(bitops)
library(RCurl)
library(XML)

organism<-args[1]
out<-args[2]

temp<-getURL(url=paste("https://www.kegg.jp/kegg-bin/show_organism?menu_type=pathway_maps&org=",organism,sep=""))
sink(out)
temp
sink()
cat("Organism kegg map grabbing succssed!")
