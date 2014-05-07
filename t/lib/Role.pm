use strict;
use warnings;
package Role;

use Role::Tiny 1.003000;    # for is_role, used by our heuristic
use Scalar::Util 'reftype';
use namespace::clean;

sub role_stuff {}

1;
