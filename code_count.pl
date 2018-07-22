#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use feature 'say';
use feature 'switch';

use Getopt::Long;

my $check_path = undef; # Path to check line count
my $save_path = undef; # Path to save data
GetOptions(
    "path=s" => \$check_path, # compulsory
    "save=s" => \$save_path # optional
);

# Check if the path is specified
if ( !$check_path ) {
    say "Path argument must be specified.";
    exit;
}

open my $fh, '<', $check_path
    or die "Can't open file: $_";

my $line_count = 0;
while( my $line = <$fh> ) {
    $line =~ s/^\s+|\s+$//g; # Trim both ends

    if( substr($line, 0, 2) ne "//" && $line ne "" ) {
        $line_count++;
    }
}

close $fh or die "Can't close file: $_";

if ( $save_path ) {
    open my $fh, '>>', $save_path
        or die "Can't open file: $_";
    
    my $date_time = localtime();
    say $fh "$date_time";
    say $fh "$line_count\n";
}
say $line_count;