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

foreach my $package (qw(MouseyDirty))
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

foreach my $package (qw(MouseyClean MouseyRole MouseyComposer))
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
