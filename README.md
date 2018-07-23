# CodeCount

## "Weird Phenomena"

The things listed below are perhaps expected but they seemed weird to a first time Perl learner like myself.
As a result, they were not very intuitive to debug. These are for me to take note of in the future.

### `glob()` behaviour

Given that `directory_path` is an argument specified from the terminal when perl script is run, 
`glob( directory_path )` returns:
* all file_paths in the directory if `directory_path` is enclosed by " ".
  ```shell
  $ perl code_count.pl -p "~/path/to/directory"
  ```
* only the first_file_path in the directory if `directory_path` is **not** enclosed by " ".
  ```shell
  $ perl code_count.pl -p ~/path/to/directory
  ```

It seems like `glob()` behaves the same way in both Perl and Python. 

To enable Perl to detect directories containing spaces we use `glob qq{ directory_path }`

### Passing an array into a subroutine

Passing in an array into subroutines involve passing in the reference of the array.
``` perl
sub aSubroutine {
  my $array_ref = shift;
  my @array = @$array_ref;
}

my $array_ref = [ 'element1', 'element2' ];
aSubroutine( $array_ref );
```

### Checking if an element exists in an array

The check involves turning an array into a hash first. Then, use the `exists()` function on the hash.
For example, if we would like to check whether `$anElement` exists in `@anArray`, the code is as follows:
```perl
my %aHash = map{ $_ => 1 } @anArray;
if( exists $aHash{ $anElement } ) { ... }
```

### Hash of array

A hash of array is done through a hash of array reference instead. This is to fascilitate array retrieval from the hash.
```perl
my @first_array = ( 'element1', 'element2' );
my $second_array = [ 'element3', 'element4' ];

my %hash_of_array = (
    'first_key' => \@first_array,
    'second_key' => $second_array,
    'third_key' => [ 'element5', 'element6' ]
);

# Retrieving array from %hash_of_array;
my @retrieved_array = @{ $hash_of_array{ 'first_key' } };
```

It seems like
```perl
my @retrieved_array = @$hash_of_array{ 'first_key' };
```
causes `@retrieved_array` to be `undef`.

### Arguments parsing in a subroutine

The following works:
```perl 
my ($text) = @_; 
```
``` perl
my $text = shift;
```
```perl
my $text = shift( @_ );
```

The following does not work:
```perl
my $text = @_;  # $text == 1
```
