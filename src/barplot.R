#!/usr/bin/Rscript
#####
args <- commandArgs(T)
if(length(args) != 3){
   stop("barplot.R GO|KEGG|DO|Reactome result prefix")
}

# read data
plottype <- args[1]
rt <- read.table(args[2])

# color setting
col <- c("gold2", "deepskyblue2", "purple3")
names(col) <- c("biological_process","cellular_component","molecular_function")

col1 <- c(rgb(59/255,179/255,135/255,1),rgb(0/255,178/255,238/255,1),
         rgb(159/255,121/255,238/255,1),rgb(240/255,128/255,128/255,1),
         rgb(238/255,233/255,58/255,1),rgb(64/255,224/255,208/255,1))
names(col1) <- c("Genetic_Information_Processing","Human_Diseases","Metabolism","Cellular_Processes","Organismal_Systems","Environmental_Information_Processing")

dat <- as.matrix(rt[,c(3,5,7)])
if(nrow(dat)>20){
    system('echo -e "\\e[1;31m[Warnning] Too many terms/pathways enriched, only the top 20 will be ploted." $(tput sgr0)')
    pdf(file=paste(args[3],"top20.pdf",sep="."),width=10)
    dat <- dat[c(1:20),]
}else{
    pdf(file=paste(args[3],"pdf",sep="."),width=10)
}
num <- nrow(dat)

if(plottype=="GO"){
v8 <- unlist(strsplit(as.character(rt[,8]), ":"))
term <- v8[ seq(1, 2*num, 2) ]
 barcol <- col[term]
 lab <- v8[ seq(2,2*num, 2) ]
 genum <- paste(dat[,1], round(dat[,2],d=2), sep="/")
 xmax <- max( -log10(rev(dat[,3])) )
 ## par(fig=c(0,0.5,0,1)) # fig=c(x1,x2,y1,y2)
 par(mar=c(5,4,4,28))
 y=barplot(-log10(rev(dat[,3])),
    horiz=T,
    xlim=c(xmax,0),
    xlab="-log10(Q-value)",
    col=rev(barcol),
    border=NA,
    yaxt="n",
    main="GO (Gene# / Rich Factor)"
 )
 text(-log10(rev(dat[,3])), y, rev(genum), pos=2, adj=1, xpd=T, cex=1)
 text(0, y, rev(lab), adj=0, xpd=T, pos=4, cex=1, font=3)
 legend("bottomleft", col=col, legend=names(col), pch=15, cex=1, bty="n")
}

if(plottype=="DO"){
  ### DO
  #dat <- as.matrix(rt[,c(3,5,7)])
  num <- nrow(dat)
  barcol <- "green4"
  v8 <- unlist(as.character(rt[,8]))
  lab <- v8[ seq(1, 1*num, 1) ]
  genum <- paste(dat[,1], round(dat[,2],d=2), sep="/")
  xmax <- max( -log10(rev(dat[,3])) )
  #par(fig=c(0,0.5,0,1))   # fig=c(x1,x2,y1,y2)
  par(mar=c(5,4,4,28))
  y=barplot(-log10(rev(dat[,3])),
    horiz=T,
    xlim=c(xmax,0),
    xlab="-log10(Q-value)",
    col=barcol,
    yaxt="n",
    border=NA,
    main="Human Disease (Gene# / Rich Factor)"
 )
 text(-log10(rev(dat[,3])), y, rev(genum), pos=2, adj=1, xpd=T,cex=1)
 text(0, y, rev(lab), adj=0, xpd=T, pos=4, cex=1, font=3)
}

if(plottype=="Reactome"){
  ### Reactome
  #dat <- as.matrix(rt[,c(3,5,7)])
  num <- nrow(dat)
  barcol <- "red3"
  v8 <- unlist(as.character(rt[,8]))
  lab <- v8[ seq(1, 1*num, 1) ]
  genum <- paste(dat[,1], round(dat[,2],d=2), sep="/")
  xmax <- max( -log10(rev(dat[,3])) )
  #par(fig=c(0,0.5,0,1))   # fig=c(x1,x2,y1,y2)
  par(mar=c(5,4,4,28))
  y=barplot(-log10(rev(dat[,3])),
    horiz=T,
    xlim=c(xmax,0),
    xlab="-log10(Q-value)",
    col=barcol,
    yaxt="n",
    border=NA,
    main="Reactome pathway (Gene# / Rich Factor)"
 )
 text(-log10(rev(dat[,3])), y, rev(genum), pos=2, adj=1, xpd=T,cex=1)
 text(0, y, rev(lab), adj=0, xpd=T, pos=4, cex=1, font=3)
}

if(plottype=="KEGG"){
  ### KEGG
  #dat <- as.matrix(rt[,c(3,5,7)])
  num <- nrow(dat)
  #barcol <- "deepskyblue2"
  v8 <- unlist(strsplit(as.character(rt[,8]), "\\|"))
  term <- v8[ seq(1, 3*num, 3) ]
  barcol <- col1[term]
  lab <- v8[ seq(3, 3*num, 3) ]
  genum <- paste(dat[,1], round(dat[,2],d=2), sep="/")
  xmax <- max( -log10(rev(dat[,3])) )
  #par(fig=c(0,0.5,0,1))   # fig=c(x1,x2,y1,y2)
  par(mar=c(5,4,4,28))
  y=barplot(-log10(rev(dat[,3])),
    horiz=T,
    xlim=c(xmax,0),
    xlab="-log10(Q-value)",
    col=rev(barcol),
    yaxt="n",
    border=NA,
    main="KEGG Pathways (Gene# / Rich Factor)"
 )
 text(-log10(rev(dat[,3])), y, rev(genum), pos=2, adj=1, xpd=T,cex=1)
 text(0, y, rev(lab), adj=0, xpd=T, pos=4, cex=1, font=3)
 legend("bottomleft", col=col1, legend=names(col1), pch=15, cex=1, bty="n")
}

if(plottype=="DisGeNET"){
  ### DisGeNET
  num <- nrow(dat)
  barcol <- "deepskyblue2"
  v8 <- unlist(as.character(rt[,8]))
  lab <- v8[ seq(1, 1*num, 1) ]
  genum <- paste(dat[,1], round(dat[,2],d=2), sep="/")
  xmax <- max( -log10(rev(dat[,3])) )
  #par(fig=c(0,0.5,0,1))   # fig=c(x1,x2,y1,y2)
  par(mar=c(5,4,4,28))
  y=barplot(-log10(rev(dat[,3])),
    horiz=T,
    xlim=c(xmax,0),
    xlab="-log10(Q-value)",
    col=barcol,
    yaxt="n",
    border=NA,
    main="DisGeNET disease (Gene# / Rich Factor)"
 )
 text(-log10(rev(dat[,3])), y, rev(genum), pos=2, adj=1, xpd=T,cex=1)
 text(0, y, rev(lab), adj=0, xpd=T, pos=4, cex=1, font=3)
}

dev.off()
### END
