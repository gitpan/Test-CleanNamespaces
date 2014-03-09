use strict;
use warnings;

package Test::CleanNamespaces;
BEGIN {
  $Test::CleanNamespaces::AUTHORITY = 'cpan:FLORA';
}
# git description: v0.07-4-g4487ff3
$Test::CleanNamespaces::VERSION = '0.08';
# ABSTRACT: Check for uncleaned imports

use Module::Runtime 'use_module';
use Sub::Name 'subname';
use Sub::Identify qw(sub_fullname stash_name);
use Package::Stash;
use Module::Runtime 'module_notional_filename';
use Test::Builder;
use File::Find::Rule;
use File::Find::Rule::Perl;
use File::Spec::Functions 'splitdir';
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [
        namespaces_clean     => \&build_namespaces_clean,
        all_namespaces_clean => \&build_all_namespaces_clean,
    ],
    groups => {
        default => [qw/namespaces_clean all_namespaces_clean/],
    },
};

BEGIN {
    # temporary hack to make import into a real named method until
    # Sub::Exporter does it for us.
    *import = subname __PACKAGE__ . '::import', \&import;
}

# =head1 SYNOPSIS
#
#     use strict;
#     use warnings;
#     use Test::CleanNamespaces;
#
#     all_namespaces_clean;
#
# =head1 DESCRIPTION
#
# This module lets you check your module's namespaces for imported functions you
# might have forgotten to remove with L<namespace::autoclean> or
# L<namespace::clean> and are therefore available to be called as methods, which
# usually isn't want you want.
#
# =head1 FUNCTIONS
#
# All functions are exported by default.
#
# =head2 namespaces_clean
#
#     namespaces_clean('YourModule', 'AnotherModule');
#
# Tests every specified namespace for uncleaned imports. If the module couldn't
# be loaded it will be skipped.
#
# =head2 all_namespaces_clean
#
#     all_namespaces_clean;
#
# Runs C<namespaces_clean> for all modules in your distribution.
#
# =head1 METHODS
#
# The exported functions are constructed using the the following methods. This is
# what you want to override if you're subclassing this module.
#
# =head2 build_namespaces_clean
#
#     my $coderef = Test::CleanNamespaces->build_namespaces_clean;
#
# Returns a coderef that will be exported as C<namespaces_clean>.
#
# =cut

sub build_namespaces_clean {
    my ($class, $name) = @_;
    return sub {
        my (@namespaces) = @_;
        local $@;

        for my $ns (@namespaces) {
            unless (eval { use_module($ns); 1 }) {
                $class->builder->skip("failed to load ${ns}: $@");
                next;
            }

            my $symbols = Package::Stash->new($ns)->get_all_symbols('CODE');
            my @imports;

            my $meta;
            if ($INC{ module_notional_filename('Moose::Util') }
                and $meta = Moose::Util::find_meta($ns))
            {
                my %subs = %$symbols;
                delete @subs{ $meta->get_method_list };
                @imports = keys %subs;
            }
            elsif ($INC{ module_notional_filename('Mouse::Util') }
                and $meta = Mouse::Util::class_of($ns))
            {
                my %subs = %$symbols;
                delete @subs{ $meta->get_method_list };
                @imports = keys %subs;
            }
            else
            {
                @imports = grep {
                    my $stash = stash_name($symbols->{$_});
                    $stash ne $ns
                        and $stash ne 'Role::Tiny'
                        and not eval { require Role::Tiny; Role::Tiny->is_role($stash) }
                } keys %$symbols;
            }

            $class->builder->ok(!@imports, "${ns} contains no imported functions");

            my %imports; @imports{@imports} = map { sub_fullname($symbols->{$_}) } @imports;
            $class->builder->diag(
                $class->builder->explain('remaining imports: ' => \%imports)
            ) if @imports;
        }
    };
}

# =head2 build_all_namespaces_clean
#
#     my $coderef = Test::CleanNamespaces->build_namespaces_clean;
#
# Returns a coderef that will be exported as C<all_namespaces_clean>. It will use
# the C<find_modules> method to get the list of modules to check.
#
# =cut

sub build_all_namespaces_clean {
    my ($class, $name) = @_;
    my $namespaces_clean = $class->build_namespaces_clean($name);
    return sub {
        my @modules = $class->find_modules(@_);
        $class->builder->plan(tests => scalar @modules);
        $namespaces_clean->(@modules);
    };
}

# =head2 find_modules
#
#     my @modules = Test::CleanNamespaces->find_modules;
#
# Returns a list of modules in the current distribution. It'll search in
# C<blib/>, if it exists. C<lib/> will be searched otherwise.
#
# =cut

sub find_modules {
    my ($class) = @_;
    my @modules = map {
        /^blib/
            ? s/^blib.(?:lib|arch).//
            : s/^lib.//;
        s/\.pm$//;
        join '::' => splitdir($_);
    } File::Find::Rule->perl_module->in(-e 'blib' ? 'blib' : 'lib');
    return @modules;
}

# =head2 builder
#
#     my $builder = Test::CleanNamespaces->builder;
#
# Returns the C<Test::Builder> used by the test functions.
#
# =cut

{
    my $Test = Test::Builder->new;
    sub builder { $Test }
}

1;

__END__

=pod

=encoding UTF-8

=for :stopwords Florian Ragwitz Karen Etheridge

=head1 NAME

Test::CleanNamespaces - Check for uncleaned imports

=head1 VERSION

version 0.08

=head1 SYNOPSIS

    use strict;
    use warnings;
    use Test::CleanNamespaces;

    all_namespaces_clean;

=head1 DESCRIPTION

This module lets you check your module's namespaces for imported functions you
might have forgotten to remove with L<namespace::autoclean> or
L<namespace::clean> and are therefore available to be called as methods, which
usually isn't want you want.

=head1 FUNCTIONS

All functions are exported by default.

=head2 namespaces_clean

    namespaces_clean('YourModule', 'AnotherModule');

Tests every specified namespace for uncleaned imports. If the module couldn't
be loaded it will be skipped.

=head2 all_namespaces_clean

    all_namespaces_clean;

Runs C<namespaces_clean> for all modules in your distribution.

=head1 METHODS

The exported functions are constructed using the the following methods. This is
what you want to override if you're subclassing this module.

=head2 build_namespaces_clean

    my $coderef = Test::CleanNamespaces->build_namespaces_clean;

Returns a coderef that will be exported as C<namespaces_clean>.

=head2 build_all_namespaces_clean

    my $coderef = Test::CleanNamespaces->build_namespaces_clean;

Returns a coderef that will be exported as C<all_namespaces_clean>. It will use
the C<find_modules> method to get the list of modules to check.

=head2 find_modules

    my @modules = Test::CleanNamespaces->find_modules;

Returns a list of modules in the current distribution. It'll search in
C<blib/>, if it exists. C<lib/> will be searched otherwise.

=head2 builder

    my $builder = Test::CleanNamespaces->builder;

Returns the C<Test::Builder> used by the test functions.

=head1 AUTHOR

Florian Ragwitz <rafl@debian.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Florian Ragwitz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTOR

Karen Etheridge <ether@cpan.org>

=cut
