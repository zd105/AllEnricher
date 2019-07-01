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
my %tax;
my $n=0;
while(<IN>){
    chomp;
    if(/^Proteome_ID/ || /^UP\d+/){
    	my @a=split;
        #print $a[1]."\n";
    	$tax{$a[1]}=1;
        $n++;
    }
}
print "GOA supports total species number: $n\n";
close IN;

if($ARGV[1]=~/\.gz/){
    open TA,"<:gzip",$ARGV[1] or die $!;
}
else{
    open TA, "<$ARGV[1]" or die "can't open $ARGV[1]";
}

open OUT, ">:gzip",$out or die $!;
while(<TA>){
    next if(/^\!/);
    chomp;
    my @b = split(/\t/);
    #print $b[-3]."\n";
    if($b[-3]=~/taxon:(\d+)$/){
        #print $1."\n";
        if(exists $tax{$1}){
    	    print OUT "$_\n";
        }
    }
}
close OUT;
close TA;

