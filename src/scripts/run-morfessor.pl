#!/usr/bin/perl -w
use strict;
use Getopt::Std;

my $usage = qq{run-mofessor.pl -m morfessor_path -p PPLTHRESH < vocablary_file
};

our($opt_m, $opt_p);
getopts('m:p:');
die $usage unless ($opt_m and $opt_p);
$opt_m =~ s/\/$//g;

my %words;
while (<>) {
  $_ =~ s/#/|PSN|/g;
  $_ =~ s/\\\*/|AST|/g;
  $_ =~ s/\\\//|SLH|/g;
  $_ =~ s/\+/|PLS|/g;
  $words{$_}++;
}


open(FP, "| gzip > $opt_m/train/wsj.words.clean.gz") or die $!;
while (my($word, $c) = each(%words)) {
  print FP $c." ".$word;
}
close(FP);

system("cd $opt_m/train; sed 's/^GZIPPEDINPUTDATA = mydata.gz/GZIPPEDINPUTDATA = wsj.words.clean.gz/g' Makefile | sed 's/^PPLTHRESH = 10/PPLTHRESH = $opt_p/g' > tmp; mv tmp Makefile; make");

open(FP, "zcat $opt_m/train/segmentation.final.gz |") or die $!;
while (<FP>) {
  print $_;
}
close(FP);

`cd $opt_m/train; make realclean`;
