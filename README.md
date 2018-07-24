# CodeCount

Counts the lines of code in a single file / all files specified in a directory with the specified extension (e.g. .swift). These data can be automatically written into a file if the file path is specified.

## How it is done

Below are the steps of how the counting of lines of code is done:
  1. A temporary file in the `process` directory is created
  2. The content of a file is copied into the temporary file without mltiline comments
  3. The lines in the temporary file are counted ignoring blank lines and comment lines
  4. The temporary file in the `process` directory is removed
  5. Steps 1 to 4 are repeated till all files are parsed

## Usage

1. Clone the repository. Using HTTPS:
    ```shell
    $ git clone https://github.com/CT15/CodeCount.git
    ```
2. Navigate into the direcotry and run `code_count.pl`.
   Don't forget to specify the `path` and `extension` argument as follows:
    ```shell
    $ cd CodeCount
    $ perl code_count.pl -p path/to/file/or/directory/to/check -e .your_file_extension
    ```
    
Optionally, you can specify the path to a file where you want to save the parsing result (the `save` argument).
```shell
$ perl code_count.pl -p some/path -e .some_extension -s path/to/result/file
```

### Example:

An example of script execution with `save` argument.
```shell
$ perl code_count.pl -p ~/Desktop/my_directory -e .swift -s ~/Desktop/result.txt
```

### Dependency

You may need to install `Path::Tiny` module.
```shell
$ cpan Path::Tiny
```
## Extension Support

.swift

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

#### Note

[This](https://stackoverflow.com/questions/10031455/using-my-with-parentheses-and-only-one-variable) StackOverflow thread provides a useful example.

### quotemeta

## Future Improvement

Try to remove all comments (single and multi-line) from the content of a file before printing it to `temp.txt` file. Currently, I am only able to remove multi-line comments.

## Reflection

Regex is hard!!!

It is difficult to ensure that I have considered all possible commenting cases for an extension.
