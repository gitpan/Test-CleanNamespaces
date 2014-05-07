use strict;
use warnings;
package MooseExporter;

use Moose::Exporter;
use Moose::Role ();

Moose::Exporter->setup_import_methods(also => 'Moose::Role');

1;
