
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Test-CleanNamespaces',
  NAME      => 'Test::CleanNamespaces',
  AUTHOR    => 'Florian\ Ragwitz\ \<rafl\@debian\.org\>',
  ABSTRACT  => 'Check for uncleaned imports',
  VERSION   => '0.02',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "File::Find::Rule" => '0',
    "namespace::autoclean" => '0',
    "Class::MOP" => '0',
    "File::Find::Rule::Perl" => '0',
    "Sub::Exporter" => '0',
    "Test::Tester" => '0',
    "Sub::Name" => '0',
    "Test::Builder" => '0',
    "File::Spec::Functions" => '0',
  },
);
