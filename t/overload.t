use strict;
use warnings;
use Test::Tester;
use Test::More;
use Test::Fatal;

use Test::CleanNamespaces;
use lib 't/lib';

{
    my $package = 'Overloader';

    my (undef, @results) = run_tests(sub { namespaces_clean($package) });
    cmp_results(
        \@results,
        [ {
            ok => 1,
            name => $package . ' contains no imported functions',
        } ],
        $package . ' has a clean namespace',
    );

    like(
        exception { $package->stuff },
        qr/Can't locate object method "stuff" via package "$package"/,
        'cannot call stuff as a class method on ' . $package . ' - it was cleaned',
    );

    my $obj = $package->new(val => 42);

    is("$obj", '42', 'string overload works');
    is($obj + 1, 43, 'numeric overload works');
}

done_testing;
