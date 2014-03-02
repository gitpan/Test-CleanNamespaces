use strict;
use warnings;
package MouseyComposer;

use Mouse;
extends 'MouseyClean';
with 'MouseyRole';
use Scalar::Util 'weaken';
use namespace::clean;

sub child_stuff {}

1;
