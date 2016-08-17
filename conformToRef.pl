#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  conformToRef.pl
#
#        USAGE:  ./conformToRef.pl  
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
#      CREATED:  14/08/16 19:07:06
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;


if (scalar @ARGV != 2){ print "\n$0 <chr> <target> \n\n"; exit;}
my $CHROMOSOME = $ARGV[0];

my $refFile = "/home/jody/thailand/human/imputation/beagle/db/chr$CHROMOSOME.1kg.phase3.v5a.vcf.gz";
my $targetFile = $ARGV[1];
my $newRefFile = "$CHROMOSOME.ref.vcf";
my $newTargetFile = "$CHROMOSOME.preImpute";
my $mapFile = "/home/jody/thailand/human/imputation/beagle/db/map/plink.chr$CHROMOSOME.GRCh37.map";

my %ref;

if( $refFile =~ /\.gz$/ ){
	open R, "zcat $refFile |" or die;
} else {
	open R, "$refFile" or die;
}
my %revRef;
while(<R>){
	chomp;
	if ($_ =~ /^#/){next;}
	my ($chr,$pos,$id,$ref,$alt) = (split /\s+/,$_)[0,1,2,3,4];
	$ref{$id}{'chr'} = $chr;
	$ref{$id}{'pos'} = $pos;
	$ref{$id}{'ref'} = $ref;
	$ref{$id}{'alt'} = $alt;
	$revRef{$chr}{$pos} = $id;
}
close R;


open LOG, ">$newTargetFile.log" or die;
my %chrPos;
my %ambiguous;
open OUT, ">$newTargetFile.vcf" or die;
if( $targetFile =~ /\.gz$/ ){
    open F, "zcat $targetFile |" or die;
} else {
    open F, "$targetFile" or die;
}
while(<F>){
	if ($_ =~ /^#/){print OUT "$_"; next;}
	chomp;
	my ($chr,$pos,$id,$ref,$alt,$t1,$t2,$t3,$t4,@calls) = split /\s+/,$_;
	if(exists($chrPos{$chr}{$pos})){next;}

	if (exists($ref{$id})){
		print "$chr\t$pos\t$id\t$ref\t$alt\t$ref{$id}{'ref'}\t$ref{$id}{'alt'}";
		if (($ref eq $ref{$id}{'alt'}) and ($alt eq $ref{$id}{'ref'})){
			my $calls = $_;
			$calls =~ s/$chr\t$pos\t$id\t$ref\t$alt\t$t1\t$t2\t$t3\t$t4\t//;
			
			print "\tFLIP\n";
			$calls =~ tr/01/10/;
			print OUT "$chr\t$pos\t$id\t$alt\t$ref\t$t1\t$t2\t$t3\t$t4\t$calls\n";
			$chrPos{$chr}{$pos} = 1;
		} elsif (($ref eq $ref{$id}{'ref'}) and ($alt eq $ref{$id}{'alt'})){
			print "\tOK\n";
			print OUT "$_\n";
            $chrPos{$chr}{$pos} = 1;
		} else {
				print "\tNA\n";
				$ambiguous{$id} = 1;
		}

	} else {
		my $exists;
		if (exists($revRef{$chr}{$pos})){
			$exists = $revRef{$chr}{$pos};
			print "$id is the same as $exists\n";
		} 
		if ($exists){
			print LOG "$exists\t$id\n";
			if (($ref eq $ref{$exists}{'alt'}) and ($alt eq $ref{$exists}{'ref'})){
				my $calls = $_;
        	    $calls =~ s/$chr\t$pos\t$id\t$ref\t$alt\t$t1\t$t2\t$t3\t$t4\t//;
       		    print "\tFLIP\n";
   	        	$calls =~ tr/01/10/;
            	print OUT "$chr\t$pos\t$exists\t$alt\t$ref\t$t1\t$t2\t$t3\t$t4\t$calls\n";
	            $chrPos{$chr}{$pos} = 1;

			} elsif (($ref eq $ref{$exists}{'ref'}) and ($alt eq $ref{$exists}{'alt'})){
	            print "\tOK\n";
				$_ =~ s/$id/$exists/;
	            print OUT "$_\n";
	            $chrPos{$chr}{$pos} = 1;

			} else {
				print "\tNA\n";
        	    $ambiguous{$id} = 1;
			}
		}
	}
}
close(F);


open N, ">$newRefFile" or die;

if( $refFile =~ /\.gz$/ ){
    open R, "zcat $refFile |" or die;
} else {
    open R, "$refFile" or die;
}


while(<R>){
    chomp;
    if ($_ =~ /^#/){print N "$_\n"; next;}
    my ($chr,$pos,$id,$ref,$alt) = (split /\s+/,$_)[0,1,2,3,4];
	if (!exists($ambiguous{$id})){
#		print "$id\n";
		print N "$_\n";
	} else {
#		print "????\n";
	}
}
close N;
close R;

`gzip -f $newTargetFile.vcf $newRefFile`;
`java8 -Xmx50g -jar ~/software/beagle.03May16.862.jar gt=$newTargetFile.vcf.gz ref=$newRefFile.gz map=$mapFile out=imputed.$newTargetFile nthreads=23`
