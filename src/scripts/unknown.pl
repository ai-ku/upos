#!/usr/bin/perl -w
# prints the unknows percentage of a given vocabulary and file

use strict;

my $usage = qq{Usage:./unknown.pl voc input
Prints out unknown percentage of input
};

die $usage if @ARGV < 2;
open(V,"gzip -dc $ARGV[0] |");
open(F,"gzip -dc $ARGV[1] |");
my %voc;
while(<V>){
    chomp;
    my @l = split;
    $voc{$l[0]}++;
}
my ($u,$a) = (0,0);
while(<F>){
    chomp;
    my @line = split;
    foreach(@line){
	$u++ unless(defined $voc{$_});
	$a++;
    }
}

print $u/$a."\n";
close(V);
close(F);
