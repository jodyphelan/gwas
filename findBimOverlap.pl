#!/usr/bin/perl 
use strict;
use warnings;

my %b1;
my %b2;
open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my ($chr,$id,$map,$pos,$a1,$a2) = split /\s+/,$_;
	$b1{$id} = 1;
}
close(F);


open F, $ARGV[1] or die;
while(<F>){
	chomp;
	my ($chr,$id,$map,$pos,$a1,$a2) = split /\s+/,$_;
    $b2{$id} = 1
}
close(F);


foreach my $id ( keys %b1 ) {
	if (exists($b2{$id})){
		print "$id\n";
	}
}
