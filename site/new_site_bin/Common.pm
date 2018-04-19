package Common;

require Exporter;

our @ISA=(qw(Exporter));

our @EXPORT=(qw(get_common_tmpl_params));

sub get_common_tmpl_params
{
    return ('nav_bar' => [
			{ nav_page => 'about.html'         , nav_name => 'About Us'      },
			{ nav_page => 'mailing_lists.html' , nav_name => 'Mailing Lists' },
			{ nav_page => 'meetings.html'      , nav_name => 'Meetings'      },
			{ nav_page => 'yapc.html'          , nav_name => 'Conferences'   },
#			{ nav_page => 'library.html'       , nav_name => 'Library'       },
			{ nav_page => 'misc.html'          , nav_name => 'Misc Content'  },
			{ nav_page => 'learning-perl.html' , nav_name => 'Learning Perl' },
            { nav_page => 'israeli-projects.html'
                                               , nav_name => 'Israeli Projects'
                                           },
			{ nav_page => 'business.html'      , nav_name => 'Perl in Business' },
#            { nav_page => 'http://wiki.perl.org.il/', nav_name => "Wiki", abs_path => 1, },

		],
        # TODO : Empty the banner string code once AP5 is over.
        'banner' => "",

        );
}

# Rejects

=begin Rejects

        'banner' => <<"EOF",
<a href="http://ap.hamakor.org.il/2006/" title="August Penguin 5">
<img src="/images/ap5-banner-alex-em.png" style="border-width:0" alt="August Penguin 5" /></a>
EOF

=end

=cut

1;

