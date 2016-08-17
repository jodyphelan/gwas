#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  compareFam.pl
#
#        USAGE:  ./compareFam.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Jody Phelan (mn), jody.phelan@lshtm.ac.uk
#      COMPANY:  LSHTM
#      VERSION:  1.0
#      CREATED:  05/25/2016 11:29:20 AM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


my %l1;
my %l2;
open F, "$ARGV[0].fam" or die;
while(<F>){
	chomp;
	my $id = (split /\s+/,$_)[1];
	$l1{$id} = 1;
}
close(F);

open F, "$ARGV[1].fam" or die;
while(<F>){
	chomp;
	my $id = (split /\s+/,$_)[1];
	$l2{$id} = 1;
}
close(F);

open OUT, ">samples.intersection" or die;
open OUT2, ">samples.missing" or die;

for (keys %l1){
	if (exists($l2{$_})){
		print OUT "0 $_\n";
	} else {
		print OUT2 "$ARGV[0]\t$_\n";
	}
}

for (keys %l2){
	if (!exists($l1{$_})){
		print OUT2 "$ARGV[1]\t$_\n";
	}
}
close(OUT);
close(OUT2);

my %s1;
my %s2;

open F, "$ARGV[0].bim" or die;
while(<F>){
    chomp;
    my $id = (split /\s+/,$_)[1];
    $s1{$id} = 1;
}
close(F);

open F, "$ARGV[1].bim" or die;
while(<F>){
    chomp;
    my $id = (split /\s+/,$_)[1];
    $s2{$id} = 1;
}
close(F);

open OUT, ">$ARGV[0].extract" or die;
open OUT2, ">$ARGV[1].extract" or die;

for (keys %s1){
    if (exists($s2{$_})){
        print "$_\n";
    } else {
        print OUT "$_\n";
    }
}

for (keys %s2){
    if (!exists($s1{$_})){
        print OUT2 "$_\n";
    }
}
close(OUT);
close(OUT2);


