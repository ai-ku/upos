#!/usr/bin/perl -w
use strict;

my $seed = 0;

for my $nsub qw(1 2 4 8 16 32 64 90 128 180 256) {
    for my $s (0 .. 9) {
	$seed++;
	print "$seed\t$nsub\n";
    }
}
