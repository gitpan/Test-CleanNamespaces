use strict;
use warnings;

use Test::Tester;
use Test::More;
use Test::Requires 'Moose';
use Test::CleanNamespaces;

use lib 't/lib';

{
    my (undef, @results) = run_tests(sub { namespaces_clean('MooseyDirty') });
    cmp_results(
        \@results,
        [ {
            ok => 0,
            name => 'MooseyDirty contains no imported functions',
        } ],
        'MooseyDirty has an unclean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok(MooseyDirty->can('refaddr'), 'refaddr import still available');
}

{
    my (undef, @results) = run_tests(sub { namespaces_clean('MooseyClean') });
    cmp_results(
        \@results,
        [ {
            ok => 1,
            name => 'MooseyClean contains no imported functions',
        } ],
        'MooseyClean has a clean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok(!MooseyClean->can('refaddr'), 'refaddr import not still available');
}

done_testing;
