use strict;
use warnings;

use Test::Tester;
use Test::More;
use Test::Requires { 'Role::Tiny' => '1.003000' };
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(Clean Role Composer))
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

    ok($package->can('method'), 'method from base class is still available')
        if $package eq 'Clean' or $package eq 'Composer';

    ok($package->can('role_stuff'), 'role_stuff method from role is still available')
        if $package eq 'Role';

    ok(!$package->can($_), "$_ import not still available") foreach qw(refaddr weaken reftype);
}

done_testing;
