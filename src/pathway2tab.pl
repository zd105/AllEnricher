#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use PerlIO::gzip;
my %name;
my ($pathwaysummary, $dir, $n) = @ARGV;
open IN, "$pathwaysummary" or die $!;
while(<IN>){
	chomp;
	next if /^#/;
	my @arr = split(/\t+/,$_);
	my $id = $arr[2];
	my $n = "$n" . "$arr[2]";
	# my $n = "$arr[0]|$arr[1]|$arr[3]";
	# $n=~s/[,\(\):;\/\-]//g;
	# $n=~s/\s+/_/g;
	$name{$id} = $n;
}
close IN;

my %tab;
my %gene;
foreach my $id (keys %name){
        #print "$n$id\n"; 
	open IN,"$dir/$n$id.glist.tab" or die $!;
	while(<IN>){
		chomp;
		my @arr = split;
		$gene{$arr[1]} = 1;
		$tab{$id}{$arr[1]} = 1;
	}
	close IN;
}

print "Gene";
print "\t$name{$_}" foreach sort keys %name;
print "\n";
foreach my $g (sort keys %gene){
	my @out = ();
	push @out, $g;
	foreach my $id (sort keys %name){
		if(exists $tab{$id}{$g}){
			push @out, 1;
		}else{
			push @out, 0;
		}
	}
	print join("\t", @out) . "\n";
}
