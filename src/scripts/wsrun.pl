#!/usr/bin/perl -w
use strict;

my $usage = q{Usage: wsrun.pl seed nsub
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $nsub = shift or die $usage;

my $ndim = 25;
my $Z = 0.166;
my $ntest = 1173766;
my $sc_restart = 1;
my $sc_niter = int(300/$nsub);
$sc_niter = 50 if $sc_niter > 50;
my $km_init = 'kpp';
my $km_restart = 10;
my $km_k = 45;
my $test = 'data/wsj.test1M.tok.gz';
my $gold = 'wsj.pos.gz';

my $input = 'zcat wsj.sub.gz';
my $wordsub = "wordsub.pl -n $nsub -s $seed";
my $scode = "scode -r $sc_restart -i $sc_niter -d $ndim -z $Z -s $seed";
my $scode2kmeans = "scode2kmeans.pl -t $test";
my $kmeans = "kmeans --init $km_init --k=$km_k --restarts=$km_restart --seed=$seed";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $wordsub | $scode | $scode2kmeans | $kmeans | $score |";

my $t = time;
open(CMD, $cmd) or die $!;
my $result = <CMD>;
close(CMD);
$t = time - $t;
chomp($result);
print join("\t", $seed, $nsub, $result, $t)."\n";
