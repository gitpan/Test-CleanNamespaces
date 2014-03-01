use strict;
use warnings;

package SubDirty;

use SubExporterModule qw/stuff/;

sub method { }

sub callstuff { stuff(); 'called stuff' }

1;
