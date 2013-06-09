#!/usr/bin/env perl

use strict;
use warnings;

my $word = $ARGV[0];
if ( !$word ) { $word = `xsel -o`; }
if ( !$word ) { &usage; exit; }
chomp $word;

my $direction;
if ( $word =~ /\w/ ) {
    $direction = "en|zh-CN";
}
else {
    $word      = `echo "$word"|uni2ascii -a J -s`;
    $direction = "zh-CN|en";
}

$_ =
`w3m -cookie -dump 'http://www.google.com.hk/dictionary?langpair=$direction&q=$word&hl=zh-CN' 2>/dev/null`
  or die "Network Error!\n";

if (/(^相关短语.*)^词义搜索/ms) {
    print $1;
}
else {
    warn "Invalued word!\n";
    exit 1;
}

sub usage {
    print "$0 someword\n";
    exit 1;
}

