#!/usr/bin/perl -w
use strict;
use IO::All;

sub myopen {
    my ($path) = @_;
    $path = "zcat $path |" if $path =~ /gz$/;
    return io($path);
}

my @fp;
push @fp, myopen($_) for @ARGV;

while(1) {
    my $eof = 0;
    my $col = 0;
    for my $f (@fp) {
	my $line = $f->getline;
	if (not defined $line) {
	    $eof = 1;
	    last;
	}
	chomp($line);
	print "\t" if $col++;
	print "$line";
    }
    print "\n";
    last if $eof;
}

$_->close for @fp;
