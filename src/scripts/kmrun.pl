#!/usr/bin/perl -w
use strict;
use File::Temp qw/tempdir/;

my $usage = q{Usage: kmrun.pl seed file weights nstart
Runs clustering experiment with given settings.
Prints out inputs, outputs, number of seconds.
};

my $seed = shift;
my $file = shift;
my $weights = shift;
my $nstart = shift;
die $usage unless (defined $seed and defined $file and defined $weights and defined $nstart);

my $tmp = tempdir("kmrun-XXXX", CLEANUP => 1);
my $km_err = "$tmp/kmeans";
my $ev_err = "$tmp/eval";

my $ntest = 1173766;
my $K = 45;
my $word = 'wsj.words.gz';
my $gold = 'wsj.pos.gz';

my ($input, $kmeans, $score);
if ($weights) {
    $input = "zcat $file | grep ^0: | cut -f2-";
    $kmeans = "wkmeans -k $K -r $nstart -s $seed -w";
    $score = "wkmeans2eval.pl -i $file -t $word | eval.pl -m -v -g $gold";
} else {
    $input = "zcat $file | scode2kmeans.pl -t $word";
    $kmeans = "wkmeans -k $K -r $nstart -s $seed";
    $score = "eval.pl -m -v -g $gold";
}

my $cmd = "$input | $kmeans 2> $km_err | $score 2> $ev_err";

my $tm = time;
system($cmd);
$tm = time - $tm;

my @km = split(' ', `cat $km_err`);
my @ev = split(' ', `cat $ev_err`);

print join("\t", $seed, $file, $weights, $nstart, @km, @ev, $tm)."\n";
