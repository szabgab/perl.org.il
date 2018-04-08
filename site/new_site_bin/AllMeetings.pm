package AllMeetings;

use strict;
use warnings;

use Exporter;
use YAML qw(LoadFile);
use FindBin qw($Bin);

our @ISA = (qw(Exporter));

our @EXPORT = (qw(get_all_meetings));

sub get_all_meetings
{
    my %data;
    for my $file (glob "$Bin/../new_site_sources/meetings*.yml") {
        #print "Processing $file\n";
        my $r = LoadFile($file); 
        %data = (%data, %$r);
    }
    return %data;
}

1;
