#!/usr/bin/perl -w
use strict;
use warnings;
use HTML::Template;
use Getopt::Long qw(GetOptions);
use FindBin qw($Bin);
use YAML qw(LoadFile);

use lib $Bin;

use Common;

############################################################################### 
# This is the Perl script for creating the book pages (0596003102.html, etc.) 
# from the info in this file.
############################################################################### 

my %opts;
GetOptions(\%opts, "outdir=s");

my $books = LoadFile("$Bin/../new_site_sources/books.yml");

my $template_file       = "$Bin/../new_site_sources/templates/books_main.tmpl";
my $outfiles_basedir    = $opts{outdir} || "$Bin/../new_site_sources/site";
$outfiles_basedir    .= "/books";
my @outfiles = map { "$outfiles_basedir/$_" } (
	'0596000278.html',
	'1565926099.html',
	'1565924193.html',
	'1565923987.html',
	'1565924495.html',
	'059600012X.html',
	'1565922514.html',
	'1565926730.html',
	'1930110820.html',
	'1930110006.html',
	'0596004419.html',
	'0596003560.html',
	'0130652067.html',
	'073571228X.html',
	'157870216X.html',
	'0735711216.html',
	'0735711100.html',
	'1930110022.html',
	'1884777805.html',
	'1930110065.html',
	'1893115879.html',
	'159059018X.html',
	'1590590082.html',
	'1893115461.html',
	'0596003102.html',
	'0596002890.html',
	'0596002254.html',
	'0201633612.html',
	'020161586X.html',
	'0201485672.html',
	'0201710145.html',
	'0201419750.html',
	'020165783X.html',
	'1884777791.html',
	'1565926536.html',
	'0596002874.html',
	'0596001320.html',
	'0596000804.html',
	'1565927168.html',
	'059600205X.html',
	'0596001789.html',
	'059600219X.html',
	'0596002068.html',
	'0596002106.html',
	'0596001193.html',
	'0596000952.html',
	'0596001002.html',
	'0596002033.html',
	'0596003811.html',
	'0596004508.html',
	'0072129506.html',
	'0596003129.html',
	'0072133872.html',
	'0072226463.html',
	'0072132329.html',
	'0596002270.html',
	'1893115739.html',
	'1565926994.html',
	'0201612445.html',
	'0672323060.html',
	'0201771683.html',
	'0201648652.html',
	'0201615711.html',
	'0596003803.html',
	'0201773457.html',
	'0201733862.html',
	'0201771373.html',
	'0201710919.html',
	'1590591119.html',
	'0130282510.html',
	'1590590171.html',
	'0131111558.html',
	'020177061X.html',
	'1565922921.html',
	'156592262X.html',
    '1558607013.html',
);

for my $output_file (@outfiles) {
	my $isbn;
	if ($output_file =~ m/([\dxX]+)\.html$/) {
		$isbn = $1;
	}
	my $template = HTML::Template->new(filename => $template_file , loop_context_vars => 1, global_vars => 1,);
	$template->param(
		get_unique_params($output_file,$isbn),
		meta_keywords    => "Perl, perl, Mongers, mongers, book, Book, books, Books",
		date             => get_date(qw(books_main.tmpl)),
		meta_description => 'Book page - Info and Reviews',
		left_bar_title   => 'Sections',
		left_bar         => [
			{ ref => 'info'    , title => 'Book Information' , text => 'Book Information' },
			{ ref => 'reviews' , title => 'Book Reviews'     , text => 'Book Reviews'     },
		],
        books => "1",
        get_common_tmpl_params(),
	);
	# Print the template output
	open(OUT,">$output_file") or die "Couldn't open $output_file for writing: $!\n";
	print OUT $template->output;
	close(OUT) or die "Couldn't close $output_file after writing: $!\n";
}

sub get_unique_params {
	my ($file,$isbn) = @_;
	my $title = get_title($isbn);
	my %parameters = (
		title            => $title,
		pub_book_page    => get_link($title),
		amazon_book_page => "http://www.amazon.com/exec/obidos/ASIN/$isbn/",
		book_info => [
			{ dt => 'Title'           , dd => $title                },
			{ dt => 'ISBN'            , dd => $isbn                 },
			{ dt => 'Author/Editor'   , dd => get_author($title)    },
			{ dt => 'Publisher'       , dd => get_publisher($title) },
			{ dt => 'Publishing date' , dd => get_pub_date($title)  },
			{ dt => 'Pages'           , dd => get_pages($title)     },
		],
		book_cover_image => get_image($title),
		book_reviews     => get_reviews($title),
	);
	return %parameters;
}

sub get_date {
	my @files = map {"$Bin/../new_site_sources/templates/$_"} (@_ , qw(right_sidebar.tmpl footer.tmpl));
	my @times;
	for (@files) {
		push @times , (stat)[9];
	}
	return scalar localtime((sort {$a <=> $b} @times)[-1]);
}

sub get_title {
	my $isbn = shift;
	my $book_name;
	for my $name (sort keys %$books) {
		if ($books->{$name}->{"details"}->[-1] eq $isbn) {
			$book_name = $name;
			last;
		}
	}
	return $book_name;
}

sub get_link {
	my $title = shift;
	return $books->{$title}->{"link"};
}

sub get_author {
	my $title = shift;
	return $books->{$title}->{"author"};
}

sub get_publisher {
	my $title = shift;
	return $books->{$title}->{"details"}->[0];
}

sub get_pub_date {
	my $title = shift;
	return $books->{$title}->{"details"}->[2];
}

sub get_pages {
	my $title = shift;
	return $books->{$title}->{"details"}->[3];
}

sub get_image {
	my $title = shift;
	return $books->{$title}->{"book_cover_image"};
}

sub get_reviews {
	my $title = shift;
	return $books->{$title}->{"book_reviews"};
}

# The End !!!
