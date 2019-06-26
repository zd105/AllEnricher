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
    	$ref{$a[1]}=$a[2];
        $ref{$a[2]}=$a[2];
        my @b==split(/\|/,$a[3]);
        foreach my $gene(@b){
            $ref{$gene}=$a[2];
        }
        #print "$a[1]\t$a[2]\n";
}
close IN;

if($ARGV[1]=~/\.gz/){
    open TA,"<:gzip",$ARGV[1] or die $!;
}
else{
    open TA, "<$ARGV[1]" or die "can't open $ARGV[1]";
}

open OUT, ">$ARGV[2]" or die $!;
while(<TA>){
    my @b = split;
    #print "$b[0]\n";
    if(exists $ref{$b[0]}){
    	print OUT "$ref{$b[0]}\t$b[2]\t$b[3]\n";
    }elsif(exists $ref{$b[1]}){
        print OUT "$ref{$b[1]}\t$b[2]\t$b[3]\n";
    }else{
        print $_;
    }
}
close OUT;
close TA;

