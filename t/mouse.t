use strict;
use warnings;

use Test::Tester;
use Test::More;

BEGIN {
    local $ENV{RELEASE_TESTING};    # so Test::Requires does not die if Mouse not installed
    use Test::Requires 'Mouse';
}
use Test::CleanNamespaces;

use lib 't/lib';

{
    my (undef, @results) = run_tests(sub { namespaces_clean('MouseyDirty') });
    cmp_results(
        \@results,
        [ {
            ok => 0,
            name => 'MouseyDirty contains no imported functions',
        } ],
        'MouseyDirty has an unclean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok(MouseyDirty->can('refaddr'), 'refaddr import still available');
}

{
    my (undef, @results) = run_tests(sub { namespaces_clean('MouseyClean') });
    cmp_results(
        \@results,
        [ {
            ok => 1,
            name => 'MouseyClean contains no imported functions',
        } ],
        'MouseyClean has a clean namespace',
    );
    diag 'got result: ', explain(\@results) if not Test::Builder->new->is_passing;

    ok(!MouseyClean->can('refaddr'), 'refaddr import not still available');
}

done_testing;
