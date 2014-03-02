use strict;
use warnings;
package Dirty;

use ExporterModule qw/stuff/;

sub method { }

sub callstuff { stuff(); 'called stuff' }

1;
