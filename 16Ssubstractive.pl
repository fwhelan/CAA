#! /usr/bin/perl -w
use POSIX;
use Math::Combinatorics;

#Author: Fiona J. Whelan
#Date: May 23rd 2017

#Usage: 16Ssubstractive.pl otu_table plate_list

#Check usage
if (($#ARGV+1) < 2) {
	print "\nError: give me the parameters I need!\n";
	print "Usage: 16Ssubstractive.pl otu_table plate_list\n";
	exit;
}

#Save var input
$otu_table = $ARGV[0];
$plate_list = $ARGV[1];
$relAbundCutoff = 0.01;

#Translate plate names to otu table column positions
open (LIST, "<", $plate_list) or die "$!";
@plates = ();
foreach $line (<LIST>) {
	chomp($line);
	push @plates, "$line";
}
close LIST;

open (TABLE, "<", $otu_table) or die "$!";
$firstline = <TABLE>;
close TABLE;
@first = split /\t/, $firstline;
@platePos = ();
$count = 0;
%plate_pos = ();
foreach $i (@first) {
	if ( grep(/$i/, @plates)) {
		push @platePos, $count;
		$plate_pos{$count} = $i;
	}
	$count++;
}

#Union x
my @c;
for ($a = $#platePos+1; $a >= 1; $a--) {
	push @c, combine($a+1,@platePos);
}

for $c_ele ( 0 .. $#c ) {
	open (TABLE, "<", $otu_table) or die "$!";
	#skip first line
	<TABLE>;
	foreach $woline (<TABLE>) {
		@line = split /\t/, $woline;
		$FLAG = 0;
		for $element (0 .. $#{ $c[$c_ele] } ) {
			if ($line[$c[$c_ele][$element]] <= $relAbundCutoff) {
				$FLAG = 1;
				last;
			}
		}
		if ($FLAG == 0) {
			foreach $e (@{ $c[$c_ele] }) { print $plate_pos{$e}." ";} print "\n";
			last;
		}
	}
}
