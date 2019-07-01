#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
#use File::Basename qw(basename dirname);
use PerlIO::gzip;
my $usage=<<"USAGE";

Name:    AllEnricher
	 
	 It is designed for functional genomic and large-scale genetic
	 studies from which large number of gene lists (e.g. differentially
	 expressed gene sets, co-expressed gene sets, or differential epigenomic
	 modification gene sets etc) are continuously generated. AllEnricher 
         incorporates information from different public resources and provides 
         an easy way for biologists to make sense out of gene lists.

Usage:   perl $0
	 -l <str>  gene sets list by gene symbols, one gene symbol per line.
	 -s <str>  specify the species kegg abbreviation name, default is hsa.
		   for example: 
			hsa : human 
  			mmu : mouse
			ssc : pig
                   check species kegg abbreviation and taxnomy id in "https://www.kegg.jp/kegg/catalog/org_list.html"
	 -t <str>  specify the type of analysis, such as GO,kegg, default is GO.
		   optional: GO,kegg,DO and Reactome.
	 -b <str>  specify the background gene sets for enrichment analysis, 
                   default is the whole genome genes.
	 -m <str>  specify the enrichment test method,
	               "fisher" for Fisher's exact test;(default)
		       "phyper" for Hypergeometric test.
	 -a <str>  specify Multiple Test Adjustment method, such as BH, BY, none, default is BH.
		   optional: BH, BY, holm, none.
	 -c <flt>  specify the cutoff value for Adjust p value, default is 1, means no filtering.
	 -v <str>  specify the AllEnricher organism GO and KEGG annotation database to use,like "v20181210".
                   default is the most recent version.
         -r <str>  Rscript program.
	 -o <str>  prefix of output file, default is "./allenricher".
	
USAGE

my ($List, $Rscript,$Species, $Type, $Background, $mode,$Adjustment, $Cutoff, $help, $Out,$version);

GetOptions ( 
	"l=s" => \$List,
	"s:s" => \$Species,
	"t:s" => \$Type,
	"b:s" => \$Background,
	"m:s" => \$mode,
	"a:s" => \$Adjustment,
	"c:f" => \$Cutoff,
	"v:s" => \$version,
	"h|?|help" => \$help,
	"o:s" => \$Out,
	"r:s" => \$Rscript
);  

die $usage if $help;
die $usage unless $List;
die $usage unless $Rscript;

if(!$version){
    my $allversion=`ls $Bin/../database/organism/`;
    my @b=split(/\n/,$allversion);
    $version ||=$b[-1];
}

$Species ||= 'hsa';
$Type ||= 'GO';
if($Type eq "DisGeNET"){$Type = "CUI"};
$Background ||= 'genome';
$mode ||='fisher';
$Adjustment ||= 'BH';
$Cutoff ||= 1;
$Out ||= "./allenricher.$Type";

if(!-e $Rscript){
	print STDERR "[error] $Rscript does't exists,\nplease specify the path of Rscript\n";
	exit 0;
}

my $ref_gene_sets = "$Bin/../database/organism/$version/$Species/$Species.$Type"."2gene.tab.gz";
my $id_map = "$Bin/../database/organism/$version/$Species/$Species.$Type"."2disc.gz";
my %gene_list;
my %gene_list1;
my %ref;
my %genome_list;
my %background_list;
my $background_total;
my $gene_total;
my %id2name;
my $bak_gene_sets = "$Bin/../database/organism/$version/$Species/$Species.gene_info";

### step 01 read-in gene set
open LI, $List or die "[error] can not open the gene sets list : $List\n";
while(<LI>){
	chomp;
	next if /^\s*$/;
	$gene_list{$_} = 1; 
}
close LI;
print STDERR "[ok] read in $List\n";

## step 02 read-in GO/KEGG anotation file
#print  "$ref_gene_sets\n";
open IN,"<:gzip",$ref_gene_sets or die "[error] can not open the reference gene sets : $ref_gene_sets\n";
my @term_list;
$background_total = 0;
while(<IN>){
	chomp;
	my @arr = split(/\t/, $_);
	if($.==1){
		push @term_list, $_ foreach @arr;
	}else{	
		my $gene = $arr[0];
		$genome_list{$gene} = 1;
                $background_total +=1;
		foreach my $i (1..$#arr){
			my $term = $term_list[$i];
			$ref{$term}{$gene} = $arr[$i] if $arr[$i]; 
		}
	}
}
close IN;
print STDERR "[ok] read in $ref_gene_sets\n";

