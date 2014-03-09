use strict;
use warnings;

use Test::Tester;
use Test::More;
use Test::Requires 'Moo';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(MooyDirty))
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

foreach my $package (qw(MooyClean MooyRole MooyComposer))
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
        if $package eq 'MooClean' or $package eq 'MooComposer';

    ok($package->can('role_stuff'), 'role_stuff method from role is still available')
        if $package eq 'MooRole' or $package eq 'MooComposer';

    ok(!$package->can($_), "$_ import not still available") foreach qw(refaddr weaken reftype);
}

done_testing;
