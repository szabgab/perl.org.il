#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use Fcntl qw(:flock);

my @sites =qw(
	      perl.org.il 
	      perl.org 
	      perl.com 
	      plover.com 
	      perlmonks.org
	      perldoc.com
	      cpan.org
	      yapc.org
	      archive.develooper.com
	      );
# search.cpan.org
# perldoc.com
# stonhenge.com
# ?
=pod
http://www.perlpod.com/
http://groups.google.com/groups?group=comp.lang.perl
http://groups.google.com/groups?group=comp.lang.perl.announce
http://groups.google.com/groups?group=comp.lang.perl.misc
http://groups.google.com/groups?group=comp.lang.perl.moderated
http://groups.google.com/groups?group=comp.lang.perl.modules
http://groups.google.com/groups?group=comp.lang.perl.tk
http://www.tek-tips.com/gthreadminder.cfm/lev2/4/lev3/32/pid/219
http://www.experts-exchange.com/Programming/Programming_Languages/Perl/
http://www.webreference.com/perl/
http://www.rexswain.com/perl5.html
http://www.codebits.com/p5be/
http://www.oopweb.com/Perl/Files/Perl.html
http://www.perlfaq.com/
=cut


my $q = new CGI;
my $time = localtime;

#my $group = 1; # perl.org.il

my $group = defined $q->param('group') ? $q->param('group') : '1';

my $term = defined $q->param('term') ? $q->param('term') : '';
warn "Search:$time | $group | $term\n";

my $url = "http://www.google.com/custom?q=$term";
if ($group eq "1") {
   $url .= "&domains=www.perl.org.il&sitesearch=www.perl.org.il";
} else {
   $url .=  "+site%3A" . join "+OR+site%3A", @sites;
}

print $q->redirect($url);


