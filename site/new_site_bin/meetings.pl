#!/usr/bin/perl -w
use strict;
use warnings;
use HTML::Template;
use Getopt::Long qw(GetOptions);
use FindBin qw($Bin);
use File::Basename qw(basename dirname);
use File::Path qw(mkpath);
use POSIX qw(mktime strftime);
use lib $Bin;

############################################################################### 
# This is the Perl script for creating the meeting pages (20041104.html, etc.) 
# from the info in this file.
############################################################################### 

my $outfiles_basedir;
GetOptions("outdir=s" => \$outfiles_basedir) or die;
die if not $outfiles_basedir;

use Common;

use AllMeetings;

my %meetings = get_all_meetings();

my $template_file       = "$Bin/../new_site_sources/templates/meetings_main.tmpl";
my @outfiles = map { if(m/^(\d{4})/) {"$outfiles_basedir/meetings/$1/$_.html"} } keys %meetings;

for my $output_file (@outfiles) {
	my $template = HTML::Template->new(filename => $template_file , loop_context_vars => 1, global_vars => 1,);
	$template->param(
		get_unique_params($output_file),
		meta_keywords => "Perl, perl, Mongers, mongers, meeting, meetings",
		date => get_date(qw(meetings_main.tmpl)),
		meta_description => 'Meeting details and report page.',
		left_bar_title => 'Sections',
		left_bar => [
			{ ref => 'agenda', title => 'Meeting agenda', text => 'Agenda' },
			{ ref => 'report', title => 'Meeting report', text => 'Report' },
		],
        get_common_tmpl_params(),
	);
	# Print the template output
	my $dir = dirname $output_file;
	mkpath $dir if not -e $dir;
	open(OUT,">:encoding(utf8)", $output_file) or die "Couldn't open $output_file for writing: $!\n";
	print OUT $template->output;
	close(OUT) or die "Couldn't close $output_file after writing: $!\n";
}

sub get_date {
	my @files = map {"$Bin/../new_site_sources/templates/$_"} (@_ , qw(right_sidebar.tmpl footer.tmpl));
	my @times;
	for (@files) {
		push @times , (stat)[9];
	}
	return scalar localtime((sort {$a <=> $b} @times)[-1]);
}
sub get_unique_params {
	my $filename = basename($_[0],".html");
	my ($year, $month, $day) = unpack "a4 a2 a2", $filename;
	my $time_then = mktime(0, 0, 18, $day, $month-1, $year-1900);
	my %parameters = (
		title            => "Israel.pm - Meeting Page for $filename Meeting",
		day_and_date     => strftime("%d %B, %Y" , localtime $time_then),
		past             => ($time_then < time),
		agenda_items     => $meetings{$filename}->{"agenda_items"},
		participants     => $meetings{$filename}->{"participants"},
		report_text      => $meetings{$filename}->{"report_text"},
		other_summarizer => $meetings{$filename}->{"other_summarizer"},
		report_exists    => (($meetings{$filename}->{"report_text"} =~ m/^\s+$/) ? 0 : 1),
        location         => $meetings{$filename}->{"location"},
	);
	return %parameters;
}

# The End !!!
#
