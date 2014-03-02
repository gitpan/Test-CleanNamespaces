use strict;
use warnings;

use Test::Tester;
use Test::More;
use Test::Requires 'Role::Tiny';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(Role Composer))
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

    ok(!$package->can('refaddr'), 'refaddr import not still available');
}

done_testing;
