#!/usr/bin/perl
package Extensions;

use Exporter;
use feature 'say';

@ISA = ( 'Exporter' );
our @EXPORT = qw/ 
    is_supported
    is_comment
    get_supported_extensions/;

# 
# %supported_extensions
#
# Key:      string          Supported extension inclusive of .
# Value:    array reference Single line comments identifier
my %supported_extensions = (
    '.swift' => ['//']  # //, ///
);

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
    return !exists( $supported_extensions{ $extension } ) ? 0 : 1;
}

#
# is_comment()
#
# Arguments:
#   $line: string A line in the source code
#   $extension: string File extension
#
# Returns: boolean True (1) if the line is a comment
#                  False (0) otherwise
#
# Check whether a line in the source code is a comment.
#
sub is_comment {
    my ( $line, $extension ) = @_;

    my @comment_ids = @{ $supported_extensions { $extension } };

    foreach my $comment_id ( @comment_ids ) {
        if( $line =~ m/^$comment_id/ ) {
            return 1;
        }
    }
    
    return 0;
}

#
# get_supported_extensions()
#
# Arguments: N/A
#
# Returns: array of string Supported extensions
#
# Get all the supported extensions.
#
sub get_supported_extensions {
    return keys %supported_extensions;
}

1;