#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PerlIO::gzip;
my $usage=<<"USAGE";
name:    $0
usage:   perl $0
             -gaf  <str>   gaf.gz file;
             -s    <str>   organism abbreviation name;
             -t    <int>   taxmony id;
             -out  [str]   outdir;
             -h    <str>   help
USAGE
my ($gaf,$organism,$taxid,$out,$help);
GetOptions (
		"gaf=s"        => \$gaf,
		"s=s"     => \$organism,
		"t=i"     => \$taxid,
		"out=s"     => \$out,
		"h=s"          => \$help
		);
die $usage if $help;
die $usage unless $gaf;
die $usage unless $organism;
die $usage unless $taxid;
die $usage unless $out;


my %tab;
my %GO;
my %GENE;

open OUT, ">$out/$organism.geneSymbol2GO.txt" or die $!;
open OUT2, ">:gzip","$out/$organism.GO2gene.tab.gz" or die $!;
open IN, "zcat $gaf |" or die $!;
while(<IN>){
	chomp;
	next if /^!/;
	# next unless /^UniProtKB/;
	my @arr = split(/\t/, $_);
	next if($arr[12] !~ /^taxon\:$taxid/);
	next unless $arr[4]=~/GO:/;
	next if $arr[2] eq $arr[1];
	# next if $arr[2]=~/[a-z]/;
	next if $arr[2]=~/^[0-9]/;
	print OUT "$arr[2]\t$arr[4]\t$arr[8]\t$arr[9]\t$arr[10]\n";
	$GO{$arr[4]} = 1;
	$GENE{$arr[2]} = 1;
	$tab{$arr[2]}{$arr[4]} = 1;
}
close IN;
print OUT2 "Gene";
my $gonum=0;
foreach my $go(sort keys %GO){
	print OUT2 "\t$go";
	$gonum++;
}
print OUT2 "\n";

my $genenum=0;
foreach my $ge (sort keys %GENE){
	$genenum++;
	my @out = ();
	push @out, $ge;
	foreach my $go (sort keys %GO){
		my $k = $tab{$ge}{$go} ? 1 : 0;
		push @out, $k;
	}
	print OUT2 join "\t",@out;
	print OUT2 "\n";
}
die "[Failure]: No GO anotation infomation in GOA gaf.gz file!!!\n" if $genenum==0;
print STDERR "Find $genenum genes refers to $gonum GO terms in total...\n";
close OUT2;
close OUT;
