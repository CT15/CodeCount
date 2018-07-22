#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use feature 'say';
use feature 'switch';

use Getopt::Long;
use File::Basename;

########## INITIALIZATION ##########
my @supported_extensions = qw/
.txt
/;

my $check_path;     # Path to file(s) to be checked
my $save_path;      # Path to file where data is saved
my $extension = ""; # Extension of files to check (with .)
GetOptions(
    "path=s" => \$check_path,       # compulsory
    "save=s" => \$save_path,        # optional
    "extension=s" => \$extension    # optional, default to all extensions
);

# Check if the path is specified
if ( !$check_path ) {
    say "Path argument must be specified.";
    exit;
}

my @paths;
if ( -d $check_path ) {
    # Get all files at specified directory
    @paths = glob( $check_path . "/*" );
} else {    # A single file
    # There is only one path, which is $check_path
    @paths = $check_path;
}

my $total_lines = 0;

############### END ################

######## HELPER SUBROUTINES ########

#
# is_supported()
#
# Arguments:
#   $extension: string File extension
#
# Returns: boolean True (1) if extension is supported
#                  False (0) otherwise
#
# Check whether the extension specified is in the @supported_extensions array. 
# "" is considered a supported extension.
#
sub is_supported {
    my $extension = shift;
    my %supported_extensions = map { $_ => 1 } @supported_extensions;

    if( $extension ne "" && !exists( $supported_extensions{ $extension } ) ) {
        return 0;
    }

    return 1;
}

#
# display_and_append_file()
#
# Arguments:
#   $text: Text to be displayed on the console
#
# Returns: void
#
# Display the given argument on the console.
# Appends the specified file with the given argument
# if $save_path is specified.
#
sub display_and_append_file {
    my ( $text ) = @_ ;
    say $text;

    if( $save_path ) {
        open my $fh, '>>', $save_path || die "Can't open file: $!";
        say $fh $text;
        close $fh || die "Can't close file: $!";
    }
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

        if( -d $path ) {    # Handle sub-directory
            my $dir_name = basename( $path );

            say "HERE";
            display_and_append_file( "=== $dir_name START ===" );

            my @paths_in_dir = glob( "$path" . "/*" );
            process_files( \@paths_in_dir );
            
            display_and_append_file( "=== $dir_name END ===" );
        
            next;
        }

        # Skip file if extension does not match the extension specified
        my ( $name, $dir, $extension ) = fileparse( $path, @supported_extensions );
        if ( !is_supported( $extension ) ) {
            next;
        }

        say "YAY";
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
        display_and_append_file( "$file_name: $line_count" );

        # Increment total number of lines
        $total_lines += $line_count;
    }
}

############### END ################

############ EXECUTION #############

# Check if extension is supported
if( !is_supported( $extension ) ) {
    say "The extension you specified is not yet supported.\n" .
        "You can go to https://github.com/CT15/CodeCount to submit a PR.\n" .
        "It is also possible that you did not specify the correct extension.\n" .
        "The correct extension should be inclusive of the '.' (dot).\n" .
        "For example, '.java' and NOT 'java'.";
    exit;
}

my $date_time = localtime();
display_and_append_file( "$date_time" );

process_files( \@paths );
display_and_append_file( "==========");
display_and_append_file( "Total: $total_lines\n" );

############### END ################