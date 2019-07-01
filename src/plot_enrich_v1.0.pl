#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
my $usage=<<"USAGE";

name:    A graphical display for AllEnricher results
	 
	 AllEnricher is designed for functional genomic and large-scale genetic
	 studies from which large number of gene lists (e.g. differentially
	 expressed gene sets, co-expressed gene sets, or differential epigenomic
	 modification gene sets etc) are continuously generated. AllEnricher incorporates
	 information from different public resources and provides an easy way for
	 biologists to make sense for the interesting gene lists.

usage:   perl $0
	 -i <str>  read the output of AllEnricher as an inputfile, such as allenricher.GO.xls;
	 -t <str>  specify the type of analysis, such as GO, pathway, default is GO;
		   optional: GO,KEGG,DO and Reactome; 
	 -n <int>  cutoff for 'Observed', default is 2 
	 -f <flt>  cutoff for 'RichFactor', default is 2
	 -q <flt>  cutoff for 'adjP', default is 0.05
	 -Rscript  <flt> Rscript program;
	 -o <str>  prefix of output file, default is "./allenricher_plot"
	
USAGE

my ($infile, $type, $observed, $fold, $q, $help, $out_prefix,$Rscript);

GetOptions ( 
	"i=s" => \$infile,
	"t:s" => \$type,
        "n:i" => \$observed,
        "f:f" => \$fold,
        "q:f" => \$q,
	"h|?|help" => \$help,
	"o:s" => \$out_prefix,
	"Rscript:s" => \$Rscript
);  

die $usage if $help;
die $usage unless $infile;
die $usage unless $Rscript;

$type ||= 'GO';
$observed ||= 2;
$fold ||= 1;
$q ||= 0.05;
$out_prefix ||= "./allenricher.$type.plot";

#my $aa = @ARGV;
open IN, $infile or die "[err] can not open the output: $infile\n";
open OUT, "> $out_prefix.tmp1.xls" or die "[err] can not open the output: $out_prefix.tmp1.xls\n";
while(<IN>){
    chomp;
    my @a=split;
    if($a[0]=~/.*\d$/ && $a[2]>$observed && $a[4]>$fold && $a[6]<$q){
            print OUT $_;
            print OUT "\n";
    }
}
close IN;
close OUT;

if(!-e $Rscript){
	print STDERR "[err] $Rscript does't exists,\nplease specify the path of Rscript\n";
	exit 0;
}
# bar plot
#print STDERR "========= AllEnricher barplot ============\n";
system("$Rscript $Bin/barplot.R $type $out_prefix.tmp1.xls $out_prefix\_barplot && echo [ok] AllEnricher barplot done ...");
# bubbleplot
#print STDERR "========= AllEnricher bubble plot ============\n";
system("\(head -1 $out_prefix.xls; cat $out_prefix.tmp1.xls\) \| sed \'s\/\\x27\/\/g\' \> $out_prefix.forplot.xls");
system("$Rscript $Bin/bubble_plot.R $out_prefix.forplot.xls $out_prefix\_bubbleplot && echo [ok] AllEnricher bubble plot done ...");
system("rm -vf $out_prefix.tmp1.xls && rm -vf $out_prefix.forplot.xls");

print STDERR "[ok] $0 is finished\n";
exit 1;
