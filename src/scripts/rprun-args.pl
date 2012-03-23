#!/usr/bin/perl -w
# Prepare arg list for rprun.pl
use strict;

my $npart = 65536;
my $ndim = 25;
my $Z = 0.166;

for my $npart (4096, 8192, 16384, 32768, 65536, 92682, 131072, 185364, 262144) {
    for my $seed (10 .. 19) {
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}

for my $ndim (1, 2, 4, 8, 16, 25, 32, 64, 128, 256) {
    for my $seed (10 .. 19) {
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}

for my $Z (0.7071, 0.5000, 0.3536, 0.2500, 0.1768, 0.1250, 0.0884, 0.0625, 0.0442) {
    for my $seed (10 .. 19) {
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}
