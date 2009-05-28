use strict;
use warnings;

package ExporterModule;
our $VERSION = '0.02';


use Sub::Exporter -setup => {
    exports => ['stuff'],
};

sub stuff { }

1;
