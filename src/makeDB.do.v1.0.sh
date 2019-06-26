#!/bin/bash
usage() 
{ 
    echo -e "
\e[1;33mThis script is used to build AllEnricher Disease Ontology database for specified species.

    Usage: `basename $0` [options] [arg...]

        -g|geneinfo     Absolute directory of gene_info.gz file from ncbi,like: All_Mammalia.gene_info.gz;
        -s|species	Organism kegg abbreviation, like \"hsa\" for human;
        -i|taxid	Organism taxnomy id], like \"9606\" for human;
        -o|outdir	output path;
        -h|help	        Print this help information."$(tput sgr0)
    exit 1 
} 

if [ $# == 0 ]; then 
    usage 
fi 

while getopts 'g:s:i:o:h' opt; 
do	
    case ${opt} in
        g|geneinfo)
            geneinfo="${OPTARG}";;
        s|species)
            organism="${OPTARG}";;
	i|taxid) 
	    taxid="${OPTARG}";;
        o|outdir)
            outdir="${OPTARG}";;
        h|help)
            usage
            exit 1;;
        ?)
            usage
	    exit 1
    esac
done

if [ ! $geneinfo ]
then
    echo "[error] Please specify the gene_info file to use."
    exit 1
fi

if [ ! $organism ]
then
    echo "[error] Please specify the organism kegg  abbreviation."
    exit 1
fi

if [ ! $taxid ]
then
    echo "[error] Please specify the organism taxnomy id."
    exit 1
fi

if [ ! $outdir ]
then
    echo "[error] Please specify the output directory."
    exit 1
fi

# only support human
if [ $organism != "hsa" ]
then
    echo "[error] Sorry, not support species except for human."
    exit 1
fi

bin=`cd $(dirname $0);pwd`
date="`date +%Y%m%d`"

# generate gene2GO table
echo -e "\e[1;37m[`date`]|---Generate $organism gene2DO table.."$(tput sgr0)

# data download from Disease
mkdir -p $outdir/tmp2/
cd $outdir/tmp2/
echo -e "\e[1;37m[`date`]|---Download $organism disease-gene association tables from Disease database..\n"$(tput sgr0)
wget -c http://download.jensenlab.org/human_disease_textmining_filtered.tsv || exit 1
wget -c http://download.jensenlab.org/human_disease_knowledge_filtered.tsv  || exit 1
wget -c http://download.jensenlab.org/human_disease_experiments_filtered.tsv || exit 1

# get symbol-DOid-discription
echo -e "\e[1;37m[`date`]|---Extract genesymbol-DOid-disease associations ...\n"$(tput sgr0)
perl -F'\t' -alne 'if($F[2]=~/DOID\:\d+/){$F[3]=~s/[\s|\-]/\_/g;print join "\t",@F[1..3],"textmining"}' human_disease_textmining_filtered.tsv | sed "s/'//g" | sort | uniq > human_disease_textmining.dga
perl -F'\t' -alne 'if($F[2]=~/DOID\:\d+/){$F[3]=~s/[\s|\-]/\_/g;print join "\t",@F[1..3],"knowledge"}' human_disease_knowledge_filtered.tsv | sort | uniq > human_disease_knowledge.dga || exit 1
perl -F'\t' -alne 'if($F[2]=~/DOID\:\d+/){$F[3]=~s/[\s|\-]/\_/g;print join "\t",@F[1..3],"experiments"}' human_disease_experiments_filtered.tsv | sort | uniq > human_disease_experiments.dga || exit 1

# merge
echo -e "\e[1;37m[`date`]|---Merge DO evidence ...\n"$(tput sgr0) 
cat human_disease_textmining.dga human_disease_knowledge.dga human_disease_experiments.dga | cut -f1,2,3 | sort | uniq  > human_disease_all.dga || exit 1

# filter unmapped genes in gene_info of NCBI
echo -e "\e[1;37m[`date`]|---Filter unmapped genes in gene_info of NCBI ...\n"$(tput sgr0)
zcat $geneinfo | perl -alne 'print if($F[0] eq '$taxid')' > $organism.gene_info || exit 1
perl $bin/gene_filter.pl $organism.gene_info human_disease_all.dga human_disease_all_final.dga > human_disease_uncovered.dga || exit 1

echo -e "\e[1;37m[`date`]|---Build standard DO AllEricher database tables ...\n"$(tput sgr0)
perl $bin/gene2DO_extract.pl -I human_disease_all_final.dga -D $outdir || exit 1
cd $outdir
echo -e "\e[1;37m[`date`]|---Remove template files ...\n"$(tput sgr0)
rm -rf $outdir/tmp2/ || exit 1
echo -e "\e[1;37m[`date`]|---Build DO database for $organism finished!\n"$(tput sgr0)

