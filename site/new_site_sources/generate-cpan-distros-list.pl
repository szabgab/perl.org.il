#!/usr/bin/perl

use strict;
use warnings;

use utf8;

use CPANPLUS::Backend;
use Data::Dumper;
use List::MoreUtils (qw(uniq));

{
    no warnings;
    # This is an optimisation because dslip is incredibly slow,
    # and it badly affects $module->clone() .
    *CPANPLUS::Module::dslip = sub { return ' ' x 5;};
}

my $cb      = CPANPLUS::Backend->new;

sub get_author_dists_list
{
    my $id = shift;

    $id = uc($id);

    my $author = $cb->author_tree( $id );

    my @dists  = $author->distributions;

    return
    {
        dists => [
            uniq(
                sort { $a cmp $b }
                map { my $n = $_->name(); $n =~ s{::}{-}g; $n }
                # For author-*.json files.
                grep { $_->name() ne 'author' }
                @dists
            )
        ],
        id => $id,
        name => $author->author(),
    };
}

my @authors =
(
    {
        id => "amoss",
    },
    {
        id => "eilara",
        mod_comments =>
        {
            'Aspect' => qq{(originally by <a href="http://metacpan.org/author/Marcel/">Marcel Grünauer</a>)},
        },
    },
    {
        id => "felixl",
    },
    {
        id => "gaal",
        exclude_from_list => 1,
    },
    {
        id => "genie",
    },
    {
        id => "idoperel",
    },
    {
        id => "isaac",
    },
    {
        id => "migo",
    },
    {
        id => "nuffin",
        auth_comment => q{ (uploads - not all were originated or are presently maintained by him)},
    },
    {
        id => "peterg",
    },
    {
        id => "priluskyj",
    },
    {
        id => "razinf",
    },
    {
        id => "reuven",
    },
    {
        id => "romm",
    },
    {
        id => "semuelf",
    },
    {
        id => "shlomif",

        mod_comments =>
        {
            'Error' => qq{(originally by <a href="http://metacpan.org/author/Gbarr/">Graham Barr</a> and later maintained by <a href="http://metacpan.org/author/Uarun/">Arun Kumar U</a> - now co-maintained by <a href="http://metacpan.org/author/Pevans/">Paul Evans</a>)},
            'File-Find-Object' => qq{(originally by <a href="http://metacpan.org/author/Nanardon/">Olivier Thauvin</a>)},
            'Statistics-Descriptive' => qq{(originally by <a href="http://metacpan.org/author/Colink/">Colin Kuskie</a>)},
            'WWW-Form' => qq{(originally by <a href="http://metacpan.org/author/Bschmau/">Benjamin Schmaus</a>)},
            'XML-RSS' => qq{(originally by other authors. Also see <a href="http://www.perlfoundation.org/may_2_2007_xml_rss_cleanup_grant_completed_final_report">the XML::RSS cleanup grant final report</a>.)},
            'XML-SemanticDiff' => qq{(originally by <a href="http://metacpan.org/author/Khampton/">Kip Hampton</a>)},
        },
    },
    {
        id => "shlomoy",
    },
    {
        id => "smalyshev",
    },
    {
        id => "szabgab",
    },
    {
        id => "xsawyerx",
    },
    {
        id => "yosefm",
    },
    {
        id => "schop",
        name => "Ariel Brosh (R.I.P.)",
    },
);

=begin Removed

    # I'm removing this because RBOW is not really Israeli and this module
    # is of too little interest.
    {
        id => "rbow",
        filter => sub { my $mod = shift; return ($mod eq "Date-Passover");},
        exclude_from_list => 1,
    },

    'File-FTS' => qq{(originally by <a href="http://metacpan.org/author/SCHOP">Ariel Brosh</a>)},

=end Removed

=cut

