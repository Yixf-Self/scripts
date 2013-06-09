#!/usr/bin/perl
use strict;
use warnings;

# findDupeFiles:
# This script attempts to identify which files might be duplicates.
# It searches specified directories for files with a given suffix
# and reports on files that have the same MD5 digest.
# The suffix or suffixes to be searched for are specified by the first
# command-line argument - each suffix separated from the next by a vertical bar.
# The subsequent command-line arguments specify the directories to be searched.
# If no directories are specified on the command-line,
# it searches the current directory.
# Files whose names start with "._" are ignored.
#
# Cameron Hayne (macdev@hayne.net)  January 2006
#
#
# Examples of use:
# ----------------
# findDupeFiles '.aif|.aiff' AAA BBB CCC
# would look for duplicates among all the files with ".aif" or ".aiff" suffixes
# under the directories AAA, BBB, and CCC
#
# findDupeFiles '.aif|.aiff'
# would look for duplicates among all the files with ".aif" or ".aiff" suffixes
# under the current directory
#
# findDupeFiles '' AAA BBB CCC
# would look for duplicates among all the files (no matter what suffix)
# under the directories AAA, BBB, and CCC
#
# findDupeFiles
# would look for duplicates among all the files (no matter what suffix)
# under the current directory
# -----------------------------------------------------------------------------

use File::Find;
use File::stat;
use Digest::MD5;

my $matchSomeSuffix;    # reference to a subroutine for matching suffixes
if ( defined( $ARGV[0] ) ) {

    # the list of desired suffixes is supplied in $ARGV[0]
    # separated by vertical bars - e.g. ".mp3|.aiff"
    # Note that if $ARGV[0] is '', then all files will be looked at

    my @suffixes = split( /\|/, $ARGV[0] );
    if ( scalar(@suffixes) > 0 ) {

        # create an efficient matching subroutine using the Friedl technique
        my $matchExpr =
          join( '||', map { "m/\$suffixes[$_]\$/io" } 0 .. $#suffixes );

        $matchSomeSuffix = eval "sub {$matchExpr}";
    }
    shift @ARGV;
}

# if no dirs supplied as command-line args, we search the current directory
my @searchDirs = @ARGV ? @ARGV : ".";

# verify that these are in fact directories
foreach my $dir (@searchDirs) {
    die "\"$dir\" is not a directory\n" unless -d "$dir";
}

my %filesByMd5;    # global variable holding hash of arrays of dupes

# calcMd5: returns the MD5 digest of the given file
sub calcMd5($) {
    my ($filename) = @_;

    if ( -d $filename ) {

        # doing MD5 on a directory is not supported
        return "unsupported";    # we need to return something
    }

    $filename =~ s#^(\s)#./$1#;    # protect against leading whitespace
    open( FILE, "< $filename\0" )
      or die "Unable to open file \"$filename\": $!\n";
    binmode(FILE);                 # just in case we're on Windows!
    my $md5 = Digest::MD5->new->addfile(*FILE)->hexdigest;
    close(FILE);
    return $md5;
}

# checkFile: invoked from the 'find' routine on each file or directory in turn
sub checkFile() {
    return unless -f $_;           # only interested in files, not directories

    my $filename = $_;
    my $dirname  = $File::Find::dir;

    return if $filename =~ /^\._/;    # ignore files whose names start with "._"

    if ( defined($matchSomeSuffix) ) {
        return unless &$matchSomeSuffix;
    }

    my $statInfo = stat($filename)
      or warn "Can't stat file \"$dirname/$filename\": $!\n" and return;
    my $size = $statInfo->size;
    my $md5  = calcMd5($filename);

    my $fileInfo = {
        'dirname'  => $dirname,
        'filename' => $filename,
        'size'     => $size,
        'md5'      => $md5,
    };

    push( @{ $filesByMd5{$md5} }, $fileInfo );
}

MAIN:
{

    # traverse the directories and build up lists of dupes in %filesByMd5
    find( \&checkFile, @searchDirs );

    # for each set of dupes, print the full path to the files
    my $numDupes     = 0;
    my $numDupeBytes = 0;
    foreach my $key ( keys %filesByMd5 ) {
        my @dupList   = @{ $filesByMd5{$key} };
        my $numCopies = scalar(@dupList);
        next unless $numCopies > 1;

        my $size = -1;
        foreach my $fileInfo (@dupList) {
            my $dirname  = $fileInfo->{dirname};
            my $filename = $fileInfo->{filename};
            if ( $size == -1 ) {
                $size = $fileInfo->{size};
            }
            elsif ( $size != $fileInfo->{size} )    # sanity check
            {
                print "File sizes don't match!\n";
                print "previous: $size current: $fileInfo->{size}\n";
            }

            print "$dirname/$filename\n";
        }
        print "----------\n";

        $numDupes += ( $numCopies - 1 );
        $numDupeBytes += ( $size * ( $numCopies - 1 ) );
    }

    my $numDupeMegabytes = sprintf( "%.1f", $numDupeBytes / ( 1024 * 1024 ) );
    print "Number of duplicate files: $numDupes\n";
    print "Megabytes duplicated: $numDupeMegabytes\n";
}
