#!/usr/bin/perl

my @data;
my $col = 0;

for my $file (@ARGV) {
    open(FP, $file) || die $!;
    my $row = 0;
    while(<FP>) {
	s/\s+$//;
	$data[$row++][$col] = $_;
    }
    close(FP);
    $col++;
}

for my $row (@data) {
    print join("\t", @$row) . "\n";
}
