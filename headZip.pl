#!/usr/bin/perl 

use strict;
use warnings;

use Getopt::Std;
use IO::Uncompress::AnyUncompress qw(anyuncompress $AnyUncompressError);

my %opts = ( n => 10 );
getopts( 'n:', \%opts );
die(
    qq/
Usage:    headZip.pl [options] <FILE>

Options:  -n INT   The number of lines. [$opts{n}]
\n/
) if ( @ARGV < 1 );

my $fi = $ARGV[0];
my $n  = $opts{n};

my $z = new IO::Uncompress::AnyUncompress $fi
  or die "anyuncompress failed: $AnyUncompressError\n";

for ( my $i = 0 ; $i < $n ; $i++ ) {
    my $line = $z->getline();
    print "$line";
}

