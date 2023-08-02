use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker;
WriteMakefile
(
    NAME          => 'App',
    AUTHOR        => 'Gabor Szabo <szabgab@cpan.org>',
    VERSION       => '1.00',
    ABSTRACT      => 'perl.org.il',
    LICENSE       => 'perl',
    PREREQ_PM     => {
        'File::Copy::Recursive' => 0,
        'HTML::Template'        => 0,
        #Alien::Tidyp HTML::Tidy Acme::CPANAuthors CGI CPANPLUS::Backend Data::Dumper Exporter Fcntl File::Basename File::Copy::Recursive File::Path File::Spec File::Temp FindBin Geo::IP Getopt::Long HTML::Template HTML::TokeParser List::MoreUtils LWP::Simple Test::HTML::Tidy::Recursive::Strict Test::More YAML
    },
    TEST_REQUIRES => {
        'Test::More' => '0.47'
    },
);

