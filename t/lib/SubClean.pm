use strict;
use warnings;
package SubClean;

use SubExporterModule qw/stuff/;
use namespace::clean;   # clean 'stuff' at end of compilation

sub method { }

sub callstuff { stuff(); 'called stuff' }

1;
