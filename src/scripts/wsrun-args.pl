#!/usr/bin/perl -w
use strict;

for my $nsub qw(1 2 4 8 16 32 64 90 128 180 256) {
    for my $seed (10 .. 19) {
	print "$seed\t$nsub\n";
    }
}
