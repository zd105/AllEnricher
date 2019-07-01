#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PerlIO::gzip;

my $usage=<<"USAGE";
name:    $0
usage:   perl $0
	 extracting genes and theirs GO terms for A given species from NCBI collection file.
          
	 -A  <file>  gene2go[.gz];  file gene2go downloaded from NCBI;
	 -B  <file>  organism.gene_info[.gz]; file organism.gene_info.gz downloaded from NCBI;
	 -T  <int>   taxonomy ID; taxonomy id of this organism, such as 9606 for human;
	 -N  <str>   abbreviation of this organism; hsa, mmu, ssc and et al;
	 -D  <str>   out dir of output file; [./]
	
USAGE

my ($gene2go, $geneinfo, $taxid, $name, $outdir, $help);
GetOptions (
    "A=s" => \$gene2go,
    "B=s" => \$geneinfo,
    "T=i" => \$taxid,
    "N:s" => \$name,
    "D:s" => \$outdir,
    "help|?|h" => \$help,
);

######
if($help){
	print $usage;
	exit 1;
}
$outdir ||= ".";
$name ||= "undetermined";
unless($gene2go && $geneinfo && $taxid){
	print $usage;
	exit 1;
}

######
print STDERR "|--- perl $0 begin\n";
my %gene;
my %tab;
my %GO;
my %Symbol;

######
if($geneinfo=~/\.gz$/){
	open GI, "<:gzip", $geneinfo or die $!;
}
else{
	open GI, $geneinfo or die $!;
}
print STDERR "|--- read file: $geneinfo\n";
while(<GI>){
	chomp;
	next if /^#/;
	my @aa = split(/\t/);
	my ($id, $gid, $symbol) = @aa[0,1,2];
	next if $id != $taxid;
	$gene{$gid} = $symbol;
}
close GI;

if($gene2go=~/\.gz$/){
	open GG, "<:gzip", $gene2go or die $!;
}
else{
	open GG, $gene2go or die $!;
}
open OUA, ">$outdir/$name.gene2go.txt" or die $!;
print STDERR "|--- read file: $gene2go\n";
my $n=0;
while(<GG>){
	chomp;
	next if /^#/;
	my @aa = split(/\t/);
	my ($id, $gid, $go, $goname, $type) = @aa[0,1,2,5,7];
	next unless $id == $taxid;
	my $symbol = $gene{$gid} ? $gene{$gid} : $gid;
	$Symbol{$symbol} = 1;
	$GO{$go} = 1;
	print OUA "$symbol\t$gid\t$go\t$type\t$goname\n";
	$tab{$symbol}{$go} = 1;
	$n++;
}
die "[Attention]: No GO anotation infomation in NCBI gene2go.gz file!!!\n" if $n==0;
print STDERR "Find $n gene2go terms in total...\n";
close GG;
close OUA;

######
print STDERR "|--- write file: $outdir/$name.GO2gene.tab.gz\n";
open OUB, ">:gzip", "$outdir/$name.GO2gene.tab.gz" or die $!;

print OUB "Gene";
print OUB "\t$_" foreach sort keys %GO;
print OUB "\n";

foreach my $ge (sort keys %Symbol){
        my @out = ();
        push @out, $ge;
        foreach my $go (sort keys %GO){
                my $k = $tab{$ge}{$go} ? 1 : 0;
                push @out, $k;
        }
        print OUB join "\t",@out;
        print OUB "\n";
}
close OUB;
print STDERR "|--- perl $0 finished\n";
exit 0;