my $output = "";
my @id_names = ();
foreach my $auth_in (@authors)
{
    my $auth_struct = get_author_dists_list(delete($auth_in->{id}));
    my $id = $auth_struct->{id};

    if (exists($auth_in->{'name'}))
    {
        $auth_struct->{name} = delete($auth_in->{'name'});
    }

    my $mod_comments = delete($auth_in->{'mod_comments'}) || {};

    my $auth_comment = delete($auth_in->{'auth_comment'}) || "";

    $output .=
          qq#<li>\n#
        . qq#<a href="http://metacpan.org/author/$id">#
        . qq#$id</a>#
        . qq# - $auth_struct->{name}#
        . qq#$auth_comment<br />\n#
        . qq#<ul>\n#
        ;

    my $filter = delete($auth_in->{filter});
    DISTS_LOOP:
    foreach my $d (@{$auth_struct->{dists}})
    {
        if ($filter && (! $filter->($d)))
        {
            next DISTS_LOOP;
        }
        my $comment = delete($mod_comments->{$d}) || "";
        if (length($comment))
        {
            $comment = " " . $comment;
        }
        $output .=
            qq#<li><a href="http://metacpan.org/release/$d">$d</a>$comment</li>\n#
            ;
    }

    if (keys(%$mod_comments))
    {
        die "Leftover Module Comments for Author $id :".
            join(",", keys(%$mod_comments));
    }

    $output .= qq#</ul>\n</li>\n#;

    if (exists($auth_in->{exclude_from_list}))
    {
        delete($auth_in->{exclude_from_list});
    }
    else
    {
        push @id_names,
        {
            id => $id,
            name => $auth_struct->{name}
        };
    }

    if (keys(%$auth_in))
    {
        die "Leftover keys for Author $id : " .  join(",", keys(%$auth_in));
    }
}

open my $cpan_authors_html, ">:utf8", "cpan-distros-list.html";
print {$cpan_authors_html} <<"EOF";
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE
    html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US">
<head>
<title>Israeli CPAN Authors</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1>Israeli CPAN Authors</h1>
<ul>
EOF
print {$cpan_authors_html} $output;
print {$cpan_authors_html} <<"EOF";
</ul>
</body>
</html>
EOF
close ($cpan_authors_html);

my $source_fn = "templates/israeli-projects_content.tmpl";
my $temp_fn = "project-cont.tmpl";

open my $in, "<:utf8", $source_fn;

open my $out, ">:utf8", $temp_fn;

LINES_LOOP:
while (my $l = <$in>)
{
    print {$out} $l;
    if ($l =~ m{<!-- \{START_CPAN\} -->})
    {
        print {$out} $output;
        LOOKING_FOR_END:
        while ($l = <$in>)
        {
            if ($l =~ m{<!-- \{END_CPAN\} -->})
            {
                last LOOKING_FOR_END;
            }
        }
        print {$out} $l;
        last LINES_LOOP;
    }
}

while(my $l = <$in>)
{
    print {$out} $l;
}

close($in);
close($out);

rename($temp_fn, $source_fn);

open $out, ">", "01-misc.t";
print {$out} <<'EOF';
#!/usr/bin/perl

use strict;
use warnings;

use Acme::CPANAuthors;

use Test::More tests => 2;

my $authors = Acme::CPANAuthors->new('Israeli');
EOF

print {$out} "# TEST\n";
print {$out} q{is ($authors->count, }, scalar(@id_names), q{, 'number of authors');};

print {$out} "\n";

print {$out} "# TEST\n";
print {$out} q#is_deeply([sort $authors->id ], #, "\n",
"    [qw(\n",
    (map { ((" " x 8) . $_ . "\n") } sort map { uc($_->{id}) } @id_names),
"    )],\n",
    q#    'Author IDs');#;

close ($out);

open $out, ">:utf8", "Acme-CPANAuthors-Israeli-to-include.pm";
print {$out} qq#use Acme::CPANAuthors::Register (\n#;
print {$out} map {
    ((" " x 4) . uc($_->{id}) . " => " . q{'} . $_->{name} . q{'} . ",\n")
    }
    @id_names
    ;
print {$out} qq#);\n\n\n#;
close($out);
