#!/usr/bin/perl -w
# Prepare arg list for rprun.pl
use strict;

my $npart = 65536;
my $ndim = 25;
my $Z = 0.166;
my $seed = 0;

for my $npart (4096, 8192, 16384, 32768, 65536, 92682, 131072, 185364, 262144) {
    for my $s (0 .. 9) {
	$seed++;
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}

for my $ndim (2, 3, 4, 6, 8, 11, 16, 25, 32, 45, 64, 90, 128, 180, 256) {
    for my $s (0 .. 9) {
	$seed++;
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}

for my $Z (0.7071, 0.5000, 0.3536, 0.2500, 0.1768, 0.1250, 0.0884, 0.0625, 0.0442) {
    for my $s (0 .. 9) {
	$seed++;
	print "$seed\t$npart\t$ndim\t$Z\n";
    }
}
