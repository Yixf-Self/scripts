#!/usr/bin/perl
use Bio::SeqIO::fastq;

my $in = Bio::SeqIO->new(
    -format  => 'fastq',
    -variant => 'illumina',

    #-variant => 'solexa',
    -file => 'in.fq'
);

my $out = Bio::SeqIO->new(
    -format  => 'fastq',
    -variant => 'sanger',
    -file    => '>out.fq'
);

while ( my $seq = $in->next_seq ) {
    $out->write_seq($seq);
}

