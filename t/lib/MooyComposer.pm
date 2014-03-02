use strict;
use warnings;
package MooyComposer;

use Moo;
extends 'MooyClean';
with 'MooyRole';
use Scalar::Util 'weaken';
use namespace::clean;

sub child_stuff {}

1;
