
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "web scraping assistant",
  "AUTHOR" => "Stanislaw Pusep <stas\@sysd.org>",
  "BUILD_REQUIRES" => {
    "Data::Dumper" => 0,
    "File::Find" => 0,
    "FindBin" => 0,
    "HTML::TreeBuilder::XPath" => 0,
    "Path::Class" => 0,
    "Set::CrossProduct" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "HTML-Untemplate",
  "EXE_FILES" => [
    "bin/untemplate",
    "bin/xpathify"
  ],
  "LICENSE" => "perl",
  "NAME" => "HTML::Untemplate",
  "PREREQ_PM" => {
    "Any::Moose" => 0,
    "Digest::SHA" => 0,
    "File::Basename" => 0,
    "File::Temp" => 0,
    "Getopt::Long" => 0,
    "HTML::TreeBuilder" => 0,
    "IO::Interactive" => 0,
    "JSON::XS" => 0,
    "List::Util" => 0,
    "Module::Load" => 0,
    "MouseX::NativeTraits" => 0,
    "MouseX::NonMoose" => 0,
    "Pod::Usage" => 0,
    "Term::ANSIColor" => "3.0",
    "Tie::IxHash" => 0,
    "feature" => 0,
    "open" => 0,
    "overload" => 0,
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.011",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



