#!/usr/bin/perl 

use strict;
use warnings;
use Class::Date qw(now);

my $mode = $ARGV[0];
my $time = now;
my $date = $time->ymd;
$date =~ s#/##g;

my $bak_folder = "/3_archive/Dropbox/Ubuntu_Software/vnstat";

if ( $mode eq "daily" ) {
    my $png = "$mode" . "_$date" . ".png";
    system "vnstati -i eth0 --days --output $bak_folder/$png";
}
elsif ( $mode eq "monthly" ) {
    my $png = "$mode" . "_$date" . ".png";
    system "vnstati -i eth0 --months --output $bak_folder/$png";
}
elsif ( $mode eq "weekly" ) {
    my $txt = "$mode" . "_$date" . ".txt";
    system "vnstat -i eth0 --weeks >$bak_folder/$txt";
}
else {
    print "ERROR!\n";
}
