#!/usr/bin/perl

use warnings;
use strict;

# my $out  = `fortune`;
my $out  = `fortune-zh`;
my $icon = "/home/yixf/Pictures/icons/books.png";
my $title;
my @body;
my $body;

if ( $out =~ /32m/ ) {
    my @lines = split /\n/, $out;
    foreach my $line (@lines) {
        if ( $line =~ /m/ ) {
            $line =~ s/^\W\[\d+m(.+?)\W\[m/$1/;
            $line =~ s/题目://;
            $line =~ s/作者://;
            $line =~ s/作者：//;
            $title .= $line;
        }
        else {
            push @body, $line;
        }
        $body = join "\n", @body;
    }
}
else {
    $title = "FORTUNE";
    $body  = $out;
    $body =~ s/"/\\"/g;
    $body =~ s/'/\\'/g;
}

`notify-send -i "$icon" "$title" "$body"`;

# my $output = join "\n",$title,$body;
# `notify-send -i "$icon" "$output" ""`;

