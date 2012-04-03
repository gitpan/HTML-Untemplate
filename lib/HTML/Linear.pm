package HTML::Linear;
# ABSTRACT: represent HTML::Tree as a flat list
use strict;
use common::sense;

use Any::Moose;
use Any::Moose qw(X::NonMoose);
extends 'HTML::TreeBuilder';

use HTML::Linear::Element;
use HTML::Linear::Path;

our $VERSION = '0.001'; # VERSION


has _list       => (
    traits      => ['Array'],
    is          => 'ro',
    isa         => 'ArrayRef[Any]',
    default     => sub { [] },
    handles     => {
        add_element     => 'push',
        as_list         => 'elements',
        count_elements  => 'count',
        get_element     => 'accessor',
    },
);


has _strict => (
    traits      => ['Bool'],
    is          => 'ro',
    isa         => 'Bool',
    default     => 0,
    handles     => {
        set_strict      => 'set',
        unset_strict    => 'unset',
    },
);


has _uniq       => (is => 'ro', isa => 'HashRef[Str]', default => sub { {} });


after eof => sub {
    my ($self) = @_;

    $self->deparse($self, []);

    my $i = 0;
    my %uniq;
    for my $elem ($self->as_list) {
        $elem->index($uniq{join ',', $elem->path}++);
        $elem->index_map($self->_uniq);
    }
};


sub deparse {
    my ($self, $node, $path) = @_;

    my $level = HTML::Linear::Path->new({
        address     => $node->address,
        attributes  => {
            map     { lc $_ => $node->attr($_) }
            grep    { not m{^[_/]} }
            $node->all_attr_names
        },
        strict      => $self->_strict,
        tag         => $node->tag,
    });

    if (
        not $node->content_list
        or (ref(($node->content_list)[0]) ne '')
    ) {
        $self->add_element(
            HTML::Linear::Element->new({
                depth   => $node->depth,
                path    => [ @{$path}, $level ],
            })
        );
    }

    my %uniq;
    for my $child ($node->content_list) {
        if (ref $child) {
            my $l = $self->deparse($child, [ @{$path}, $level ]);
            push @{$uniq{$l->as_xpath}}, $l->address;
        } else {
            $self->add_element(
                HTML::Linear::Element->new({
                    content => $child,
                    depth   => $node->depth,
                    path    => [ @{$path}, $level ],
                })
            );
        }
    }

    while (my ($xpath, $address) = each %uniq) {
        next if 2 > scalar @{$address};

        my $i = 0;
        $self->_uniq->{$_} =
            HTML::Linear::Path::_wrap(array     => '[')
            . HTML::Linear::Path::_wrap(number  => ++$i)
            . HTML::Linear::Path::_wrap(array   => ']')
                for @{$address};
    }

    return $level;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding utf8

=head1 NAME

HTML::Linear - represent HTML::Tree as a flat list

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use Data::Printer;
    use HTML::Linear;

    my $hl = HTML::Linear->new;
    $hl->parse_file(q(index.html));

    for my $el ($hl->as_list) {
        my $hash = $el->as_hash;
        p $hash;
    }

=head1 ATTRIBUTES

=head2 _list

Internal list representation.

=head2 _strict

Internal strict mode flag.

=head2 _uniq

Used for internal collision detection.

=head1 METHODS

=head2 add_element

Add an element to the list.

=head2 as_list

Access list as array.

=head2 count_elements

Number of elements in list.

=head2 get_element

Element accessor.

=head2 set_strict

Do not group by C<id>, C<class> or C<name> attributes.

=head2 unset_strict

Group by C<id>, C<class> or C<name> attributes.

=head2 eof

Overrides L<HTML::TreeBuilder> C<eof>.

=head2 deparse($node, $path)

Recursively scan underlying L<HTML::TreeBuilder> structure.

=head1 AUTHOR

Stanislaw Pusep <stas@sysd.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Stanislaw Pusep.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

