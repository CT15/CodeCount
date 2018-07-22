#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use feature 'say';
use feature 'switch';

use Getopt::Long;
use File::Basename;

#
# append_to_file()
#
# Arguments:
#   $file_path: string Path of a file to be written to
#   $to_write: Information to be written to the file
#
# Returns: void
#
# Appends the specified file with the given argument.
#
sub append_to_file {
    my ( $file_path, $to_write ) = @_ ;

    open my $fh, '>>', $file_path || die "Can't open file: $!";
    say $fh $to_write;
    close $fh || die "Can't close file: $!";
}

my $check_path; # Path to file(s) to be checked
my $save_path;  # Path to file where data is saved
GetOptions(
    "path=s" => \$check_path,   # compulsory
    "save=s" => \$save_path     # optional
);

# Check if the path is specified
if ( !$check_path ) {
    say "Path argument must be specified.";
    exit;
}

# Append date_time to target file if specified
if ( $save_path ) { 
    my $date_time = localtime();
    append_to_file( $save_path, "\n$date_time" ); 
}

my @paths;
if ( -d $check_path ) {
    # Get all files at specified directory
    @paths = glob( "$check_path" . "/*");
} else {    # A single file
    # There is only one path, which is $check_path
    @paths = $check_path;
}

#
# process_files()
#
# Arguments:
#   $files: array of string Paths to files to be processed
#
# Returns: void
#
# Counts the lines of code in all the files as specified by paths.
# If any path is a directory, counts the lines of code in all the
# files in the directory.
#
sub process_files {
    my $paths_ref = shift( @_ );
    my @paths = @$paths_ref;

    foreach my $path ( @paths ) {

        if( -d $path ) {
            my $dir_name = basename( $path );

            if( $save_path ) { append_to_file( $save_path, "=== $dir_name START ===" ); }
            say "=== $dir_name START ===";

            my @paths_in_dir = glob( "$path" . "/*" );
            process_files( \@paths_in_dir );
            
            if( $save_path ) { append_to_file( $save_path, "=== $dir_name END ===" ); }
            say "=== $dir_name END ===";
        
            next;
        }

        open my $fh, '<', $path || die "Can't open file: $!";

        # Count the lines of code
        my $line_count = 0;
        while( my $line = <$fh> ) {
            $line =~ s/^\s+|\s+$//g;    # Trim both ends

            if( substr($line, 0, 2) ne "//" && $line ne "" ) {
                $line_count++;
            }
        }

        close $fh || die "Can't close file: $!";

        # Display line_count in the console
        my $file_name = basename( $path );
        say "$file_name: $line_count";

        # Append $line_count data to target file if specified
        if( $save_path ) { 
            append_to_file( $save_path, "$file_name: $line_count" ); 
        }
    }
}

process_files( \@paths );