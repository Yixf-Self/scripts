#!/usr/bin/perl 

use strict;
use warnings;
use DateTime;

my $dt  = DateTime->now;
my $ymd = $dt->ymd;
$ymd =~ s/-//g;

my @configure_home = ( "bashrc",  "conkyrc", "profile", "vimrc" );
my @configure_etc  = ( "crontab", "hosts" );
my @configure_apt  = ("sources.list");
my @configure_ftp  = ("sitemanager.xml");
my @configure_dict = ("config");
my $configure_ssh  = "~/.ssh/config";
my $bak_folder  = "/3_archive/Dropbox/Ubuntu_Software/configure";
my $bak_vim     = "/3_archive/Dropbox/Ubuntu_Software/vim";
my $bak_scripts = "/3_archive/Dropbox/Ubuntu_Software/scripts";

foreach (@configure_home) {
    system "cp ~/.$_ $bak_folder/$_.$ymd";
}

foreach (@configure_etc) {
    system "cp /etc/$_ $bak_folder/$_.$ymd";
}

foreach (@configure_apt) {
    system "cp /etc/apt/$_ $bak_folder/$_.$ymd";
}

foreach (@configure_ftp) {
    system "cp ~/.filezilla/$_ $bak_folder/ftp_$_.$ymd";
}

foreach (@configure_dict) {
    system "cp ~/.goldendict/$_ $bak_folder/goldendict_$_.$ymd";
}

system "cp $configure_ssh $bak_folder/ssh_config.$ymd";

system "tar -czf $bak_vim/vim_$ymd.tar.gz ~/.vim";
system "tar -czf $bak_vim/vimana_$ymd.tar.gz ~/.vimana";

system "tar -czf $bak_folder/conky_$ymd.tar.gz ~/.conky";
system "tar -czf $bak_folder/ssh_$ymd.tar.gz ~/.ssh";

system "tar -czf $bak_scripts/scripts_$ymd.tar.gz ~/Scripts";

