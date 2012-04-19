#!/usr/bin/perl -w
use strict;

my $seed = 1;
my $i = 35;
for (my $j=0; $j < 10; $j++) {
    print $seed." ".$i."\n";
    $seed++;
}
