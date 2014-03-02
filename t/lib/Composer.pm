use strict;
use warnings;
package Composer;

use parent 'Clean';
use Role::Tiny 'with';
with 'Role';
use Scalar::Util 'weaken';
use namespace::clean;

sub child_stuff {}

1;
