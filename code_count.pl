#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

use feature 'say';

use Getopt::Long;
use File::Basename;
use Path::Tiny 'path';
use Cwd 'abs_path';

use lib dirname( abs_path $0 ); # Manipulate @INC at compile time
use Extensions;

########## INITIALIZATION ##########

my $check_path;     # Path to file(s) to be checked
my $save_path;      # Path to file where data is saved
my $extension; # Extension of files to check (with .)
GetOptions(
    "path=s" => \$check_path,       # compulsory
    "extension=s" => \$extension,   # compulsory
    "save=s" => \$save_path         # optional
);

# Check if the path is specified
unless ( $check_path ) {
    say "path argument must be specified.";
    exit;
}

# Check if extension is specified
unless ( $extension ) {
    say "extension argument must be specified.";
    exit;
}

my @paths;
if ( -d $check_path ) {
    # Get all files at specified directory
    @paths = glob qq{ '$check_path/*' };
} else {    # A single file
    # There is only one path, which is $check_path
    @paths = $check_path;
}

my $total_lines = 0;

############### END ################

######## HELPER SUBROUTINES ########

#
# has_specified_extension()
#
# Arguments:
#   $path: string Path to file to be processed
#
# Returns: True (1) if extension is supported
#          False (0) otherwise
#
# Check whether the file given by path has the same
# extension as the extension argument specified.
#
sub has_specified_extension {
    my $path = shift;
    my ( $name, $dir, $ext ) = fileparse( $path, get_supported_extensions() );
    return $ext eq $extension ? 1 : 0;
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
    my ( $text ) = @_;
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

            display_and_append_file( "=== $dir_name START ===" );

            my @paths_in_dir = glob qq{ '$path/*' };
            process_files( \@paths_in_dir );
            
            display_and_append_file( "=== $dir_name END ===" );
        
            next;
        }

        # Skip file if extension does not match the extension specified
        unless( has_specified_extension( $path ) ) { next; }

        # Create temp.txt in process folder
        my $temp_path = dirname( abs_path $0 ) . '/process/temp.txt';
        open my $TEMP, '+>', $temp_path || die "Can't open file: $!";

        # Copy file content to temp.txt without multiline comments
        my $file_content = path( $path )->slurp_utf8;
        $file_content =~ s{/\*(?:.|[\r\n])*?\*/}{}g;
        print $TEMP $file_content;

        my $line_count = 0;

        seek $TEMP, 0, 0;   # Re-position pointer to the beginning of the file

        # Count lines of code ignoring empty lines and comments
        while( my $line = <$TEMP> ) {
            $line =~ s/^(\s+)|(\s+)$//g;
            if( $line ne "" && !is_comment( $line, $extension ) ) {
                $line_count++;
            }
        }

        # Display line_count in the console
        my $file_name = basename( $path );
        display_and_append_file( "$file_name: $line_count" );

        # Increment total number of lines
        $total_lines += $line_count;

        # Delete temp.txt
        close $TEMP || die "Can't close file: $!";
        unlink $temp_path;
    }
}

############### END ################

############ EXECUTION #############

# Check if extension is supported
unless( is_supported( $extension ) ) {
    say "The extension you specified is not yet supported.\n" .
        "You can go to https://github.com/CT15/CodeCount to submit a PR.\n" .
        "It is also possible that you did not specify the correct extension.\n" .
        "The correct extension should be inclusive of the '.' (dot).\n" .
        "For example, '.java' and NOT 'java'.";
    exit;
}

my $date_time = localtime();
display_and_append_file( $date_time );

process_files( \@paths );
display_and_append_file( "==========");
display_and_append_file( "Total: $total_lines\n" );

############### END ################