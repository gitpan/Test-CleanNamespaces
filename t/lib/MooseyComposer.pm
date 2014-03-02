use strict;
use warnings;
package MooseyComposer;

use Moose;
extends 'MooseyClean';
with 'MooseyRole';
use Scalar::Util 'weaken';
use namespace::clean;

sub child_stuff {}

1;
