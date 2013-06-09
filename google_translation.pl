#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $notify;
GetOptions( 'n' => \$notify );

# 无参数时，使用剪贴板内容。
my $in = join( '+', @ARGV );
if ( !$in ) { $in = `xsel -o`; }
if ( !$in ) { exit; }
my $raw = $in;
$in = `echo "$in"|uni2ascii -a J -s`;
$in =~ s/ /+/g;
$in =~ s/["']//g;
chomp $in;

my $str;
my $icon;
if ( $in =~ /%/ ) {
    $str  = "zh-CN%7Cen";
    $icon = "$ENV{HOME}/Pictures/icons/english_big.png";
}
else {
    $str  = "en%7Czh-CN";
    $icon = "$ENV{HOME}/Pictures/icons/chinese_big.png";
}

my $out =
"curl -e http://www.my-ajax-site.com 'http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$in&langpair=$str' 2>/dev/null";
$out = `$out`;
$out =~ /translatedText":"(.*?)"/;
if   ($notify) { `notify-send -i '$icon' 'google翻译' "$in  =>  $1"`; }
else           { print "$raw  =>  $1\n"; }

