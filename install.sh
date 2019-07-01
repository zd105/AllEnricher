#!/bin/bash

bin=`cd $(dirname $0);pwd`

usage() 
{ 
    echo -e "\e[1;33m
This is a installation shell script of AllEnricher.

\e[1;33m[Usage]: `basename $0`
    -R|Rscript	Rscript program to use.
    -P|Perl	perl program to use.
    -h|help	Print this help information." 
    exit 1 
} 

while getopts 'R:P:h' opt; 
do	
    case ${opt} in
        R|Rscript)
            Rscript="${OPTARG}";;
        P|Perl)
            perl_abs="${OPTARG}";;
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
    Rscript=`which Rscript`
    echo "Installing to the default R: $Rscript"
fi

if [ ! $perl_abs ]
then
    perl_abs=`which perl`
    echo "Installing to the default perl: $perl_abs"
fi

echo -e "|--- Installing dependent Perl modules...\n"
status=0
$perl_abs -MPerlIO::gzip -e "print\"module PerlIO::gzip had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan PerlIO::gzip
    $perl_abs -MPerlIO::gzip -e "print\"module PerlIO::gzip had installed\n\"" || echo "Cannot install module PerlIO::gzip." && exit 1;
fi

status=0
$perl_abs -MFindBin -e "print\"module FindBin had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan FindBin
    $perl_abs -MFindBin -e "print\"module FindBin had installed\n\"" || echo "Cannot install module FindBin." && exit 1;
fi

status=0
$perl_abs -MGetopt::Long -e "print\"module Getopt::Long had installed\n\"" || status=1
if [ $status == 1 ];then
    cpan Getopt::Long
    $perl_abs -MGetopt::Long -e "print\"module Getopt::Long had installed\n\"" || echo "Cannot install module Getopt::Long." && exit 1;
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
