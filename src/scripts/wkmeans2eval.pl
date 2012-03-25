#!/usr/bin/perl -w
use strict;

my $usage = qq{wkmeans2eval.pl -i scode.out -t test.tok < kmeans.out > eval.in
Construct input for eval from input and output of weighted kmeans
-i scode output kmeans input file
-t test file
};

use Getopt::Std;
our($opt_i, $opt_t);
getopt('it');
die $usage unless $opt_i and $opt_t;
$opt_i = "zcat $opt_i |" if $opt_i =~ /\.gz$/;
$opt_t = "zcat $opt_t |" if $opt_t =~ /\.gz$/;

my @kclus = <>;
my $iclus = 0;

my %clus;
open(FP, $opt_i) or die $!;
while(<FP>) {
    $clus{$1} = $kclus[$iclus++] if /^0:(\S+)/;
}
close(FP);

die "$iclus!=".scalar(@kclus) unless $iclus == scalar(@kclus);

open(FP, $opt_t) or die $!;
while(<FP>) {
    for my $w (split) {
	print $clus{$w};
    }
}
close(FP);
