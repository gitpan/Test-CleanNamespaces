use strict;
use warnings;
package inc::DynamicPrereqs;

use Moose;
with 'Dist::Zilla::Role::InstallTool', 'Dist::Zilla::Role::MetaProvider';
use List::Util 'first';

# this is a horrible hack and I'm doing it much better in its own dist. this
# is very temporary...

sub metadata { return +{ dynamic_config => 1 } }

sub setup_installer
{
    my $self = shift;

    my $file = first { $_->name eq 'Makefile.PL' } @{$self->zilla->files};
    my $content = $file->content;

    $self->log_debug('Inserting dynamic prereq into Makefile.PL...');
    $self->log_fatal('failed to find position in Makefile.PL to munge!')
        if $content !~ m'^my %FallbackPrereqs = \(\n(?:[^;]+)^\);$'mg;

    my $pos = pos($content);

    $content = substr($content, 0, $pos)
        . "\n\n"
        . q|$WriteMakefileArgs{PREREQ_PM}{'Role::Tiny'} = $FallbackPrereqs{'Role::Tiny'} = '1.003000' if eval { require Role::Tiny; 1 };|
        . "\n" . substr($content, $pos, -1);

    $file->content($content);
    return;
}

1;
