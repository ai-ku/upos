#!/usr/bin/perl -w
use strict;
# 14 secs per iteration without weights
# .8 secs per iteration with weights

my $seed = 0;

for my $file ('rpart.scode.gz', 'wordsub.scode.gz') {
    for my $nstart (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024) {
	for my $s (0 .. 9) {
	    $seed++; print "$seed $file 1 $nstart\n";
	    if ($nstart <= 64) {
		$seed++; print "$seed $file 0 $nstart\n";
	    }
	}
    }
}

