#!/usr/bin/Rscript

# Rscript enrich.R in background_total gene_total test_method Adjustment Cutoff out

args    <- commandArgs(TRUE)
infile  <- args[1]
N 	<- as.numeric(args[2])
n	<- as.numeric(args[3])
test <-args[4]  # fisher.test() or phyper()
adj     <- args[5]
cutoff  <- as.numeric(args[6])
outfile <- args[7]

rt  <- read.table(infile, sep="\t", head=T)
dat <- rt[ rt[,3]>=1, ]

mat <- dat[,2:3]
mat <- cbind(mat,0)
mat <- cbind(mat,0)

for(i in 1:nrow(mat)){
        M <-mat[i,1]
	k <-mat[i,2]
	m <- data.frame(gene.not.interest=c(M-k, N-M-n+k), gene.in.interest=c(k, n-k))
	row.names(m) <- c("In_category", "not_in_category")
	if(test == "phyper"){
		mat[i,3] <-phyper(k-1,M, N-M, n, lower.tail=FALSE)
	}else if(test == "fisher"){
		mat[i,3] <- fisher.test(m)$p.value
	}
}

mat[,4] <- p.adjust( mat[,3], method=adj, n=length(mat[,3]) )

out <- cbind(dat,mat)[,c(1:5,9,10,6)]
colnames(out) <- c("TermID","TermGeneNum","ObservedGeneNum","ExpectedGeneNum","RichFactor","rawP","adjP","GeneList")
out <- out[order(out[,7]),]
write.table(out, file=outfile, quote=F, sep = "\t", row.names = F)
