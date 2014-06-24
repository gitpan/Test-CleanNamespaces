use strict;
use warnings FATAL => 'all';

use Test::More;

# blech! but Test::Requires does a stringy eval, so this works...
use Test::Requires { 'Moose' => '()', 'MooseX::Role::Parameterized' => '()' };

use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Deep;
use Module::Runtime 'require_module';
use Test::CleanNamespaces;

use lib 't/lib';

foreach my $package (qw(MooseyParameterizedRole MooseyParameterizedComposer))
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
