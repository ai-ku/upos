#!/usr/bin/perl -w
use strict;

my $usage = qq{eval.pl [-m -v] -g <gold> < input
Calculates many-to-one and v-measure evaluations.
-m prints many-to-one (default)
-v prints v-measure (homogeneity, completeness, v-measure)
-g file with gold answers
};

use Getopt::Std;
our($opt_m, $opt_v, $opt_g);
getopts('mvg:');
die $usage unless $opt_g;
$opt_g = "zcat $opt_g |" if $opt_g =~ /\.gz$/;

my (%cnt);
open(GOLD, $opt_g) or die $!;
while(<>) {
    my $g = <GOLD>;
    $cnt{$_}{$g}++;
}
close(GOLD);

if ($opt_m and $opt_v) {
    print STDERR join("\t", m2o(), vm())."\n";
} elsif ($opt_v) {
    print STDERR join("\t", vm())."\n";
} else {
    print STDERR m2o()."\n";
}

sub m2o {
    my $total = 0;
    my $correct = 0;

    for my $l (keys %cnt) {
	my $max;
	for my $p (keys %{$cnt{$l}}) {
	    my $n = $cnt{$l}{$p};
	    if (not defined $max or $n > $max) {
		$max = $n;
	    }
	    $total += $n;
	}
	$correct += $max;
    }

    return $correct / $total;
}

sub vm {
    my (%acnt, %gcnt, $N);
    for my $a (keys %cnt) {
	for my $g (keys %{$cnt{$a}}) {
	    my $n = $cnt{$a}{$g};
	    $acnt{$a} += $n;
	    $gcnt{$g} += $n;
	    $N += $n;
	}
    }
    my $log2 = log(2);
    my $H_a;
    for my $a (keys %acnt) {
	my $p = $acnt{$a} / $N;
	$H_a -= $p * log($p);
    }
    my $H_g;
    for my $g (keys %gcnt) {
	my $p = $gcnt{$g} / $N;
	$H_g -= $p * log($p);
    }
    my ($H_ag, $H_ga);
    for my $a (keys %cnt) {
	my $na = $acnt{$a};
	for my $g (keys %{$cnt{$a}}) {
	    my $ng = $gcnt{$g};
	    my $nag = $cnt{$a}{$g};
	    my $p = $nag / $N;
	    my $pag = $nag / $ng;
	    my $pga = $nag / $na;
	    $H_ag -= $p * log($pag);
	    $H_ga -= $p * log($pga);
	}
    }    
    my $h = 1 - $H_ga / $H_g;
    my $c = 1 - $H_ag / $H_a;
    my $v = (2*$h*$c / ($h+$c));
    return ($h, $c, $v);
}
