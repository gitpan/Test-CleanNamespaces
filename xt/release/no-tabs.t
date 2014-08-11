use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.08

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Test/CleanNamespaces.pm',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/basic.t',
    't/class_mop.t',
    't/clean-namespaces.t',
    't/lib/ClassMOPClean.pm',
    't/lib/ClassMOPDirty.pm',
    't/lib/Clean.pm',
    't/lib/Composer.pm',
    't/lib/Dirty.pm',
    't/lib/DoesNotCompile.pm',
    't/lib/ExporterModule.pm',
    't/lib/MooseExporter.pm',
    't/lib/MooseyClean.pm',
    't/lib/MooseyComposer.pm',
    't/lib/MooseyDirty.pm',
    't/lib/MooseyParameterizedComposer.pm',
    't/lib/MooseyParameterizedRole.pm',
    't/lib/MooseyRole.pm',
    't/lib/MooyClean.pm',
    't/lib/MooyComposer.pm',
    't/lib/MooyDirty.pm',
    't/lib/MooyRole.pm',
    't/lib/MouseyClean.pm',
    't/lib/MouseyComposer.pm',
    't/lib/MouseyDirty.pm',
    't/lib/MouseyRole.pm',
    't/lib/Overloader.pm',
    't/lib/Role.pm',
    't/lib/SubClean.pm',
    't/lib/SubDirty.pm',
    't/lib/SubExporterModule.pm',
    't/moo.t',
    't/moose-parameterized-role.t',
    't/moose.t',
    't/mouse.t',
    't/overload.t',
    't/role_tiny.t',
    't/self.t',
    'xt/author/00-compile.t',
    'xt/author/pod-spell.t',
    'xt/release/changes_has_content.t',
    'xt/release/clean-namespaces.t',
    'xt/release/cpan-changes.t',
    'xt/release/distmeta.t',
    'xt/release/eol.t',
    'xt/release/kwalitee.t',
    'xt/release/minimum-version.t',
    'xt/release/mojibake.t',
    'xt/release/no-tabs.t',
    'xt/release/pod-coverage.t',
    'xt/release/pod-no404s.t',
    'xt/release/pod-syntax.t',
    'xt/release/portability.t'
);

notabs_ok($_) foreach @files;
done_testing;
