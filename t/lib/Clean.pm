use strict;
use warnings;
package Clean;

use ExporterModule qw/stuff/;
use Scalar::Util 'refaddr';
use namespace::clean;

sub method { }

sub callstuff { stuff(); 'called stuff' }

1;
