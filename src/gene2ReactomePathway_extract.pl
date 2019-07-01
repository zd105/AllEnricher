#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PerlIO::gzip;

my $usage=<<"USAGE";
name:    $0
usage:   perl $0
	 extracting genes and theirs GO terms for A given species from NCBI collection file.
          
	 -A  <file>  gene2pathway[.gz];  file NCBI2Reactome.txt downloaded from Reactome;
	 -B  <file>  organism.gene_info[.gz]; file organism.gene_info.gz downloaded from NCBI;
	 -T  <int>   taxonomy ID; taxonomy id of this organism, such as 9606 for human;
	 -N  <str>   abbreviation of this organism; hsa, mmu, ssc and et al;
	 -D  <str>   out dir of output file; [./]
	
USAGE

my ($gene2pathway, $geneinfo, $taxid, $name, $outdir, $help);
GetOptions (
    "A=s" => \$gene2pathway,
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
unless($gene2pathway && $geneinfo && $taxid){
	print $usage;
	exit 1;
}

######
print STDERR "|--- perl $0 begin\n";
my %gene;
my %tab;
my %PATH;
my %Symbol;

######
if($geneinfo=~/\.gz$/){
	open GI, "<:gzip", $geneinfo or die $!;
}
else{
	open GI, $geneinfo or die $!;
}
print STDERR "|--- read file: $geneinfo\n";
open OUI, ">$outdir/$name.gene_info" or die $!;
while(<GI>){
	chomp;
	next if /^#/;
	my @aa = split(/\t/);
	my ($id, $gid, $symbol) = @aa[0,1,2];
	next if $id != $taxid;
	$gene{$gid} = $symbol;
        print OUI "$_\n";
}
close OUI;
close GI;

if($gene2pathway=~/\.gz$/){
	open GG, "<:gzip", $gene2pathway or die $!;
}
else{
	open GG, $gene2pathway or die $!;
}

my $name2=uc($name);
open OUA, ">$outdir/$name.gene2pathway.txt" or die $!;
print STDERR "|--- read file: $gene2pathway\n";
my $n=0;
while(<GG>){
	chomp;
	next if /^#/;
	my @aa = split(/\t/);
	my ($gid, $pid,$pname) = @aa[0,1,3];
        my @bb = split(/\-/,$pid);
	next unless $bb[1] eq $name2;
	my $symbol = $gene{$gid} ? $gene{$gid} : $gid;
	#my $symbol;
        #if($gene{$gid}){
        #    $symbol = $gene{$gid};
        #}else{
        #    print STDERR "[Warnning]: No gene symbol found in $name for NCBI Gene ID: $gid\n";
        #    next;
        #}
	$Symbol{$symbol} = 1;
	$PATH{$pid} = 1;
	print OUA "$symbol\t$gid\t$pid\t$pname\n";
	$tab{$symbol}{$pid} = 1;
	$n++;
}
die "[Failure]: No Reactome pathway anotation infomation in NCBI2Reactome.txt file!!!\n" if $n==0;
print STDERR "Find $n gene2pathways in total...\n";
die unless $n > 1;
close GG;
close OUA;

######
print STDERR "|--- write file: $outdir/$name.Reactome2gene.tab.gz\n";
open OUB, ">:gzip", "$outdir/$name.Reactome2gene.tab.gz" or die $!;

print OUB "Gene";
print OUB "\t$_" foreach sort keys %PATH;
print OUB "\n";

foreach my $ge (sort keys %Symbol){
        my @out = ();
        push @out, $ge;
        foreach my $pid (sort keys %PATH){
                my $k = $tab{$ge}{$pid} ? 1 : 0;
                push @out, $k;
        }
        print OUB join "\t",@out;
        print OUB "\n";
}
close OUB;
print STDERR "|--- perl $0 finished\n";
exit 0;
