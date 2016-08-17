#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  combineEff.pl
#
#        USAGE:  ./combineEff.pl  
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
#      CREATED:  06/14/2016 02:28:17 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

my %chip;
open F, $ARGV[2] or die;
while(<F>){
	chomp;
	$chip{$_} = 1;
}
close(F);

my %genes;
open F, $ARGV[0] or die;
while(<F>){
	chomp;
	my $id = (split /\s+/,$_)[2];
	$genes{$id} = $_;
}
close(F);

my $x = 0;
open F, $ARGV[1] or die;
while(<F>){
	chomp;
	if ($x<1){
		$x++;
		print "genotyped\tchr\tpos\tid\tallele1\tallale2\ttype\tgene";
		$_ =~ s/\S+\s\S+\s\S+//;
		print "$_\n";
		next;
	}
	my $id  = (split /\s+/,$_)[2];
	$_ =~ s/\S+\s\S+\s\S+//;
	if (exists($chip{$id})){print "1\t";} else {print "0\t";}
	print "$genes{$id}$_\n"
}
close(F);
