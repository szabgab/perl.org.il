#!/usr/bin/perl -w
use strict;
use Data::Dumper    qw(Dumper);
use HTML::Template;
use Getopt::Long qw(GetOptions);
use FindBin qw($Bin);
use POSIX qw(mktime strftime);
use YAML qw(LoadFile);
use CGI ();

use lib $Bin;

use Common;

my $books  = LoadFile("$Bin/../new_site_sources/books.yml");
my $people = LoadFile("$Bin/../new_site_sources/people.yml");

#die Dumper $people;

###############################################################################
# This is the Perl script for creating the main pages (index, about, etc.)
# from the templates.
# By default it generates the pages in the "site" directory but you can
# override this default by providing the --outdir command line flag.
###############################################################################

my %opts;
GetOptions(\%opts, "outdir=s");

my @pages = qw(
	index.html
	about.html
	mailing_lists.html
	meetings.html
	yapc.html
	library.html
	misc.html
    israeli-projects.html
    learning-perl.html
	business.html
	error.html
);

my $template_file       = "$Bin/../new_site_sources/templates/main.tmpl";
my $outfiles_basedir    = $opts{outdir} || "$Bin/../new_site_sources/site";
my @outfiles = map { "$outfiles_basedir/$_" } @pages;
my $rss2_file = "$outfiles_basedir/rss2.rdf";
my $url = "http://perl.org.il/";

# create an RSS 2.0 file
my $rss;
eval {
	require XML::RSS;
};
$rss = new XML::RSS (version => '2.0') if not $@;
$rss->channel(
	title          => 'Israel.pm',
	'link'         => 'http://perl.org.il/',
	language       => 'en-us',
	description    => 'Israeli Perl Mongers',
	#rating         => '(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))',
	copyright      => 'Copyright 2002-2004, Perl.org.il',
	pubDate        => localtime,
	lastBuildDate  => localtime,
	docs           => 'http://blogs.law.harvard.edu/tech/rss',
	managingEditor => 'webmaster at perl.org.il',
	webMaster      => 'webmaster at perl.org.il',
	ttl            => "360",
	generator      => "XML::RSS",
) if $rss;

for my $output_file (@outfiles) {
	my $template = HTML::Template->new(filename => $template_file , loop_context_vars => 1, global_vars => 1,);
	$template->param(
		get_unique_params($output_file),
		meta_keywords => "Perl, perl, Mongers, mongers",
        get_common_tmpl_params(),
        'main' => 1,
	);

	# Print the template output
	open(OUT,">:encoding(utf8)", $output_file) or die "Couldn't open $output_file for writing: $!\n";
	print OUT $template->output;
	close(OUT) or die "Couldn't close $output_file after writing: $!\n";
}

$rss->save($rss2_file) if $rss;

#########################  start Hebrew pages
sub hebew_pages {
	my @pages = qw(
		index.html
		about.html
		mailing_lists.html
		meetings.html
		yapc.html
		library.html
		misc.html
		business.html
		error.html
	);

	my $template_file     = "$Bin/../new_site_sources/templates/he/main.tmpl";
	my $outfiles_basedir  = $opts{outdir} || "$Bin/../new_site_sources/site/he";
	my @outfiles          = map { "$outfiles_basedir/$_" } @pages;

	mkdir $outfiles_basedir if not -e $outfiles_basedir;

	for my $output_file (@outfiles) {
		my $template = HTML::Template->new(filename => $template_file , loop_context_vars => 1, global_vars => 1,);
		$template->param(
      		get_hebrew_unique_params($output_file),
			meta_keywords => "Perl, perl, Mongers, mongers",
			Hebrew	 => 'style="direction: rtl ; text-align: right"',
			#English  => 'dir="ltr"',
		);
   		# Print the template output
		open(OUT,">$output_file") or die "Couldn't open $output_file for writing: $!\n";
		print OUT $template->output;
		close(OUT) or die "Couldn't close $output_file after writing: $!\n";
	}
}
sub get_hebrew_unique_params {
	my $file = shift;
	my %parameters;
	if ($file =~ m/index/) {
		%parameters = (
			homepage => 1,
			date     => get_date(qw(index_content.tmpl related_sites_list.tmpl)),
		);
	} elsif ($file =~ m/about/) {
		%parameters = (
			about    => 1,
			date     => get_date(qw(about_content.tmpl)),
		);
	} elsif ($file =~ m/mailing/) {
		%parameters = (
			mailing  => 1,
			date     => get_date(qw(mailing_lists_content.tmpl)),
		);
	} elsif ($file =~ m/meetings/) {

		%parameters = (
			meetings => 1,
			date     => get_date(qw(meetings_content.tmpl)),
		);
	} elsif ($file =~ m/yapc/) {
		%parameters = (
			yapc     => 1,
			date     => get_date(qw(yapc_content.tmpl)),
		);
	} elsif ($file =~ m/library/) {
		%parameters = (
			library  => 1,
			date     => get_date(qw(library_content.tmpl BooksData.pm)),
		);
	} elsif ($file =~ m/misc/) {
		%parameters = (
			misc     => 1,
			date     => get_date(qw(misc_content.tmpl)),
		);
	} elsif ($file =~ m/business.html$/) {
		%parameters = (
			business => 1,
			date     => get_date(qw(business_content.tmpl)),
		);
	} elsif ($file =~ /error.html$/) {
		%parameters = (
			error    => 1,
			date     => get_date(qw(error.tmpl)),
		);
	}
	return %parameters;
}


