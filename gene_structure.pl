#!/usr/bin/perl -w

use Bio::Graphics;
use Bio::SeqIO;
use Bio::SeqFeature::Generic;
my $file = shift
  or die "provide a sequence file as the argument";
my $io = Bio::SeqIO->new( -file => $file )
  or die "couldn't create Bio::SeqIO";
my $seq = $io->next_seq
  or die "couldn't find a sequence in the file";
my @features = $seq->all_SeqFeatures;

# sort features by their primary tags
my %sorted_features;
for my $f (@features) {
    my $tag = $f->primary_tag;
    push @{ $sorted_features{$tag} }, $f;
}
my $panel = Bio::Graphics::Panel->new(
    -length    => $seq->length,
    -key_style => 'between',
    -width     => 800,
    -pad_left  => 10,
    -pad_right => 10
);
$panel->add_track(
    arrow => Bio::SeqFeature::Generic->new(
        -start => 1,
        -end   => $seq->length
    ),
    -bump   => 0,
    -double => 1,
    -tick   => 2
);
$panel->add_track(
    generic => Bio::SeqFeature::Generic->new(
        -start   => 1,
        -end     => $seq->length,
        -bgcolor => 'blue',
        -label   => 1
    )
);

# general case
my @colors = qw(cyan orange blue purple green
  chartreuse magenta yellow aqua);
my $idx = 0;
for my $tag ( sort keys %sorted_features ) {
    my $features = $sorted_features{$tag};
    $panel->add_track(
        $features,
        -glyph       => 'generic',
        -bgcolor     => $colors[ $idx++ % @colors ],
        -fgcolor     => 'black',
        -font2color  => 'red',
        -key         => "${tag}s",
        -bump        => +1,
        -height      => 8,
        -label       => 1,
        -description => 1
    );
}
print $panel->png;
