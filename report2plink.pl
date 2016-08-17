#! /usr/bin/perl

use strict;
use warnings;


if (scalar @ARGV != 3){ print "\n$0 <report> <out> <manifest>  \n\n"; exit;}

my $x=0;
my @samples;
my %sampleStrings;
open F, $ARGV[0] or die;
open INFO, "$ARGV[2]" or die;
my %info;
while(<INFO>){
	chomp;
	my @a = split /,/,$_;
	if ($#a != 18){next;}
	my ($rs,$tb,$alleles,$chr,$pos,$seq) = @a[1,2,3,9,10,17];
	$info{$rs}{'info'} = "$chr $rs 0 $pos";
	$alleles =~ /(\w+)\/(\w+)/;
	my ($all1,$all2) = ($1,$2);
	
	if (!$all1){next;}
	$seq =~ /\w+\[([\w\-]+)\/([\w\-]+)\]/;
	my ($a1,$a2) = ($1,$2);
	
	if ($alleles =~ m/D\/I/){
			$info{$rs}{$all1} = $a1;
			$info{$rs}{$all2} = $a2;
#		print "$rs $all1=$a1 $all2=$a2\n";
	} elsif ($alleles =~ m/I\/D/){
		$info{$rs}{$all1} = $a2;
		$info{$rs}{$all2} = $a1;
#		print "$rs $all1=$a2 $all2=$a1\n";
	} else {
		if ($tb eq "TOP"){
			$info{$rs}{'A'} = $all1;
			$info{$rs}{'B'} = $all2;
#			print "$rs TOP A-$all1 B-$all2\n";
		} elsif ($tb eq "BOT"){
			$info{$rs}{'A'} = $all2;
			$info{$rs}{'B'} = $all1;
#			print "$rs BOT A-$all2 B-$all1\n";
		} else {
			die;
		}
	}
}
close(INFO);


open PED, ">$ARGV[1].tped" or die;
open MAP, ">$ARGV[1].tfam" or die;
open LOG, ">$ARGV[1].log" or die;
while(<F>){
	if ($_ =~ m/Data/){
		
		$x++;
		next;
	}
	if ($x == 1){	
		$x++;
		chomp;
		my @a = split /\t/,$_;
		shift @a;	
		foreach my $f (@a){
#			print "$f\n";
			push @samples, $f;
			print MAP "0\t$f\t0\t0\t0\t-9\n";
		}
		
		next;
	} elsif ($x > 1) {
		chomp;
		my @a = split /\t/,$_;
		my $rs = $a[0];
		my $line;
#		print "$info{$rs}{'info'}\n";
		$line .= $info{$rs}{'info'};
		for (my $i=1; $i<=$#a; $i++){
			my $gt = (split /\|/,$a[$i])[0];	
			if ($gt =~ /\-\-/){
				$line .= " 0 0";
				next;
			}
			my @geno = split //,$gt;
			if (!exists($info{$rs})){print LOG "$rs\n";}
			if ($gt =~ m/[DI]/){
				$line .= " $info{$rs}{$geno[0]} $info{$rs}{$geno[1]}";
			} else {
				$line .= " $geno[0] $geno[1]";
			}
		}
		print PED "$line\n";
		print "Processing line $x\n";
		$x++;
	}
}

