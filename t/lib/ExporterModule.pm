use strict;
use warnings;

package ExporterModule;
our $VERSION = '0.01';


use Sub::Exporter -setup => {
    exports => ['stuff'],
};

sub stuff { }

1;
