#! /usr/bin/perl -w

#Author: Fiona J. Whelan
#Date: May 23rd 2017; Feb 25th 2018

#Usage: CAA.pl union.txt index.txt
#CoSA (https://sourceforge.net/projects/concurrentsa/) must be installed and in the path
#SAcounter (http://omics.informatics.indiana.edu/mg/SA/) must be installed with SAcounter/Scripts/ in the path

#Check usage
if (($#ARGV+1) < 2) {
	print "\nError: give me the parameters I need!\n";
	print "Usage: CAA.pl union.txt index.txt\n";
	exit;
}

#Save var input
$union = $ARGV[0];
$index = $ARGV[1];

#Translate plate names to otu table column positions
open(UNION, "<", $union) or die "$!";
@union_list = ();
foreach $line (<UNION>) {
	chomp($line);
	@lines = split /\s/, $line;
	push @union_list, [@lines];
}
close UNION;

#Pull in CAA files for each union_list item
open(INDEX, "<", $index) or die "$!";
%index = ();
foreach $line (<INDEX>) {
	chomp($line);
	@lines = split /\t/, $line;
	$index{$lines[0]} = $lines[1];
}
#Union x
for $x ( 0 .. $#union_list ) {
	$FLAGa = 0;
	for $y (0 .. $#{ $union_list[$x] } ) {
		#Check to see if we're the first flag through
		if ($FLAGa eq "0") {
			$FLAGa_indy = $index{$union_list[$x][$y]};
			$FLAGa = $union_list[$x][$y];
			$xy1 = $x.$y;
			`touch union_readHeaders`;
			`touch union_readHeaders.sort`;
		} else {
			#Run SACounter on FLAGa and current plate
			$xy = $x.$y;
			$indy = $index{$union_list[$x][$y]};
			print "CoSA -o $xy1 -p $xy -a $FLAGa_indy -b $indy -k 20 -t 12 -m 50 --kmc --verbose\n";
			system("CoSA -o $xy1 -p $xy -a $FLAGa_indy -b $indy -k 20 -t 12 -m 50 --kmc --verbose");
			print "grep -e \"\@HWI\" -e \"\@SNL\" $xy1*.fastq > $xy1.unique\n";
			`grep -e \"\@HWI\" -e \"\@SNL\" $xy1*.fastq > $xy1.unique`;
			print "grep -e \"\@HWI\" -e \"\@SNL\" $FLAGa > $xy1.all\n";
			`grep -e \"\@HWI\" -e \"\@SNL\" $FLAGa > $xy1.all`;
			print "sort $xy1.all > $xy1.sort.all\n";
			`sort $xy1.all > $xy1.sort.all`;
			print "sort $xy1.unique > $xy1.sort.unique\n";
			`sort $xy1.unique > $xy1.sort.unique`;
			print "comm -23 $xy1.sort.all $xy1.sort.unique > $xy1.shared.tmp\n";
			`comm -23 $xy1.sort.all $xy1.sort.unique > $xy1.shared.tmp`;
			print "comm -23 $xy1.shared.tmp union_readHeaders.sort > $xy1.shared\n";
			`comm -23 $xy1.shared.tmp union_readHeaders.sort > $xy1.shared`;
			print "header2seq.py -header $xy1.shared -fq $FLAGa -out $xy1.shared\n";
			`header2seq.py -header $xy1.shared -fq $FLAGa -out $xy1.shared`;
			print "remove $xy1 tmp files\n";
			`rm $xy1.unique`;
                        `rm $xy1.all`;
			`rm $xy1.sort.unique`;
			`rm $xy1.sort.all`;
			`rm $xy1.shared.tmp`;
			`rm $xy1.shared`;
			print "grep -e \"\@HWI\" -e \"\@SNL\" $xy*.fastq > $xy.unique\n";
			`grep -e \"\@HWI\" -e \"\@SNL\" $xy*.fastq > $xy.unique`;
			print "grep -e \"\@HWI\" -e \"\@SNL\" $union_list[$x][$y] > $xy.all\n";
			`grep -e \"\@HWI\" -e \"\@SNL\" $union_list[$x][$y] > $xy.all`;
			print "sort $xy.all > $xy.sort.all\n";
			`sort $xy.all > $xy.sort.all`;
			print "sort $xy.unique > $xy.sort.unique\n";
			`sort $xy.unique > $xy.sort.unique`;
			print "comm -23 $xy.sort.all $xy.sort.unique > $xy.shared.tmp\n";
			`comm -23 $xy.sort.all $xy.sort.unique > $xy.shared.tmp`;
			print "comm -23 $xy.shared.tmp union_readHeaders.sort > $xy.shared\n";
			`comm -23 $xy.shared.tmp union_readHeaders.sort > $xy.shared`;
			print "header2seq.py -header $xy.shared -fq $union_list[$x][$y] -out $xy.shared\n";
			`header2seq.py -header $xy.shared -fq $union_list[$x][$y] -out $xy.shared`;
			print "remove $xy tmp files\n";
			`rm $xy.unique`;
			`rm $xy.all`;
			`rm $xy.sort.unique`;
			`rm $xy.sort.all`;
			`rm $xy.shared.tmp`;
			`rm $xy.shared`;
			print "cat $xy1.shared.fq $xy.shared.fq > $xy1.$xy.shared.fq\n";
			`cat $xy1.shared.fq $xy.shared.fq > $xy1.$xy.shared.fq`;
			print "rm $xy1.shared.fq\n$xy.shared.fq\n";
			`rm $xy1.shared.fq`; `rm $xy.shared.fq\n`;
			$FLAGa = "$xy1.$xy.shared.fq";
			#Make FLAGa index file
			`echo '$FLAGa	flaga' > flaga.index`;
			$index{$FLAGa} = "FLAGa";
			$xy1 = $xy1.".".$xy;
			print "FLAGa $FLAGa xy1 $xy1 \n";
		}
	}
	`mv $FLAGa inter_$FLAGa`;
	print "grep -e \"\@HWI\" -e \"\@SNL\" inter_$FLAGa >> union_readHeaders\n";
	`grep -e \"\@HWI\" -e \"\@SNL\" inter_$FLAGa >> union_readHeaders`;
	print "sort union_readHeaders > union_readHeaders.sort\n";
	`sort union_readHeaders > union_readHeaders.sort`;
}
#Deal with leftover reads
open(INDEX, "<", $index) or die "$!";
$cnt = 0;
foreach $line (<INDEX>) {
        chomp($line);
        @lines = split /\t/, $line;
        print "index: $lines[0]\n";
	print "grep -e \"\@HWI\" -e \"\@SNL\" $lines[0] > inter_plate$cnt\n";
	`grep -e \"\@HWI\" -e \"\@SNL\" $lines[0] > inter_plate$cnt`;
	print "sort inter_plate$cnt > inter_plate$cnt.sort\n";
	`sort inter_plate$cnt > inter_plate$cnt.sort`;
	print "comm -23 inter_plate$cnt.sort union_readHeaders.sort > inter_plate$cnt.unique\n";
	`comm -23 inter_plate$cnt.sort union_readHeaders.sort > inter_plate$cnt.unique`;
	print "header2seq.py -header inter_plate$cnt.unique -fq $lines[0] -out inter_plate$cnt.unique.fq\n";
	`header2seq.py -header inter_plate$cnt.unique -fq $lines[0] -out inter_plate$cnt.unique`;
	print "remove inter_plate$cnt tmp files\n";
	`rm inter_plate$cnt`;
	`rm inter_plate$cnt.sort`;
	`rm inter_plate$cnt.unique`;
	$cnt++;
}