#########################  end Hebrew pages



sub get_unique_params {
	my $file = shift;
	my %parameters;
	if ($file =~ m/index/) {
		%parameters = (
			homepage => 1,
			date             => get_date(qw(index_content.tmpl related_sites_list.tmpl)),
			title            => "Israel.pm - Perl in Israel",
			meta_description => "The homepage of Israel.pm, the Israeli Perl Mongers",
			left_bar_title   => 'Home',
			left_bar         => [
				{ ref => 'introduction'       , title => 'Introduction'              , text => 'Introduction'              },
				{ ref => 'next_il_pm_meeting' , title => 'Next Israel.pm Meeting'    , text => 'Next Israel.pm Meeting'    },
				{ ref => 'next_jm_pm_meeting' , title => 'Next Jerusalem.pm Meeting' , text => 'Next Jerusalem.pm Meeting' },
			],
		);
	} elsif ($file =~ m/about/) {
		%parameters = (
			about             => 1,
			date              => get_date(qw(about_content.tmpl)),
			title             => "About the Israeli Perl Mongers",
			meta_description  => "Describes what Perl Mongers are in geberal and specifically who the Israeli Perl Mongers are.",
			left_bar_title    => 'About Us',
			left_bar          => [
				{ ref => 'introduction' , title => 'Introduction'               , text => 'Introduction'     },
				{ ref => 'officers'     , title => 'Current Israel.pm officers' , text => 'Current Officers' },
				{ ref => 'history'      , title => 'History of Israel.pm'       , text => 'History'          },
				{ ref => 'about_site'   , title => 'About this site'            , text => 'About This Site'  },
			],
			people   => $people,
		);
	} elsif ($file =~ m/mailing/) {
		%parameters = (
			mailing          => 1,
			date             => get_date(qw(mailing_lists_content.tmpl)),
			title            => "Israel.pm Mailing Lists",
			meta_description => "A listing of the Israeli Perl Mongers mailing lists.",
			left_bar_title   => 'Mailing Lists',
			left_bar         => [
				{ ref => 'overview'       , title => 'Israel.pm Mailing Lists Overview'    , text => 'Overview'                    },
				{ ref => 'israel.pm'      , title => 'The main Israel.pm mailing list'     , text => 'Israel.pm Mailing List'      },
				{ ref => 'jerusalem.pm'   , title => 'Mailing list of the Jerusalem group' , text => 'Jerusalemm.pm Mailing List'  },
				{ ref => 'rehovot.pm'     , title => 'Mailing list of the Rehovot group'   , text => 'Rehovot.pm Mailing List'  },
				{ ref => 'news'           , title => 'Israel.pm News Announcements'        , text => 'News Announcements'          },
				#{ ref => 'website'        , title => 'Website Mailing List'                , text => 'Website Mailing List'        },
				#{ ref => 'website-commit' , title => 'Website-Commit Mailing List'         , text => 'Website-Commit Mailing List' },
				{ ref => 'statistics'     , title => 'Some mailing list statistics'        , text => 'Statistics'                  },
			],
		);
	} elsif ($file =~ m/meetings/) {
        use AllMeetings;

        my %meetings = get_all_meetings();

		my %past_annual; # We'll collect the monthly meetins in a temporary hash and then put them
		my @past;        # in this array - one entry for each year.
		my @future;
		foreach my $filename (sort keys %meetings) {
			my ($year, $month, $day) = unpack "a4 a2 a2", $filename;
			my $time_then = mktime(0, 0, 18, $day, $month-1, $year-1900);

			my $comment;
			if ($meetings{$filename}{items}) {
				$comment  = "$meetings{$filename}{location} (";
				$comment .= qq($_->{speaker} - "$_->{title}"; ) foreach @{$meetings{$filename}{items}};
				$comment .= ")";
			} else {
				$comment = $meetings{$filename}{comment},
			}

			my %entry = (
				title    => strftime("%d %B, %Y" , localtime $time_then),
				filename => "meetings/$year/$filename.html",
				comment  => $comment,
			);
			my %rss_entry = (
				title    => strftime("%d %B, %Y" , localtime $time_then),
				filename => "meetings/$year/$filename.html",
				comment  => $comment,
				items    => $meetings{$filename}{items},
			);
			if ($time_then < time) {
				push @{$past_annual{$year}}, \%entry;
			} else {
				push @future, \%entry;
				add_rss_entry(\%rss_entry) if $rss;
			}
		}
		foreach my $year (sort keys %past_annual) {
			push @past, { year => $year, meetings => $past_annual{$year}};
		}
		#print Dumper \@past;
		#print Dumper \%past_annual;
		#print Dumper \@future;

		%parameters = (
			past_meetings    => \@past,
			future_meetings  => \@future,
			meetings         => 1,
			date             => get_date(qw(meetings_content.tmpl)),
			title            => "Israel.pm Meetings",
			meta_description => "About Israel.pm's meetings, past and future.",
			left_bar_title   => 'Meetings',
			left_bar         => [
				{ ref => 'future_meetings' , title => 'Info about future meetings' , text => 'Future Meetings'    },
				{ ref => 'about_meetings'  , title => 'About Our Meetings'         , text => 'About Our Meetings' },
				{ ref => 'past_meetings'   , title => 'Archives of past meetings'  , text => 'Past Meetings'      },
			],
		);
	} elsif ($file =~ m/yapc/) {
		%parameters = (
			yapc             => 1,
			date             => get_date(qw(yapc_content.tmpl)),
			title            => "Israel.pm Conferences",
			meta_description => "About Israel.pm's conferences, past and future.",
			left_bar_title   => 'Conferences',
			left_bar         => [
				{ ref => 'introduction' , title => 'Introduction'       , text => 'Introduction'       },
				{ ref => 'yapc-2006'    , title => 'OSDC::Israel::2005' , text => 'OSDC::Israel::2005' },
				{ ref => 'yapc-2005'    , title => 'YAPC::Israel::2005' , text => 'YAPC::Israel::2005' },
				{ ref => 'yapc-2004'    , title => 'YAPC::Israel::2004' , text => 'YAPC::Israel::2004' },
				{ ref => 'yapc-2003'    , title => 'YAPC::Israel::2003' , text => 'YAPC::Israel::2003' },
			],
		);
	} elsif ($file =~ m/library/) {
		%parameters = (
			library          => 1,
			date             => get_date(qw(library_content.tmpl BooksData.pm)),
			title            => "Israel.pm's Library",
			meta_description => "About Israel.pm's library of Perl and computing related books.",
			left_bar_title   => 'Library',
			left_bar => [
				{ ref => 'introduction' , title => 'Introduction'     , text => 'Introduction'     },
				{ ref => 'sponsors'     , title => 'List of sponsors' , text => 'List of sponsors' },
				{ ref => 'books'        , title => 'List of books'    , text => 'List of books'    },
			],
			books_table => populate_books_table(),
		);
	} elsif ($file =~ m/misc/) {
		%parameters = (
			misc             => 1,
			date             => get_date(qw(misc_content.tmpl)),
			title            => "Israel.pm Miscellaneous Content",
			meta_description => "Miscellaneous content from the Israeli Perl Mongers",
			left_bar_title   => 'Misc',
			left_bar => [
				{ ref => 'pl_vs_pl'    , title => 'Perl vs. perl'          , text => 'Perl vs. perl' },
				{ ref => 'learn'       , title => 'Learning Perl'          , text => 'Learning Perl' },
                { ref => 'material'    , title => "Talks' Material",       , text => "Talks' Material", },
				{ ref => 'cpan'        , title => 'CPAN Mirrors'           , text => 'CPAN Mirrors' },
				{ ref => 'projects'    , title => 'Perl Projects in Israel', text => 'Perl Projects in Israel' },
                { ref => 'linkedin'    , title => "LinkedIn Israel.pm Group", text => "LinkedIn Israel.pm Group" },
			],
		);
	} elsif ($file =~ m/business.html$/) {
		%parameters = (
			business         => 1,
			date             => get_date(qw(business_content.tmpl)),
			title            => "Israel.pm Perl in Business",
			meta_description => "Using Perl in Business activities",
			left_bar_title   => 'Business',
			left_bar => [
				{ ref => 'jobs'         , title => 'Perl related jobs'      , text => 'Perl Related Jobs in Israel' },
				{ ref => 'commercial'   , title => 'Commercial Support'     , text => 'Commercial Support'          },
				{ ref => 'who_uses_perl', title => 'Who Uses Perl in Israel', text => 'Who Uses Perl in Israel'     },
			],
		);
	} elsif ($file =~ /error.html$/) {
		%parameters = (
			error            => 1,
			date             => get_date(qw(error.tmpl)),
			title            => "Israel.pm - Error page",
			meta_description => "Error on the Israeli Perl Mongers",
		);
	} elsif ($file =~ m/israeli-projects/) {
		%parameters = (
			israeliproj      => 1,
			date             => get_date(qw(israeli-projects_content.tmpl)),
			title            => "Israeli Perl Projects",
			meta_description => "Perl Projects Initiated or Maintained by Israelis",
			left_bar_title   => 'Projects',
		);
	} elsif ($file =~ m/learning-perl/) {
		%parameters = (
			learnperl      => 1,
			date             => get_date(qw(learning-perl_content.tmpl)),
			title            => "Learning Perl",
			meta_description => "How to Learn Perl",
			left_bar_title   => 'Learn Perl',
		);
	}
	return %parameters;
}

