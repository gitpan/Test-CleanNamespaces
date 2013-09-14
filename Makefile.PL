
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Check for uncleaned imports',
  'AUTHOR' => 'Florian Ragwitz <rafl@debian.org>',
  'BUILD_REQUIRES' => {
    'FindBin' => '0',
    'Test::More' => '0',
    'Test::Tester' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Test-CleanNamespaces',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Test::CleanNamespaces',
  'PREREQ_PM' => {
    'Class::MOP' => '0',
    'File::Find::Rule' => '0',
    'File::Find::Rule::Perl' => '0',
    'File::Spec::Functions' => '0',
    'Sub::Exporter' => '0',
    'Sub::Name' => '0',
    'Test::Builder' => '0',
    'namespace::autoclean' => '0'
  },
  'VERSION' => '0.03',
  'test' => {
    'TESTS' => 't/*.t'
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



