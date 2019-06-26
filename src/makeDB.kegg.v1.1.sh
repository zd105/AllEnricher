#!/bin/bash

usage() 
{ 
    echo -e "
\e[1;33mThis script is used to build AllEnricher KEGG database for specified species.

    Usage: `basename $0` [options] [arg...]

        -g|geneinfo	Absolute directory of gene_info.gz file from ncbi,like: All_Mammalia.gene_info.gz;
        -s|species	Organism kegg abbreviation, like \"hsa\" for human;
        -i|taxid	Organism taxnomy id], like \"9606\" for human;
        -o|outdir	output files path;
        -R|Rscript	Rscript program, like \"\$WHEREYOUR/Rscript\";
        -h|help	        Print this help information." 
    exit 1 
} 

if [ $# == 0 ]; then 
    usage 
fi 

while getopts 'g:s:i:o:R:h' opt; 
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

if [ ! $geneinfo ]
then
    echo "[error] Please specify the gene_info file to use."
    exit 1
fi

if [ ! $organism ]
then
    echo "[error] Please specify the organism kegg abbreviation."
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

if [ ! $Rscript ]
then
    echo "[error] Please specify the Rscript program to use."
    exit 1
fi

bin=`cd $(dirname $0);pwd`
date="`date +%Y%m%d`"

mkdir -p $outdir/temp

## 01 organism kegg map grab
echo -e "\e[1;37m[`date`]|---$organism kegg map grabbing..."$(tput sgr0)
$Rscript $bin/keggMapGrab.R $organism $outdir/temp/tmp01.$organism.kegg.map.html

cat $outdir/temp/tmp01.$organism.kegg.map.html |perl -alne '
    s/\\n/\n/g;
    s/\\t/\t/g; 
    print;
' | perl -lne '
    if(/^\s([A-Z].*\w$)/){
        print $1;
    };
    if(/^\<b\>(.*)\<\/b\>$/){
        print $1;
    };
    if(/^(\d+).*\>(.*)\<\/a\>\<br\>$/){
        print "$1  $2";
    }
' | perl -lne '
    BEGIN{
         print "KEGG pathway maps -> https://www.kegg.jp/kegg-bin/show_organism?menu_type=pathway_maps&org='$organism'\n\n"
    };
    print;
' > $outdir/temp/tmp02.$organism.kegg.map


## 02 pathway gene grap
echo -e "\n\n\e[1;37m[`date`]|---$organism kegg pathway genes grabbing..."$(tput sgr0)
cat $outdir/temp/tmp02.$organism.kegg.map | perl -alne '
	BEGIN{ $last="00000"; } 
	print and next if /^#/; 
	if(/^(\d{5})/){
		print "$main\t$sub\t$1\t$_\thttp://www.kegg.jp/dbget-bin/www_bget?pathway+'$organism'$1";
	}else{ 
		if($last=~/^(\d{5})/){ 
			$sub=$_; 
		}else{ 
			$main=$sub; $sub=$_; 
		};
	};
        $last=$_;
' | perl -F"\t" -alne '
	$F[3]=~s/^\d{5}\s+//; 
	print join "\t",@F,"https://www.genome.jp/dbget-bin/get_linkdb?-t+9+path:'$organism'$F[2]";
' > $outdir/temp/tmp03.$organism.kegg.xls

mkdir -p $outdir/temp/pathways
cd $outdir/temp/
perl -F"\t" -alne '
    BEGIN{
        print "#!/usr/bin/Rscript\nlibrary(bitops)\nlibrary(RCurl)\nlibrary(XML)\n";
    };
    next if /^#/; 
    print "temp<-getURL(\"$F[5]\")\nsink(\"./pathways/'$organism'$F[2].html\")\ntemp\nsink()\ncat(\"Pathway grab succssed: '$organism'$F[2]\n\")\n";
' $outdir/temp/tmp03.$organism.kegg.xls > $outdir/temp/tmp04.$organism.PathwayGrab.R

$Rscript tmp04.$organism.PathwayGrab.R

for i in `ls pathways/*.html`;
do 
perl -alne '
    s/\\n/\n/g; s/\\t/\t/g; 
    print;
' $i | perl -lne '
    if(/>'$organism':(\d+)</){
        @a=split(/<\/a>\s+/,$_); 
        @b=split(/,\s+|;\s+/,$a[1]);  
        print $1,"\t",$b[0];
    };
' > ${i%.html}.glist ;
done

zcat $geneinfo | perl -alne 'print if($F[0] eq '$taxid')' > $outdir/temp/$organism.gene_info

for i in `ls pathways/*.glist`;
do 
perl -F"\t" -alne '
    BEGIN{
        open I, "'$organism'.gene_info"; 
        while(<I>){
            chomp;
            next if /^#/;
            @a=split(/\t/,$_);
            $h{$a[1]}=$a[2];
        }
        close I;
    }
    if(exists $h{$F[0]}){ 
        print $F[0],"\t",$h{$F[0]}
    }else{
        print $_;
    };
' $i > $i.tab;
done


## 03 kegg gene table and pathway table generation
echo -e "\n\n\e[1;37m[`date`]|---$organism kegg gene table and pathway table generation..."$(tput sgr0)
perl $bin/pathway2tab.pl $outdir/temp/tmp03.$organism.kegg.xls $outdir/temp/pathways $organism > $outdir/$organism.kegg2gene.tab
cat $outdir/temp/tmp03.$organism.kegg.xls | perl -F"\t" -alne '
    ($a, $b, $c) = @F[0,1,3]; 
    $a=~s/\s+/_/g; $b=~s/\s+/_/g; $c=~s/\s+/_/g;  
    print join "\t","'$organism'$F[2]","$a|$b|$c";
' > $outdir/$organism.kegg2disc

echo -e "\n\e[1;37m[`date`]|---KEGG results gzip..."$(tput sgr0)
gzip -f $outdir/$organism.kegg2gene.tab && echo $organism.kegg2gene.tab gzip done...
gzip -f $outdir/$organism.kegg2disc && echo $organism.kegg2disc gzip done...

echo -e "\n\e[1;37m[`date`]|---Clear the temporary files..."$(tput sgr0)
mv $outdir/temp/$organism.gene_info $outdir/
rm -rf $outdir/temp/ && echo done...

echo -e "\n\n\e[1;37m[`date`]---|KEGG database for $organism build done..."$(tput sgr0)
