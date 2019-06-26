#!/bin/bash
usage() 
{ 
    echo -e "
\e[1;33mThis script is used to build AllEnricher GO database for specified species.

    Usage: `basename $0` [options] [arg...]

        -v|version	AllEnricher GO database version to use, like\"GO20181026\";
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
            GOdb="${OPTARG}";;
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

if [ ! $GOdb ]
then
    echo "[error] Please specify the AllEnricher GO database version to use."
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
dbpath=$bin/../database/basic/go/$GOdb

# generate gene2GO table
echo -e "\e[1;37m[`date`]|---Generate $organism gene2GO table..\n"$(tput sgr0)
echo -e "\e[1;37m[`date`]|---Trying to extract from NCBI gene2go.gz..."$(tput sgr0)
perl $bin/gene2GO_extract.pl -a $dbpath/gene2go.gz -b $dbpath/gene_info.gz -t $taxid -n $organism -d $outdir && succesed="yes" && echo "---|Successed!"

if [ "$succesed" != "yes" ];then
	echo -e "\n\e[1;37m|---Trying to extract from GOA gaf.gz..."$(tput sgr0)
	echo `date`
	perl $bin/goa2go.pl -gaf $dbpath/goa_uniprot_all.gaf.gz -s $organism -t $taxid -o $outdir && echo "---|Successed!"
fi

# generate GO2term table
echo -e "\n\n\e[1;37m[`date`]|---Generate $organism GO2term table.."$(tput sgr0)
perl $bin/obo2go.pl $dbpath/go-basic.obo > $outdir/$organism.GO2disc && echo "---|Successed!"
echo -e "[`date`]|---Gzip result file..."
gzip -f $outdir/$organism.GO2disc && echo "---|Successed!" 

echo -e "\n\n\e[1;37m[`date`]---|GO database for $organism build done.."$(tput sgr0)

