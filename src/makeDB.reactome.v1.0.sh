#!/bin/bash
usage() 
{ 
    echo -e "
\e[1;33mThis script is used to build AllEnricher GO database for specified species.

    Usage: `basename $0` [options] [arg...]

        -v|version	AllEnricher Reactome database version to use, like\"Reactome20181026\";
        -s|species	Organism kegg abbreviation, like \"hsa\" for human;
        -i|taxid	Organism taxnomy id], like \"9606\" for human;
        -o|outdir	output path;
        -h|help	        Print this help information."$(tput sgr0)
    exit 1 
} 

if [ $# == 0 ]; then 
    usage 
fi 

while getopts 'v:s:i:o:h' opt; 
do	
    case ${opt} in
        v|version)
            Redb="${OPTARG}";;
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

if [ ! $Redb ]
then
    echo "[error] Please specify the AllEnricher Reactome database version to use."
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

bin=`cd $(dirname $0);pwd`
date="`date +%Y%m%d`"
dbpath=$bin/../database/basic/reactome/$Redb

# generate gene2pathway table
echo -e "\e[1;37m[`date`]|---Generate $organism gene2Reactome pathway table..\n"$(tput sgr0)
echo -e "\e[1;37m[`date`]|---Extract from NCBI2Reactome file..."$(tput sgr0)
perl $bin/gene2ReactomePathway_extract.pl -A $dbpath/NCBI2Reactome_All_Levels.txt.gz -B $dbpath/gene_info.gz -T $taxid -N $organism -D $outdir && echo "---|Successed!"

# generate pathway2term table
echo -e "\n\n\e[1;37m[`date`]|---Generate $organism pathway2term table.."$(tput sgr0)
perl -alne '@a=split(/\t/,$_);$a[3]=~s/[\s]/\_/g;print "$a[2]\t$a[3]"' $outdir/$organism.gene2pathway.txt | sort |uniq > $outdir/$organism.Reactome2disc && echo "---|Successed!"
echo -e "\n\n\e[1;37m[`date`]|---Gzip result file..."$(tput sgr0)
gzip -f $outdir/$organism.Reactome2disc && echo "---|Successed!" 

echo -e "\n\n\e[1;37m[`date`]---|Reactome database for $organism build done.."$(tput sgr0)

