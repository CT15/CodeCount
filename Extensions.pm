#!/usr/bin/perl
package Extensions;

use Exporter;

@ISA = ( 'Exporter' );
our @EXPORT = qw/ 
    is_supported
    comments_identifiers
    get_supported_extensions/;

my %supported_extensions = (
    # .swift ~> '//', '///', '/* */'
    '.swift' => ('//')
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

    if( !exists( $supported_extensions{ $extension } ) ) {
        return 0;
    }

    return 1;
}

#
# comments_identifiers()
#
# Arguments:
#   $extension: string File extension
#
# Returns: array of string Comments identifiers
#
# Get the comments identifiers of file with the given extension.
#
sub comments_identifiers {
    my $extension = shift;
    return $supported_extensions{ $extension };
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