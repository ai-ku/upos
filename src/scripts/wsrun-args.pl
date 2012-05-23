#!/usr/bin/perl -w
use strict;

my $seed = 0;

for my $nsub qw(1 2 3 4 6 8 10 12 16 25 32 45 64 90) {
    for my $s (0 .. 9) {
	$seed++;
	print "$seed\t$nsub\n";
    }
}
