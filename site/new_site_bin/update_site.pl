#!/usr/bin/perl -w
use strict;

use FindBin      qw($Bin);
use File::Temp   qw(tempdir);
use Getopt::Long qw(GetOptions);
#use Mail::Sendmail qw(sendmail);

use File::Path qw(mkpath);
use File::Copy::Recursive qw(rcopy fcopy);
use File::Spec;


my $SVNLOOK = '/usr/bin/svnlook';

my %opts;
GetOptions(\%opts, "revision=s", "repo=s", 'help', 'outdir=s') or usage();
usage() if $opts{help};

my $outdir = $opts{outdir};
usage("Outdir '$outdir' does not exist") if not $outdir or not -d $outdir;

eval "use HTML::Template";
if ($@) {
	die "Need HTML::Template installed to run\n";
}

my $dir = tempdir(CLEAUP => 1);


copy_static_files($outdir);

# We don't have the library any more
system("$^X $Bin/books.pl     --outdir $outdir    2>> $dir/err");
system("$^X $Bin/meetings.pl  --outdir $outdir    2>> $dir/err");
system("$^X $Bin/main.pl      --outdir $outdir    2>> $dir/err");

use Test::HTML::Tidy::Recursive::Strict;

Test::HTML::Tidy::Recursive::Strict->new(
    {
        filename_filter => sub { return shift !~ m#/presentations/#; },
        targets => [$outdir],
    }
)->run;

my $err;
if (open my $fh, "<", "$dir/err") {
	local $/;
	$err = <$fh>;
}

#if ($opts{sendmail}) {
#	my $text = '';
#	if ($opts{revision} and $opts{repo}) {
#		my $author = `$SVNLOOK author -r $opts{revision} $opts{repo}`;
#		$text .= "Author: $author\n";
#		$text .= "Revision: $opts{revision}\n";
#		$text .= "Repo: $opts{repo}\n";
#		$text .= "\n\n";
#		$text .= `$SVNLOOK log -r $opts{revision} $opts{repo}`;
#		$text .= "\n\n";
#		$text .= `$SVNLOOK diff -r $opts{revision} $opts{repo}`;
#		$text .= "\n\n";
#	}
#	my $subject = ($err ? 'Error' : 'Success' ) . ' in the perl.org.il web creation script';
#	if ($err) {
#		$text .= "Errors:\n\n";
#		$text .= $err;
#		$text .= "\n\n";
#	}
#	my %mail = (
#		To       => 'gabor@perl.org.il',
##		Cc       => 'offer.kaye@gmail.com',
#		From     => 'gabor@perl.org.il',
#		Subject  => $subject,
#		Message  => $text,
#	);
#	sendmail(%mail);
#} else {
#	print STDERR $err;
#}

# Copies all the "static" files listed in the MANIFEST file to the target
# directory
# (e.g. "new_site_sources/site").
sub copy_static_files {
    my $outfiles_basedir = shift;

	open my $manifest, "<", "$Bin/../new_site_sources/MANIFEST"
        or die "Could not open $Bin/../new_site_sources/MANIFEST\n";
	while (my $thing = <$manifest>) {
		chomp $thing;
		my $source = "$Bin/../new_site_sources/$thing";
		my $target = File::Spec->catfile($outfiles_basedir, $thing);
		#print "$source -> $target\n";
		rcopy $source, $target or die;
	}
}


sub usage {
    my ($msg) = @_;
    $msg //= "";

	print <<"END_USAGE";
$msg

Usage: $0
           --revision REV
           --repo     REPO
           --help             This help

           --outdir PATH/TO/OUTPUT/DIRECTORY/www
END_USAGE
	exit -1;
}
