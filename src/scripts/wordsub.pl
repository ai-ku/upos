#!/usr/bin/perl -w
# Read a substitute file and print word and a random substitute on each line
use strict;
use Getopt::Std;
our($opt_n) = (1);
getopt('n');

my @words;
open(FP, "wsj.test1M.gold");
while(<FP>) {
    next unless /\S/;
    my ($w, $p) = split;
    # $w =~ tr/A-Z/a-z/;
    push @words, $w;
}
close(FP);

my $index = 0;
while(<>) {			# wsj.test1M.lc.500.n0p09.subf
    my @a = split;
    my $w = $a[0];
    next if $w eq '</s>';
    # $w =~ tr/A-Z/a-z/;
    if ($w ne '<unk>' and $w ne $words[$index]) {
	die "Bad word: [$w] != [$words[$index]]";
    }
    $w = $words[$index++];
    my $sum = 0;
    my @sub;
    for (my $i = 1; $i < $#a; $i += 2) {
	my $p = 10 ** $a[$i+1];
	$sum += $p;
	for (my $n = 0; $n < $opt_n; $n++) {
	    if (rand($sum) < $p) {
		$sub[$n] = $a[$i];
	    }
	}
    }
    for (my $n = 0; $n < $opt_n; $n++) {
	print "$w\t$sub[$n]\n";
    }
}
