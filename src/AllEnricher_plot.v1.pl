#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
#use File::Basename qw(basename dirname);
#use PerlIO::gzip;
my $usage=<<"USAGE";

Name:    A graphical display for AllEnricher results

Version: 1.0	 
Usage:   perl $0
	 -i <str>  read the output of AllEnricher as an inputfile, such as allenricher.GO.xls;
	 -t <str>  specify the type of analysis, such as GO, pathway, default is GO;
		   optional: GO,KEGG,DO and Reactome; 
	 -n <int>  cutoff for 'Observed', default is 2 
	 -f <flt>  cutoff for 'RichFactor', default is 2
	 -q <flt>  cutoff for 'adjP', default is 0.05
	 -r  <flt> Rscript program;
	 -o <str>  prefix of output file, default is "./AllEnricher_plot"
	
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
	"r:s" => \$Rscript
);  

die $usage if $help;
die $usage unless $infile;
die $usage unless $Rscript;

$type ||= 'GO';
$observed ||= 2;
$fold ||= 2;
$q ||= 0.05;
$out_prefix ||= "./allenricher.$type.plot";

#my $aa = @ARGV;
open IN, $infile or die "[err] can not open the output: $infile\n";
open OUT, "> $out_prefix.tmp1.xls" or die "[err] can not open the output: $out_prefix.tmp1.xls\n";
while(<IN>){
    chomp;
    my @a=split;
    if($type eq "GO"){
        if($a[0]=~/GO\:\d+/ && $a[2]>=$observed && $a[4]>$fold && $a[6]<$q){
            print OUT $_;
            print OUT "\n";
        } 
    }else{
        if($a[0]=~/\w+\d+/ && $a[2]>=$observed && $a[4]>$fold && $a[6]<$q){
            print OUT $_;
            print OUT "\n";
        }
    }
}
close IN;
close OUT;

if(!-e $Rscript){
	print STDERR "[err] $Rscript does't exists,\nplease specify the path of Rscript\n";
	exit 0;
}
# bar plot
print STDERR "========= AllEnricher_barplot ============\n";
#print STDERR "[run] $Rscript $Bin/AllEnricher_barplot.R $type $out_prefix.tmp1.xls $out_prefix\_barplot\n";
system("$Rscript $Bin/AllEnricher_barplot.R $type $out_prefix.tmp1.xls $out_prefix\_barplot");
# bubbleplot
print STDERR "========= AllEnricher_bubble plot ============\n";
system("\(head -1 $out_prefix.xls; cat $out_prefix.tmp1.xls\) \| sed \'s\/\\x27\/\/g\' \> $out_prefix.forplot.xls");
#print STDERR "[run] $Rscript $Bin/enrich_bubble_Plot.R $out_prefix.forplot.xls $out_prefix\_bubbleplot\n";
system("$Rscript $Bin/enrich_bubble_Plot.R $out_prefix.forplot.xls $out_prefix\_bubbleplot");
system("rm -vf $out_prefix.forplot.xls");


print STDERR "[ok] $0 is finished\n";
exit 1;
