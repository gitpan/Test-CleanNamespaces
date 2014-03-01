use strict;
use warnings;

package SubExporterModule;

use Sub::Exporter -setup => {
    exports => ['stuff'],
};

sub stuff { }

1;
