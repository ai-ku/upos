#!/usr/bin/perl -w
use strict;
use Getopt::Std;

my $usage = qq{feature-table.pl -w wsj.words.gz -s wsj.segmentation.gz
};

our($opt_w, $opt_s);
getopts('w:s:');
die $usage unless ($opt_w and $opt_s);
$opt_w = "zcat $opt_w |" if $opt_w =~ /\.gz$/;
$opt_s = "zcat $opt_s |" if $opt_s =~ /\.gz$/;

my %feat;
open(FP, $opt_w) or die $!;
my $prev = ".";
while (<FP>) {
  chomp;
  $feat{$_}{"/IC/"}++ if ($_ =~ /^[A-Z]/ and $prev !~ /^[.`'?!:;]+$/ and $prev !~ /^-[LR][RC]B-$/);
  $feat{$_}{"/CD/"}++ if $_ =~ /^[\-.]?(,?[0-9]+)+(.[0-9]+)?/;
  $feat{$_}{"/CH/"}++ if ($_ =~ /([^-]+-)+[^-]+/ and $_ !~ /([A-Z].*-)+[A-Z].*/ and $_ !~ /([0-9]+-)+[0-9]+/ and $_ !~ /([A-Za-z]+-)+[0-9]+/);
  $feat{$_}{"/IA/"}++ if $_ =~ /^'[A-Za-z0-9]+/;
  $prev = $_;
}
close(FP);

open(FP, $opt_s) or die $!;
while (<FP>) {
  next if $_ =~ /^#/;
  chomp;
  $_ =~ s/^[0-9]+ //g;
  $_ =~ s/\/PRE//g;
  $_ =~ s/\/STM//g;
  $_ =~ s/(\S+)\/SUF/$1 \/SUF:$1\//g;
  my @a = split;
  my $w = "";
  my @b;
  foreach(@a) {
    if ($_ ne "+") {
      if ($_ =~ /\/SUF:(\S+)\//) {
	push(@b, $_);
      } else {
	$w = $w.$_;
      }
    }
  }
  $feat{$w}{$_}++ foreach(@b);
}

while(my($word, $f) = each(%feat)) {
  $word =~ s/\|PSN\|/#/g;
  $word =~ s/\|AST\|/\\*/g;
  $word =~ s/\|SLH\|/\\\//g;
  $word =~ s/\|PLS\|/+/g;
  print $word."\t".join("\t", keys(%$f))."\n";
}
