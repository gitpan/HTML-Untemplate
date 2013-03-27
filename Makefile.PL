
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "web scraping assistant",
  "AUTHOR" => "Stanislaw Pusep <stas\@sysd.org>",
  "BUILD_REQUIRES" => {
    "HTML::TreeBuilder::XPath" => 0,
    "Path::Class" => 0,
    "Set::CrossProduct" => 0,
    "Test::Script::Run" => 0
  },
  "CONFIGURE_REQUIRES" => {},
  "DISTNAME" => "HTML-Untemplate",
  "EXE_FILES" => [
    "bin/untemplate",
    "bin/xpathify"
  ],
  "LICENSE" => "perl",
  "NAME" => "HTML::Untemplate",
  "PREREQ_PM" => {
    "Class::Load" => 0,
    "HTML::Entities" => 0,
    "HTML::TreeBuilder" => 0,
    "HTTP::Tiny" => 0,
    "IO::Interactive" => 0,
    "JSON" => 0,
    "Moo" => 0,
    "MooX::Types::MooseLike::Base" => 0,
    "Term::ANSIColor" => "4.0",
    "Tie::IxHash" => 0,
    "utf8::all" => 0
  },
  "VERSION" => "0.018",
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



