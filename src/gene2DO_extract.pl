#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Cwd;
use PerlIO::gzip;

my $usage=<<"USAGE";
name:    $0
usage:   perl $0
	 extracting genes and theirs GO terms for A given species from NCBI collection file.
          
	 -I  <file>  gene-doid-disease file;
	 -D  <str>   out dir of output file; [./]
	
USAGE

my ($gene2do, $outdir, $help);
GetOptions (
    "I=s" => \$gene2do,
    "D:s" => \$outdir,
    "help|?|h" => \$help,
);

######
if($help){
	print $usage;
	exit 1;
}
$outdir ||= ".";
unless($gene2do){
	print $usage;
	exit 1;
}

######
print STDERR "|--- perl $0 begin\n";
my %Doid;
my %DO;
my %Symbol;

if($gene2do=~/\.gz$/){
	open GG, "<:gzip", $gene2do or die $!;
}
else{
	open GG, $gene2do or die $!;
}
print STDERR "|--- read file: $gene2do\n";
my $n=0;
while(<GG>){
	chomp;
	my @aa = split(/\t/);
	my ($symbol, $doid, $disease) = @aa[0,1,2];
        $Doid{$doid}=$doid;
        $Symbol{$symbol}=$symbol;
	$DO{$symbol}{$doid}=$disease;
	$n++;
}
die "[Failure]: No DO anotation infomation in input file!!!\n" if $n==0;
print STDERR "---| Find $n gene-DO annotations in total...\n";
close GG;

######
print STDERR "|--- write file: $outdir/hsa.DO2gene.tab.gz\n";
open OUB, ">:gzip", "$outdir/hsa.DO2gene.tab.gz" or die $!;

print OUB "Gene";
print OUB "\t$_" foreach sort keys %Doid;
print OUB "\n";

my %uniq;
foreach my $ge (sort keys %Symbol){
        my @out = ();
        push @out, $ge;
        foreach my $doid (sort keys %Doid){
                if(exists $DO{$ge}{$doid}){
                    #print OUA "$doid\t".$DO{$ge}{$doid}."\n";
                    my $disc=$DO{$ge}{$doid};
                    $uniq{$doid}=$disc;
                }
                my $k = $DO{$ge}{$doid} ? 1 : 0;
                push @out, $k;
        }
        print OUB join "\t",@out;
        print OUB "\n";
}
close OUB;

print STDERR "|--- write file: $outdir/hsa.DO2disc.gz\n";
open OUA, ">:gzip", "$outdir/hsa.DO2disc.gz" or die $!;
my $N=0;
foreach my $doid (sort keys %uniq){
    $N++;
    print OUA "$doid\t".$uniq{$doid}."\n";
}
print STDERR "---| Find $N DO terms in total...\n";
close OUA;
print STDERR "---| perl $0 finished\n";
exit 0;
