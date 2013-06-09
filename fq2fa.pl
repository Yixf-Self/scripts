#!/usr/bin/perl
use Bio::SeqIO::fastq;

my $in = Bio::SeqIO->new(
    -format => 'fastq',

    #-variant => 'solexa',
    -file => 'in.fq'
);

my $out = Bio::SeqIO->new(
    -format => 'fasta',
    -file   => '>out.fa'
);

while ( my $seq = $in->next_seq ) {
    $out->write_seq($seq);
}

