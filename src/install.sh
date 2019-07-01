#!/bin/bash

bin=`cd $(dirname $0);pwd`

usage() 
{ 
    echo -e "\e[1;33m
This is a installation shell script of AllEnricher.

\e[1;33m[Usage]: `basename $0`
    -R|Rscript	Rscript absolute path;
    -h|help	Print this help information." 
    exit 1 
} 

while getopts 'R:h' opt; 
do	
    case ${opt} in
        R|Rscript)
            Rscript="${OPTARG}";;
        h|help)
            usage
            exit 1;;
        ?)
            usage
	    exit 1
    esac
done

if [ ! $Rscript ]
then
    echo "[error] Please specify the Rscript program to use."
    exit 1
fi


echo -e "|--- Installing dependent Perl modules...\n"
status=0
perl -MPerlIO::gzip -e "print\"module PerlIO::gzip had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan PerlIO::gzip
    perl -MPerlIO::gzip -e "print\"module PerlIO::gzip had installed\n\"" || echo "Cannot install module PerlIO::gzip." && exit 1;
fi

status=0
perl -MFindBin -e "print\"module FindBin had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan FindBin
    perl -MFindBin -e "print\"module FindBin had installed\n\"" || echo "Cannot install module FindBin." && exit 1;
fi

status=0
perl -MGetopt::Long -e "print\"module Getopt::Long had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan Getopt::Long
    perl -MGetopt::Long -e "print\"module Getopt::Long had installed\n\"" || echo "Cannot install module Getopt::Long." && exit 1;
fi

echo -e "\n|--- Installing dependent R packages...\n"
$Rscript src/package.R

echo -e "\n|--- Granting executable permissions...\n"
chmod 755 AllEnricher
chmod 755 make_speciesDB
chmod 755 update_GOdb
chmod 755 update_ReactomeDB
chmod 755 src/*

echo -e "\n|--- Done...\n"
