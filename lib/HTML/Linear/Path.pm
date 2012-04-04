package HTML::Linear::Path;
# ABSTRACT: represent paths inside HTML::Tree
use strict;
use common::sense;

use JSON::XS;
use Any::Moose;

our $VERSION = '0.003'; # VERSION


has json        => (
    is          => 'ro',
    isa         => 'JSON::XS',
    default     => sub { JSON::XS->new->ascii->canonical },
    lazy        => 1,
);


has address     => (is => 'rw', isa => 'Str', required => 1);
has attributes  => (is => 'ro', isa => 'HashRef[Str]', required => 1, auto_deref => 1);
has key         => (is => 'rw', isa => 'Str', default => '');
has strict      => (is => 'ro', isa => 'Bool', default => 0);
has tag         => (is => 'ro', isa => 'Str', required => 1);

use overload '""' => \&as_string, fallback => 1;


our %xpath_wrap = (
    array       => ['' => ''],
    attribute   => ['' => ''],
    equal       => ['' => ''],
    number      => ['' => ''],
    separator   => ['' => ''],
    sigil       => ['' => ''],
    tag         => ['' => ''],
    value       => ['' => ''],
);


sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    my $ref = {
        _tag    => $self->tag,
        addr    => $self->address,
    };
    $ref->{attr} = $self->attributes if keys %{$self->attributes};

    return $self->key($self->json->encode($ref));
}


sub as_xpath {
    my ($self) = @_;

    my $xpath = _wrap(separator => '/') . _wrap(tag => $self->tag);

    unless ($self->strict) {
        for (qw(id class name)) {
            if ($self->attributes->{$_}) {
                $xpath .= _wrap(array       => '[');
                $xpath .= _wrap(sigil       => '@');
                $xpath .= _wrap(attribute   => $_);
                $xpath .= _wrap(equal       => '=');
                $xpath .= _wrap(value       => _quote($self->attributes->{$_}));
                $xpath .= _wrap(array       => ']');

                last;
            }
        }
    }

    return $xpath;
}


sub _quote {
    local $_ = $_[0];

    s/\\/\\\\/gs;
    s/'/\\'/gs;
    s/\s+/ /gs;
    s/^\s//s;
    s/\s$//s;

    return "'$_'";
}


sub _wrap {
    return
        $xpath_wrap{$_[0]}->[0]
        . $_[1]
        . $xpath_wrap{$_[0]}->[1];
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding utf8

=head1 NAME

HTML::Linear::Path - represent paths inside HTML::Tree

=head1 VERSION

version 0.003

=head1 SYNOPSIS

    use HTML::Linear::Path;

    my $level = HTML::Linear::Path->new({
        address     => q(0.1.1.3.0),
        attributes  => {
            id  => q(li1),
        },
        strict      => 0,
        tag         => q(li),
    });

=head1 ATTRIBUTES

=head2 json

Lazy L<JSON::XS> instance.

=head2 address

Location inside L<HTML::TreeBuilder> tree.

=head2 attributes

Element attributes.

=head2 key

Stringified path representation.

=head2 strict

Strict mode disables grouping by C<id>, C<class> or C<name> attributes.

=head2 tag

Tag name.

=head1 METHODS

=head2 as_string

Build a quick & dirty string representation of a path the L<HTML::TreeBuilder> structure.

=head2 as_xpath

Build a nice XPath representation of a path inside the L<HTML::TreeBuilder> structure.

=head1 FUNCTIONS

=head2 _quote

Quote attribute values for XPath representation.

=head2 _wrap

Help to make a fancy XPath.

=head1 GLOBALS

=head2 %HTML::Linear::Path::xpath_wrap

Wrap XPath components to produce fancy syntax highlight.

The format is:

    (
        array       => ['' => ''],
        attribute   => ['' => ''],
        equal       => ['' => ''],
        number      => ['' => ''],
        separator   => ['' => ''],
        sigil       => ['' => ''],
        tag         => ['' => ''],
        value       => ['' => ''],
    )

=head1 AUTHOR

Stanislaw Pusep <stas@sysd.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Stanislaw Pusep.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

