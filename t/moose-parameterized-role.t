use strict;
use warnings;

use Test::Tester;
use Test::More;

# blech! but Test::Requires does a stringy eval, so this works...
use Test::Requires { 'Moose' => '()', 'MooseX::Role::Parameterized' => '()' };
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(MooseyParameterizedRole MooseyParameterizedComposer))
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
        if $package eq 'MooseyParameterizedComposer';

    ok($package->can('role_stuff'), 'role_stuff method from role is still available');

    ok(!$package->can('refaddr'), 'refaddr import not still available');

    ok(!$package->can($_), "$_ import not still available") foreach qw(refaddr weaken reftype);
}

done_testing;
