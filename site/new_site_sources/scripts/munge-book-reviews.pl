#!/usr/bin/perl

use strict;
use warnings;

use YAML qw(LoadFile DumpFile);

{
    my $fn = "books.yml";

    my $data = LoadFile($fn);

    my @k = keys(%$data);

    foreach my $b (@k)
    {
        foreach my $review (@{$data->{$b}->{book_reviews}})
        {
            my $c_ref = \($review->{'review_content'});
            if ($$c_ref)
            {
                $$c_ref = qq{<p>\n} . $$c_ref . qq{\n</p>\n};
            }
        }
    }

    DumpFile($fn, $data);
}