sub get_date {
	my @files = map {"$Bin/../new_site_sources/templates/$_"} (@_ , qw(right_sidebar.tmpl footer.tmpl main.tmpl));
	my @times;
	for (@files) {
		push @times , (stat)[9];
	}
	return scalar localtime((sort {$a <=> $b} @times)[-1]);
}

sub populate_books_table {
	my $books_array_ref;
	my $number = 1;
	for my $name (sort keys %$books) {
		my $isbn      = $books->{$name}->{"details"}->[-1];
		my $publisher = $books->{$name}->{"details"}->[0];
		my $cuser     = $books->{$name}->{"users"}->[0];
		if (ref $cuser eq 'ARRAY') {
			die "array as cuser for '$name' - please fix.";
		}
		if (-e "$outfiles_basedir/books/$isbn.html") {
			$name = '<a href="books/' . $isbn . '.html">' . CGI::escapeHTML($name) . "</a>";
		}
		push @{$books_array_ref} , { number => $number, name => $name, isbn => $isbn, publisher => $publisher , cuser => $cuser};
		++$number;
	}
	return $books_array_ref;
}


sub add_rss_entry {
	my $entry = shift;
	return if not $entry->{items};
	return if not $rss;

	foreach my $item (@{$entry->{items}}) {
		my $comment = $entry->{comment};
		$comment .= $item->{description} if $item->{description};
		$comment =~ s/</&lt;/g;
		$comment =~ s/>/&gt;/g;

		$rss->add_item(
			title        => $item->{title},
#			permaLink    => $url,
#			enclosure    => { url=> "$url$entry->{filename}"},
			description  => $comment,
#			'link'       => $url,
			'link'       => "$url$entry->{filename}",
			author       => $item->{speaker},
			pubDate      => $entry->{title},
			category     => "Meetings",
		);
	}
}

# The End !!!
