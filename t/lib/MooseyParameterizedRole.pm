use strict;
use warnings;
package MooseyParameterizedRole;

use MooseX::Role::Parameterized;
with 'MooseyRole';
use Scalar::Util 'reftype';
use namespace::clean;

parameter foo => ( is => 'ro', isa => 'Str' );

role {
    1;
};

sub parameterized_role_stuff {}

1;
