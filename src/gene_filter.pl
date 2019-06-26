#!/usr/bin/perl
use strict;
use warnings;
use PerlIO::gzip;

my ($aa, $bb,$out) = @ARGV;
if($ARGV[0]=~/\.gz/){
    open IN,"<:gzip",$ARGV[0] or die $!;
}
else{
    open IN, "<$ARGV[0]" or die "can't open $ARGV[0]";
}

#open IN, $aa or die "$! --> $aa\n";
my %ref;
while(<IN>){
    chomp;
    
    	my @a=split;
        $a[2]=uc($a[2]);
        $a[4]=uc($a[4]);
    	$ref{$a[2]}=$a[2];
        #print "$a[2]\t$a[4]\n";
        my @b=split(/\|/,$a[4]);
        foreach my $gene(@b){
            $ref{$gene}=$a[2];
            #print "$gene\n";
        }
        if($a[5]=~/HGNC:(HGNC:\d+)/){$ref{$1}=$a[2]};
        if($a[5]=~/Ensembl:(ENSG\d+)/){$ref{$1}=$a[2]};
}
close IN;

if($ARGV[1]=~/\.gz/){
    open TA,"<:gzip",$ARGV[1] or die $!;
}
else{
    open TA, "<$ARGV[1]" or die "can't open $ARGV[1]";
}

open OUT, ">$out" or die $!;
while(<TA>){
    my @b = split;
    #print "$b[0]\n";
    $b[0]=uc($b[0]);
    if($b[0] eq "18S_RRNA"){$b[0] = "RNA18SP"};
    if($b[0] eq "5S_RRNA"){$b[0] = "RNA5SP"};
    if($b[0] eq "45S_RRNA"){$b[0] = "RNA45SP"};
    if($b[0] eq "28S_RRNA"){$b[0] = "RNA28SP"};
    if($b[0]=~/^HSA\-MIR\-([\d|\w]*)/i){$b[0] = "MIR".$1};
    if($b[0]=~/^HSA\-LET\-([\d|\w]*)/i){$b[0] = "MIRLET".$1};
    if($b[0]=~/^MT\-/){$b[0]=~s/\-//g};
    if(exists $ref{$b[0]}){
    	print OUT "$ref{$b[0]}\t$b[1]\t$b[2]\n";
    }else{
        print $_;
    }
}
close OUT;
close TA;

