use strict;
use warnings;
package Clean;

use ExporterModule qw/stuff/;
use namespace::clean;   # clean 'stuff' at end of compilation

sub method { }

sub callstuff { stuff(); 'called stuff' }

1;