## step 03 read-in backgroud list
if($Background eq "genome"){
	#  %background_list = %genome_list;   # old methods
	open IN, $bak_gene_sets or die "[error] can not open the background gene list : $bak_gene_sets\n";
	while(<IN>){
		chomp;
		my @arr = split(/\t/, $_);
		next if /^#/;
		my $gene_symbol = $arr[2];
		next
 if $gene_symbol =~/^\s*$/; 
		$background_list{ $gene_symbol } = 1;
	}
	close IN;
	print STDERR "[ok] read in Background gene list : $bak_gene_sets\n";
}else{
	open IN, $Background or die "[error] can not open the background gene sets: $Background\n";
	while(<IN>){
		chomp;
		next if /^\s*$/;
		$background_list{$_} = 1;
	}
	close IN;
	print STDERR "[ok] read in specified background gene list : $Background\n";
}

if($background_total>1){
	print STDERR "[ok] total background gene number: \e[1;31m$background_total\n";system("tput sgr0");
}else{
	print STDERR "[error] background gene number < 1\n";
	exit 1;
}

### step 04 gene set GO/KEGG function annotation
open OUT1, ">$Out.tmp1.xls" or die "[error] can not open the output: $Out.tmp1.xls\n";
print OUT1 "TermID\tTermGeneNum\tObservedGeneNum\tExpectedGeneNum\tRichFactor\tGeneList\n";
foreach my $term (keys %ref){
	my $num_in_C = 0;
	my $num_in_O = 0;
	my $Glist = "";  ## put gene into a hash ?
	foreach my $gene (keys %{$ref{$term}}){
		if( $ref{$term}{$gene} == 1 ){
			$num_in_C += 1 if exists $background_list{$gene};
			if( exists $gene_list{$gene} ){
				$num_in_O += 1;
				$gene_list1{$gene}=1; 
				$Glist .="$gene;";
			}
		}
	}
	$gene_total = scalar keys %gene_list1;
        if($num_in_O > 1){
	#if($num_in_O >= 1){
		my $expected = $background_total ? sprintf("%.6f", $num_in_C / $background_total * $gene_total) : 0.1;
		my $RichFactor = $expected != 0 ? sprintf("%.6f", $num_in_O / $expected) : 0;
		print OUT1 "$term\t$num_in_C\t$num_in_O\t$expected\t$RichFactor\t$Glist\n";
	}
}
close OUT1;
print STDERR "[ok] stat against background gene sets is over\n";

## step 05 gene set GO/KEGG enrichment 
print STDERR "[attention] Using \e[1;31m$mode test";system("tput sgr0");
print STDERR " for enrichment analysis!!!\n";
#print STDERR "[run] $Rscript $Bin/enrich.R $Out.tmp1.xls $background_total $gene_total $mode $Adjustment $Cutoff $Out.tmp2.xls\n";
system("$Rscript $Bin/enrich.R $Out.tmp1.xls $background_total $gene_total $mode $Adjustment $Cutoff $Out.tmp2.xls");

## step 06 read-in GO/KEGG map file
open MAP, "<:gzip", $id_map or die "[error] can not open $id_map\n";
while(<MAP>){
	chomp;
	my @arr = split(/\t/,$_);
	my $id = $arr[0];
	my $name = $arr[1];
	$name =~s/\s/_/g;
	$id2name{$id} = $name;
}
close MAP;

open XLS, "<$Out.tmp2.xls" or die "[error] can not open $Out.tmp2.xls\n";

open OUT, ">$Out.xls" or die "[error] can not open $Out.xls\n";

while(<XLS>){
	chomp;
	my @arr = split(/\t/,$_);
	if($.==1){
		print OUT join("\t", @arr[0..6], "TermName", $arr[7]) . "\n";
	}else{
		my $name = $id2name{$arr[0]} ? $id2name{$arr[0]} : "NA";
		print OUT join("\t", @arr[0..6], $name, $arr[7]) . "\n";
	}
}
close XLS;
close OUT;	
print STDERR "[ok] Term id convert to name finished..\n";

system("rm -vf $Out.tmp1.xls && rm -vf $Out.tmp2.xls && echo Temporay files delete done ...");

print STDERR "[ok] $0 is finished\n";

exit 0;
##### 
