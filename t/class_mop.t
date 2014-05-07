use strict;
use warnings;

use Test::Tester;
use Test::More;
use Test::Requires 'Class::MOP';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(ClassMOPDirty))
{
    my (undef, @results) = run_tests(sub { namespaces_clean($package) });
    cmp_results(
        \@results,
        [ {
            ok => 0,
            name => $package . ' contains no imported functions',
        } ],
        $package . ' has an unclean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok($package->can('refaddr'), 'refaddr import still available');
}

foreach my $package (qw(ClassMOPClean))
{
    my (undef, @results) = run_tests(sub { namespaces_clean($package) });
    cmp_results(
        \@results,
        [ {
            ok => 1,
            name => $package . ' contains no imported functions',
        } ],
        $package . ' has a clean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok($package->can('stuff'), 'stuff method from base class is still available')
        if $package eq 'ClassMOPClean' or $package eq 'ClassMOPComposer';

    ok($package->can('role_stuff'), 'role_stuff method from role is still available')
        if $package eq 'ClassMOPRole' or $package eq 'ClassMOPComposer';

    ok(!$package->can($_), "$_ import not still available") foreach qw(refaddr weaken reftype);
}

ok(!exists($INC{'Moose.pm'}), 'Moose has not been loaded');

done_testing;
