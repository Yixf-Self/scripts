#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
our ($opt_c, $opt_f, $opt_o, $opt_d);

# Usage
my $usage = "
get_fragment_coverage - Converts BedTools coverage output to percent of bases
                        covered across the entire sequence.

Prerequisites: samtools, bedtools

Usage: perl get_fragment_coverage.pl options
  -c	Coverage file.  Generated using BedTools from the following command
        (see BamTools documentation for more information):
            genomecoveragebed -ibam <sorted BAM file> -g <.fai samtools fasta
            index file> -bga > <output file>
        If piping with genomecoveragebed, use \"-c STDIN\"    
  -f    .fai samtools fasta index file (required for now)          
  -o	ouput file name (default coverage.txt)
  -d    minimum coverage depth (default 1)
  
";

# command line processing
getopts('c:f:o:d:');
die $usage unless ($opt_c);
die $usage unless ($opt_f);

my ($cov, $fai, $outfile, $depth);

$cov		= $opt_c if $opt_c;
$fai            = $opt_f if $opt_f;
$outfile	= $opt_o ? $opt_o : "coverage.txt";
$depth  	= $opt_d ? $opt_d : 1;

# Input Index and Coverage files, open output file
my ($in, $index, $out);
if ($cov ne "STDIN") {
    open($in, "<", $cov) or die "Can't open $cov: $!";
} 
open($index, "<", $fai) or die "Can't open $fai: $!";
open($out, ">",  $outfile);
print $out "Segment ID\tlength\t#of bases with < $depth coverage\t% of bases covered\taverage coverage\tmax coverage\n";

# index file processing
print STDERR "Reading index file into array.\n";
my @farray = ();
while (<$index>){
    push @farray, [split];
}
my $fragnum = @farray;
my $fragbases = 0;
my $h;
for $h (0 .. $#farray){
    $fragbases = $fragbases + $farray[$h][1];
}
close $index;

# reads BamTools coverage file into a 2D array
my @array2d = ();
print STDERR "Reading data into array.  This may take a little while...\n";
if ($cov ne "STDIN") {
    while (<$in>){
        next if /^(\s)*$/; #skip blank lines
        chomp;
        push @array2d, [split];
    }
} else {
    while (<STDIN>){
        next if /^(\s)*$/; #skip blank lines
        chomp;
        push @array2d, [split];
    }    
}

