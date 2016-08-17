#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  parseSNPeff.pl
#
#        USAGE:  ./parseSNPeff.pl  
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
#      CREATED:  06/13/2016 06:00:41 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;



open F, $ARGV[0] or die;
while(<F>){
	chomp;
	if ($_ =~ /^#/){next;}	
	my ($chr,$pos,$id,$ref,$alt,$temp) = (split /\s+/,$_)[0,1,2,3,4,7];
	my $field;
	my @temp2 = split /;/,$temp;
	for (my $i=0; $i<=$#temp2; $i++){
		if ($temp2[$i] =~ m/^ANN/){
			$field = $i
		}
	}
	if (!$field){print "$chr\t$pos\t$id\t$ref\t$alt\tNA\tNA\n";next;}

	my $temp2 = (split /;/,$temp)[$field];
#	print "$id\t$temp\n";
#	print "$id\t$temp2\n";

	my ($type,$gene) = (split /\|/,$temp2)[1,3];
	if (!$gene){$gene = "NA";}
	print "$chr\t$pos\t$id\t$ref\t$alt\t$type\t$gene\n";
}
close(F);
