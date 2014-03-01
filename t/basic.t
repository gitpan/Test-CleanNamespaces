use strict;
use warnings;
use Test::Tester;
use Test::More;
use Test::Fatal;

use Test::CleanNamespaces;

use lib 't/lib';

{
    my (undef, @results) = run_tests(sub { namespaces_clean('Test::CleanNamespaces') });
    cmp_results(
        \@results,
        [ {
            ok => 1,
            name => 'Test::CleanNamespaces contains no imported functions',
        } ],
        'namespaces_clean success',
    );
}

{
    my (undef, @results) = check_test(sub { namespaces_clean('DoesNotCompile') }, {
        ok => 1,
        type => 'skip',
    }, 'namespace_clean compilation fail');

    like($results[0]{reason}, qr/failed to load/, 'useful diagnostics on compilation fail')
        or diag 'got result: ', explain(\@results);
}

foreach my $package (qw(Dirty SubDirty))
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

    like($results[0]{diag}, qr/remaining imports/, $package . ': diagnostic mentions "remaining imports"')
        or diag 'got result: ', explain(\@results);
    like($results[0]{diag}, qr/'stuff'\s+=>\s+'(Sub)?ExporterModule::stuff'/,
        $package . ': diagnostic lists the remaining imports')
        or diag 'got result: ', explain(\@results);

    can_ok($package, 'method');
    is($package->callstuff, 'called stuff', $package . ' called stuff via other sub');

    is(
        exception { $package->stuff },
        undef,
        'can call stuff as a class method on ' . $package . ' - it was not cleaned',
    );
}

foreach my $package (qw(Clean SubClean))
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

    can_ok($package, 'method');
    is($package->callstuff, 'called stuff', $package . ' called stuff via other sub');

    like(
        exception { $package->stuff },
        qr/Can't locate object method "stuff" via package "$package"/,
        'cannot call stuff as a class method on ' . $package . ' - it was cleaned',
    );
}

ok(!exists($INC{'Class/MOP.pm'}), 'Class::MOP has not been loaded');

done_testing;
