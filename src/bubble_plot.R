#!/usr/bin/Rscript

library(ggplot2)

args <- commandArgs(TRUE)
enrichtable<-args[1]
prefix<-args[2]

dat = read.table(enrichtable, header = T, sep = "\t")
if(nrow(dat)>20){
    system('echo -e "\\e[1;31m[Warnning] Too many terms/pathways enriched, only the top 20 will be ploted." $(tput sgr0)')
    pdf(file=paste(prefix,"top20.pdf",sep="."),width=10)
    dat <- dat[c(1:20),]
}else{
    pdf(file=paste(prefix,"pdf",sep="."),width=10)
}


p = ggplot(dat, aes(RichFactor, TermName))

pbubble = p + geom_point(aes(size = ObservedGeneNum, color = -1 * log10(adjP)))

pr = pbubble + scale_colour_gradient(low = "blue", high = "red") + labs(
  color = expression(-log[10](Qvalue)),
  size = "Gene number",
  x = "Rich Factor (Obs/Exp)",
  y = "Terms or pathways",
  title = "Function enrichment bubble plot"
)+scale_size_area(max_size = 5)

pr + theme_bw()+ theme(panel.grid.major = element_line(size = 0.5))

dev.off()
