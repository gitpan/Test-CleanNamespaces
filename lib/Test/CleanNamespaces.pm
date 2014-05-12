use strict;
use warnings;

package Test::CleanNamespaces;
BEGIN {
  $Test::CleanNamespaces::AUTHORITY = 'cpan:FLORA';
}
# git description: v0.09-TRIAL-5-g0dacbd6
$Test::CleanNamespaces::VERSION = '0.10'; # TRIAL
# ABSTRACT: Check for uncleaned imports

use Module::Runtime 'require_module';
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

#pod =head1 SYNOPSIS
#pod
#pod     use strict;
#pod     use warnings;
#pod     use Test::CleanNamespaces;
#pod
#pod     all_namespaces_clean;
#pod
#pod =head1 DESCRIPTION
#pod
#pod This module lets you check your module's namespaces for imported functions you
#pod might have forgotten to remove with L<namespace::autoclean> or
#pod L<namespace::clean> and are therefore available to be called as methods, which
#pod usually isn't want you want.
#pod
#pod =head1 FUNCTIONS
#pod
#pod All functions are exported by default.
#pod
#pod =head2 namespaces_clean
#pod
#pod     namespaces_clean('YourModule', 'AnotherModule');
#pod
#pod Tests every specified namespace for uncleaned imports. If the module couldn't
#pod be loaded it will be skipped.
#pod
#pod =head2 all_namespaces_clean
#pod
#pod     all_namespaces_clean;
#pod
#pod Runs C<namespaces_clean> for all modules in your distribution.
#pod
#pod =head1 METHODS
#pod
#pod The exported functions are constructed using the the following methods. This is
#pod what you want to override if you're subclassing this module.
#pod
#pod =head2 build_namespaces_clean
#pod
#pod     my $coderef = Test::CleanNamespaces->build_namespaces_clean;
#pod
#pod Returns a coderef that will be exported as C<namespaces_clean> (or the
#pod specified sub name, if provided).
#pod
#pod =cut

sub build_namespaces_clean {
    my ($class, $name) = @_;
    return sub {
        my (@namespaces) = @_;
        local $@;

        for my $ns (@namespaces) {
            unless (eval { require_module($ns); 1 }) {
                $class->builder->skip("failed to load ${ns}: $@");
                next;
            }

            my $symbols = Package::Stash->new($ns)->get_all_symbols('CODE');
            my @imports;

            my $meta;
            if ($INC{ module_notional_filename('Class::MOP') }
                and $meta = Class::MOP::class_of($ns)
                and $meta->can('get_method_list'))
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

            my %imports; @imports{@imports} = map { sub_fullname($symbols->{$_}) } @imports;

            # these subs are special-cased - they are often provided by other
            # modules, but cannot be wrapped with Sub::Name as the call stack
            # is important
            delete @imports{qw(import unimport)};

            my @overloads = grep { $imports{$_} eq 'overload::nil' } keys %imports;
            delete @imports{@overloads} if @overloads;

            $class->builder->ok(!keys(%imports), "${ns} contains no imported functions")
                or $class->builder->diag($class->builder->explain('remaining imports: ' => \%imports));
        }
    };
}

#pod =head2 build_all_namespaces_clean
#pod
#pod     my $coderef = Test::CleanNamespaces->build_namespaces_clean;
#pod
#pod Returns a coderef that will be exported as C<all_namespaces_clean>.
#pod (or the specified sub name, if provided).
#pod It will use
#pod the C<find_modules> method to get the list of modules to check.
#pod
#pod =cut

sub build_all_namespaces_clean {
    my ($class, $name) = @_;
    my $namespaces_clean = $class->build_namespaces_clean($name);
    return sub {
        my @modules = $class->find_modules(@_);
        $class->builder->plan(tests => scalar @modules);
        $namespaces_clean->(@modules);
    };
}

#pod =head2 find_modules
#pod
#pod     my @modules = Test::CleanNamespaces->find_modules;
#pod
#pod Returns a list of modules in the current distribution. It'll search in
#pod C<blib/>, if it exists. C<lib/> will be searched otherwise.
#pod
#pod =cut

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

#pod =head2 builder
#pod
#pod     my $builder = Test::CleanNamespaces->builder;
#pod
#pod Returns the C<Test::Builder> used by the test functions.
#pod
#pod =cut

{
    my $Test = Test::Builder->new;
    sub builder { $Test }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::CleanNamespaces - Check for uncleaned imports

=head1 VERSION

version 0.10

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

Returns a coderef that will be exported as C<namespaces_clean> (or the
specified sub name, if provided).

=head2 build_all_namespaces_clean

    my $coderef = Test::CleanNamespaces->build_namespaces_clean;

Returns a coderef that will be exported as C<all_namespaces_clean>.
(or the specified sub name, if provided).
It will use
the C<find_modules> method to get the list of modules to check.

=head2 find_modules

    my @modules = Test::CleanNamespaces->find_modules;

Returns a list of modules in the current distribution. It'll search in
C<blib/>, if it exists. C<lib/> will be searched otherwise.

=head2 builder

    my $builder = Test::CleanNamespaces->builder;

Returns the C<Test::Builder> used by the test functions.

=head1 SEE ALSO

=over 4

=item *

L<namespace::clean>

=item *

L<namespace::autoclean>

=item *

L<namespace::sweep>

=item *

L<Sub::Exporter::ForMethods>

=item *

L<Test::API>

=back

=head1 AUTHOR

Florian Ragwitz <rafl@debian.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Florian Ragwitz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTOR

Karen Etheridge <ether@cpan.org>

=cut
