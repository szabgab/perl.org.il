#!/usr/bin/perl

use strict;
use warnings;

use YAML qw(LoadFile DumpFile);

foreach my $y (2003 .. 2008)
{
    my $fn = "meetings$y.yml";

    my $data = LoadFile($fn);

    my @k = keys(%$data);

    foreach my $d (@k)
    {
        if ($data->{$d}->{'report_text'})
        {
            $data->{$d}->{'report_text'} =
                  qq{<p>\n}
                . $data->{$d}->{'report_text'}
                . qq{\n</p>\n}
                ;
        }
    }

    DumpFile($fn, $data);
}
