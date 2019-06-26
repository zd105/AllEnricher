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

# generate gene-disease table
echo -e "\e[1;37m[`date`]|---Generate $organism gene-disease table.."$(tput sgr0)

# data download from Disease
mkdir -p $outdir/tmp2/
cd $outdir/tmp2/
echo -e "\e[1;37m[`date`]|---Download $organism disease-gene association tables from DisGeNET database..\n"$(tput sgr0)
wget -c http://www.disgenet.org/static/disgenet_ap1/files/downloads/all_gene_disease_associations.tsv.gz || exit 1

# get symbol-CUI-discription
echo -e "\e[1;37m[`date`]|---Extract genesymbol-CUI-disease associations ...\n"$(tput sgr0)
zcat all_gene_disease_associations.tsv.gz | perl -F'\t' -alne 'if($F[4]=~/C\d+/){$F[5]=~s/[\s|\-]/\_/g;print join "\t",@F[0,1,4,5]}'| sed "s/'//g" | sort | uniq > all_gene_disease_associations.tsv2

# filter unmapped genes in gene_info of NCBI
echo -e "\e[1;37m[`date`]|---Filter unmapped genes in gene_info of NCBI ...\n"$(tput sgr0)
zcat $geneinfo | perl -alne 'print if($F[0] eq '$taxid')' > $organism.gene_info || exit 1
perl $bin/DisGeNET_gene_filter.pl $organism.gene_info all_gene_disease_associations.tsv2 all_gene_disease_associations_final.tsv > human_disease_uncovered.tsv || exit 1

echo -e "\e[1;37m[`date`]|---Build standard DisGeNET AllEricher database tables ...\n"$(tput sgr0)
perl $bin/gene2CUI_extract.pl -I all_gene_disease_associations_final.tsv -D $outdir || exit 1
cd $outdir
echo -e "\e[1;37m[`date`]|---Remove template files ...\n"$(tput sgr0)
rm -rf $outdir/tmp2/ || exit 1
echo -e "\e[1;37m[`date`]|---Build DisGeNET localdatabase for $organism finished!\n"$(tput sgr0)

