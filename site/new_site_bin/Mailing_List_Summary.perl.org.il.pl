#! /unix_home/oferk/perl/bin/perl
use strict;
use warnings;
use LWP::Simple;
use HTML::TokeParser;

############################################################################### 
# Mailing_List_Summary.pl:
# ------------------------
# Calculate and print some statistics for perl@perl.org.il mailing list.
# Part 1. of the code gets the URLs of the pages for each month, and then 
# uses the build_data_hash() subroutine to build the (global) data hash.
#
# Part 2. Prints the interesting statistics.
#
# Note: This is a very initial version.
# Version:	0.01
# Date:		April 20, 2003 
# Author :	Offer Kaye (oferk@oren.co.il)
#
# Copyright 2003, Offer Kaye
# This script is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
############################################################################### 


############################################################################### 
# 0. Variables
############################################################################### 
my $initial_url = 'http://mail.perl.org.il/pipermail/perl/';
my $month_names_regexp = qr/January|February|March|April|May|June|July|August|September|October|November|December/o;
my %all_data_hash; # This is a global hash


############################################################################### 
# 1. Get the URLs of the individual pages for each month
############################################################################### 
# Grab the HTML:
my $page_content = get $initial_url;
die "Error! Couldn't get $initial_url\n\n" unless defined $page_content;

# Parse the HTML
my $p = HTML::TokeParser->new(\$page_content);

# Search for a table column (td tag) with a month name, then search for
# the fourth <a> tag.
while (defined($p->get_tag("td"))){
   if (($p->get_text) =~ /$month_names_regexp/) {
      my $a_tag;
      $a_tag = $p->get_tag("a") for (1..4);
      # The following updates %all_data_hash, which is global.
      build_data_hash( $initial_url . $a_tag->[1]->{'href'} );
   }
}

############################################################################### 
# 2. Now that I have the data, it's time to print some statistics.
############################################################################### 
# What I want to print out:
# * The total number of posts and posters for $year.
# * The 10 most frequent posters of $year and their percentages of the total, 
#   sorted by descending order (highest percentage, 2nd highest, etc.), and
#   the sum of those percentages.
# * Posts/Person, Mean Posts/Month, Mean Posters/Month.
############################################################################### 
my $year='2004';
print qq{
*******************************************
Here are some statistics for the year $year:
*******************************************
};
my %total_posters_hash;
for my $month (keys %{$all_data_hash{$year}}) {
   for (keys %{$all_data_hash{$year}{$month}}) {
      $total_posters_hash{$_} += $all_data_hash{$year}{$month}{$_};
   }
}

my $total_year_posts = 0;
my $num_of_posters = 0;
for (keys %total_posters_hash) {
   $total_year_posts += $total_posters_hash{$_};
   ++$num_of_posters;
}
print "In the year $year there were a total of $total_year_posts posts from $num_of_posters people.\n\n";

print "The mean number of posts/person was ";
printf "%3.1f.\n\n",$total_year_posts/$num_of_posters; 

print "The mean number of posts/month was ";
printf "%3.1f.\n\n",$total_year_posts/12; 

print "The mean number of posters/month was ";
printf "%3.1f.\n\n",$num_of_posters/12; 

my $top_ten=0;
print "The 10 top posters of $year, and their percentage of the total number of posts, were:\n";
my @tmp_array = sort { $total_posters_hash{$b} <=> $total_posters_hash{$a} } keys %total_posters_hash;
my $n = 10;
if ($num_of_posters < 10) { $n = $num_of_posters }
for (1 .. $n) {
   print "$_. $tmp_array[$_-1]\t\t";
   printf "%3.1f",$total_posters_hash{$tmp_array[$_-1]}*100/$total_year_posts;
   print "%\n";
   $top_ten += $total_posters_hash{$tmp_array[$_-1]}*100/$total_year_posts;
}
printf "The top 10 posters together posted ";
printf "%3.1f",$top_ten;
print "% of the total number of posts in the year $year.\n";

##DEBUG## use Data::Dumper;
##DEBUG## print Dumper(\%all_data_hash);

sub build_data_hash {
############################################################################### 
# For each URL of all messages for each month, parse the URL and build the  
# data structure %all_data_hash. Example hash:
#
# %all_data_hash = (
#    $year => {
#       January  => {Gabor Szabo => 103 , Offer Kaye => 21} ,
#       February => {Gabor Szabo => 100 , Offer Kaye => 19}
#    }
# );
############################################################################### 
   my %posters_data=();
   my $year;
   my $month;
   if ($_[0] =~ /(\d+)-(\w+)\//) { $year = $1; $month = $2 }
   my $page_content = get $_[0];
   die "Error! Couldn't get $_[0]\n\n" unless defined $page_content;

   # Parse the current page.
   my $p = HTML::TokeParser->new(\$page_content);

   # In each list item (<li> tag), if the <a> tag's "href" attribute matches 
   # /\d+\.html/ then it is a valid entry for an email.
   # The poster's name is after the <i> tag.
   my $li_tag;
   while (defined($li_tag=$p->get_tag("li"))) {
      my $a_tag=$p->get_tag("a");
      if (($a_tag->[1]->{'href'}) =~ /\d+\.html/) {
         $p->get_tag("i");
	 ++$posters_data{$p->get_trimmed_text};
      }
   }

   # For each new year, create a new entry, otherwise add the current month 
   # to the other months for the same year.
   if (defined $all_data_hash{$year}) {
      $all_data_hash{$year} = { $month => {%posters_data} , %{$all_data_hash{$year}} }
   } else {
      $all_data_hash{$year} = { $month => {%posters_data} }
   }
}

# The End!!!
