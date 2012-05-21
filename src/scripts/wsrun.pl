#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: wsrun.pl seed nsub
Prints out inputs, output, number of seconds
};

my $seed = shift or die $usage;
my $nsub = shift or die $usage;

my $ndim = 25;
my $Z = 0.166;
my $ntest = 1173766;
my $sc_restart = 1;
my $sc_niter = 1+int(100/$nsub);
my $km_restart = 128;
my $K = 45;
my $test = 'wsj.words.gz';
my $gold = 'wsj.pos.gz';

my $tmp = tempdir("wsrun-XXXX", CLEANUP => 1);
my $sc_err = "$tmp/scode";
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $input = qq{perl -le 'print "wsj.sub.gz" for 1..$nsub' | xargs zcat | grep -v '^</s>'};
my $wordsub = "wordsub -s $seed";
my $scode = "scode -r $sc_restart -i $sc_niter -d $ndim -z $Z -s $seed";
my $scode2kmeans = "perl -ne 'print if s/^0://'";
my $kmeans = "wkmeans -k $K -r $km_restart -l -w -s $seed";
my $kmeans2eval = "wkmeans2eval.pl -t $test";
my $score = "eval.pl -m -v -g $gold";
my $cmd = "$input | $wordsub | $scode 2> $sc_err | $scode2kmeans | $kmeans 2> $km_err | $kmeans2eval | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @sc = split(' ', `cat $sc_err`);
my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $nsub, @sc, @km, @ev, $tm)."\n";