# calculate coverage per base across a genome or segment
my $i;
my $uncovered = 0;
my $percov = 0;
my $genome;
my $genomelength;
my $basecount = 0;
my $tbasecount = 0;
my $tlength = 0;
my $lastline = @array2d - 1;
my $count = 0;
my ($basecov, $tbasecov, $max, $avgcov) = (0) x 4;
my @covarray = ();
my $temp;
for $i (0 .. $#array2d){
    $basecov = $array2d[$i][3];
    if ($basecov < $depth and $i == 0){
        $uncovered = $array2d[$i][2] - $array2d[$i][1];
        $basecount = $basecount + $uncovered;
        $tbasecount = $tbasecount + $uncovered;
        $tbasecov = $tbasecov + $basecov;
        if ($basecov > $max){
            $max = $basecov;
        }
        print STDERR "\t@{$array2d[$i]} uncovered = $uncovered, basecount = $basecount\n";
    } elsif ($basecov < $depth and $array2d[$i][1] != 0){
        if ($i != $lastline){
            $uncovered = $array2d[$i][2] - $array2d[$i][1];
            $basecount = $basecount + $uncovered;
            $tbasecount = $tbasecount + $uncovered;
            $tbasecov = $tbasecov + $basecov;
            if ($basecov > $max){
                $max = $basecov;
            }
            print STDERR "\t@{$array2d[$i]} uncovered = $uncovered, basecount = $basecount\n";
        } else {
            $uncovered = $array2d[$i][2] - $array2d[$i][1];
            $basecount = $basecount + $uncovered;
            $tbasecount = $tbasecount + $uncovered;
            $tbasecov = $tbasecov + $basecov;
            if ($basecov > $max){
                $max = $basecov;
            }
            print STDERR "\t@{$array2d[$i]} uncovered = $uncovered, basecount = $basecount\n";
            $genome = $array2d[$i][0];
            $genomelength = $array2d [$i][2];
            $tlength = $tlength + $genomelength;
            $percov = 100*($genomelength - $basecount) / $genomelength;
            $avgcov = $tbasecov / $genomelength;
            my $temp = ([$genome, $genomelength, $basecount, $percov, $avgcov, $max]);
            push @covarray, $temp;
            print STDERR "Writing data for $genome\n";
            ($tbasecov, $max) = (0) x 2;
            $count++;
        } 
    } elsif ($array2d[$i][1] == 0 and $i > 0){
        $tbasecov = $tbasecov + $basecov;
        if ($basecov > $max){
            $max = $basecov;
        }
        $genome = $array2d[$i-1][0];
        $genomelength = $array2d [$i-1][2];
        $tlength = $tlength + $genomelength;
        $percov = 100*($genomelength - $basecount) / $genomelength;
        $avgcov = $tbasecov / $genomelength;
        my $temp = ([$genome, $genomelength, $basecount, $percov, $avgcov, $max]);
        push @covarray, $temp;
        print STDERR "Writing data for $genome\n";
        ($tbasecov, $max) = (0) x 2;
        $count++;
        $basecount = 0;
        if ($basecov < $depth){
            $uncovered = $array2d[$i][2] - $array2d[$i][1];
            $basecount = $basecount + $uncovered;
            $tbasecount = $tbasecount + $uncovered;
            print STDERR "\t@{$array2d[$i]} uncovered = $uncovered, basecount = $basecount\n"; 
        }        
    } elsif ($i == $lastline and $basecov >= $depth){
        $tbasecov = $tbasecov + $basecov;
        if ($basecov > $max){
            $max = $basecov;
        }
        $genome = $array2d[$i][0];
        $genomelength = $array2d [$i][2];
        $tlength = $tlength + $genomelength;
        $percov = 100*($genomelength - $basecount) / $genomelength;
        $avgcov = $tbasecov / $genomelength;
        my $temp = ([$genome, $genomelength, $basecount, $percov, $avgcov, $max]);
        push @covarray, $temp;
        print STDERR "Writing data for $genome\n";
        ($tbasecov, $max) = (0) x 2;
        $count++;
    } else {
        $tbasecov = $tbasecov + $basecov;
        if ($basecov > $max){
            $max = $basecov;
        }        
    }
}

my $covarraysize = @covarray;
my $p = 0;
my $q = -1;
if ($covarraysize < $fragnum){
    for $p (0 .. $#farray){
        $q++;
        if ($farray[$p][0] eq $covarray[$q][0]){
            print $out "$covarray[$q][0]\t$covarray[$q][1]\t$covarray[$q][2]\t$covarray[$q][3]\t$covarray[$q][4]\t$covarray[$q][5]\n";
        } else {
            print $out "$farray[$p][0]\t$farray[$p][1]\t$farray[$p][1]\t0\t0\t0\n";
            $q--;
        }
    }
} else {
    for $p (0 .. $#covarray){
        print $out "$covarray[$p][0]\t$covarray[$p][1]\t$covarray[$p][2]\t$covarray[$p][3]\t$covarray[$p][4]\t$covarray[$p][5]\n";
    }
}

#@array2d = ();
if ($cov ne "STDIN") {
    close $in;
}    
close $out;
print STDERR "Done!\n\n";
my $tpercov = 100*($tlength - $tbasecount) / $tlength;
my $rtpercov = sprintf("%.4f", $tpercov);
my $missingfrag = $fragnum - $count;
my $missingbases = $fragbases - $tlength;
my $overallpercov = 100*($fragbases - ($tbasecount + $missingbases)) / $fragbases;
my $rounded = sprintf("%.4f", $overallpercov);
print STDERR "Among $count sequences $tbasecount bases with less than $depth read coverage were found.  $rtpercov% of all bases have coverage.\n";
print STDERR "$fragnum total sequences in fai file.  $missingfrag sequences missing from coverage file containing $missingbases bases\n";
print STDERR "Total percent coverage for all sequences is $rounded%.\n\n";
