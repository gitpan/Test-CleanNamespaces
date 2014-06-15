use strict;
use warnings FATAL => 'all';

use Test::More;
use Test::Requires { 'Moose' => '()' };
use Test::Deep;
use Module::Runtime 'require_module';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(MooseyDirty))
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

foreach my $package (qw(MooseyClean MooseyRole MooseyComposer MooseExporter))
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

done_testing;
