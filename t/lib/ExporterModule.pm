use strict;
use warnings;
package ExporterModule;

use Scalar::Util 'unweaken';
use namespace::clean;

use Exporter 'import';
our @EXPORT_OK = qw(stuff);

sub stuff { }

1;
