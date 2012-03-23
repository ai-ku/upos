#!/usr/bin/perl -w
use strict;

my $usage = q{Usage: rprun.pl seed npart ndim Z
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $npart = shift or die $usage;
my $ndim = shift or die $usage;
my $Z = shift or die $usage;

my $ntest = 1173766;
my $sc_restart = 1;
my $sc_niter = 50;
my $km_init = 'kpp';
my $km_restart = 10;
my $km_k = 45;
my $test = 'data/wsj.test1M.tok.gz';
my $gold = 'wsj.pos.gz';

my $input = 'zcat wsj.knn.gz';
my $rpart = "rpart.pl -n $ntest -p $npart -s $seed";
my $rpart2scode = "join.pl wsj.words.gz -";
my $scode = "scode -r $sc_restart -i $sc_niter -d $ndim -z $Z -s $seed";
my $scode2kmeans = "scode2kmeans.pl -t $test";
my $kmeans = "kmeans --init $km_init --k=$km_k --restarts=$km_restart --seed=$seed";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $rpart | $rpart2scode | $scode | $scode2kmeans | $kmeans | $score |";

my $t = time;
open(CMD, $cmd) or die $!;
my $result = <CMD>;
close(CMD);
$t = time - $t;
chomp($result);
print join("\t", $seed, $npart, $ndim, $Z, $result, $t)."\n";
