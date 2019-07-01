#!/usr/bin/Rscript

args<-commandArgs(TRUE)

if(require("bitops")){
    print("Package bitops loading successed...")
} else {
    print("Package bitops has not been installed, trying installing...")
    install.packages("bitops")
    if(require("bitops")){
        print("Package bitops installing succssed!")
    } else {
        stop("Package bitops installation fialed!")
    }
}

if(require("RCurl")){
    print("Package RCurl loading successed...")
} else {
    print("Package RCurl has not been installed, trying installing...")
    install.packages("RCurl")
    if(require("RCurl")){
        print("Package RCurl installing succssed!")
    } else {
        stop("Package RCurl installation fialed!")
    }
}

if(require("XML")){
    print("Package XML loading successed...")
} else {
    print("Package XML has not been installed, trying installing...")
    install.packages("XML")
    if(require("XML")){
        print("Package XML installing succssed!")
    } else {
        stop("Package XML installation fialed!")
    }
}

organism<-args[1]
out<-args[2]

temp<-getURL(url=paste("https://www.kegg.jp/kegg-bin/show_organism?menu_type=pathway_maps&org=",organism,sep=""))
sink(out)
temp
sink()
cat("Organism kegg map grabbing succssed!")
