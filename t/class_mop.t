use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Requires 'Class::MOP';
use Test::Deep;
use Module::Runtime 'require_module';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(ClassMOPDirty))
{
    require_module($package);
    cmp_deeply(
        Test::CleanNamespaces::_remaining_imports($package),
        superhashof({
            map { $_ => ignore } @{ $package->DIRTY },
        }),
        $package . ' has an unclean namespace - found all uncleaned imports',
    );

    ok($package->can($_), "can do $package->$_") foreach @{ $package->CAN };
    ok(!$package->can($_), "cannot do $package->$_") foreach @{ $package->CANT };
}

foreach my $package (qw(ClassMOPClean))
{
    require_module($package);
    cmp_deeply(
        Test::CleanNamespaces::_remaining_imports($package),
        {},
        $package . ' has a clean namespace',
    );

    ok($package->can($_), "can do $package->$_") foreach @{ $package->CAN };
    ok(!$package->can($_), "cannot do $package->$_") foreach @{ $package->CANT };
}

ok(!exists($INC{'Moose.pm'}), 'Moose has not been loaded');

done_testing;
