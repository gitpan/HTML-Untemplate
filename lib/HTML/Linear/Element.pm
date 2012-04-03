package HTML::Linear::Element;
# ABSTRACT: represent elements to populate HTML::Linear
use strict;
use common::sense;

use Digest::SHA;
use Any::Moose;

use HTML::Linear::Path;

our $VERSION = '0.001'; # VERSION


has attributes  => (is => 'rw', isa => 'HashRef[Str]', default => sub { {} }, auto_deref => 1);
has content     => (is => 'rw', isa => 'Str', default => '');
has depth       => (is => 'ro', isa => 'Int', required => 1);
has index       => (is => 'rw', isa => 'Int', default => 0);
has index_map   => (is => 'rw', isa => 'HashRef[Str]', default => sub { {} }, auto_deref => 1);
has key         => (is => 'rw', isa => 'Str', default => '');
has path        => (is => 'ro', isa => 'ArrayRef[HTML::Linear::Path]', required => 1, auto_deref => 1);
has sha         => (is => 'ro', isa => 'Digest::SHA', default => sub { new Digest::SHA(256) }, lazy => 1 );

use overload '""' => \&as_string, fallback => 1;


sub BUILD {
    my ($self) = @_;
    $self->attributes({%{$self->path->[-1]->attributes}});
}


sub as_string {
    my ($self) = @_;
    return $self->key if $self->key;

    $self->sha->add($self->content);
    $self->sha->add($self->index);
    $self->sha->add(join ',', $self->path);

    return $self->key($self->sha->b64digest);
}


sub as_xpath {
    my ($self) = @_;
    return
        join '',
            map {
                $_->as_xpath . ($self->index_map->{$_->address} // '')
            } $self->path;
}


sub as_hash {
    my ($self) = @_;
    my $hash = {};
    my $xpath = $self->as_xpath . HTML::Linear::Path::_wrap(separator => '/');

    for my $key (sort keys %{$self->attributes}) {
        $hash->{
            $xpath
            . HTML::Linear::Path::_wrap(sigil       => '@')
            . HTML::Linear::Path::_wrap(attribute   => $key)
        } = $self->attributes->{$key}
            unless $self->attributes->{$key} =~ m{^\s*$}s;
    }

    $hash->{
        $xpath
        . HTML::Linear::Path::_wrap(attribute => 'text()')
    } = $self->content
        unless $self->content =~ m{^\s*$}s;

    return $hash;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding utf8

=head1 NAME

HTML::Linear::Element - represent elements to populate HTML::Linear

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use HTML::Linear::Element;
    use HTML::Linear::Path;

    my $el = HTML::Linear::Element->new({
        depth   => 0,
        path    => [ HTML::Linear::Path->new({ address => q(...), tag => q(...) }) ],
    })

=head1 ATTRIBUTES

=head2 attributes

Element attributes.

=head2 content

Element content.

=head2 depth

Depth level of an element inside a L<HTML::TreeBuilder> structure.

=head2 index

Index to preserve elements order.

=head2 index_map

Used for internal collision detection.

=head2 key

Stringified element representation.

=head2 path

Store representations of paths inside C<HTML::TreeBuilder> structure (L<HTML::Linear::Path>).

=head2 sha

Lazy L<Digest::SHA> (256-bit) representation.

=head1 METHODS

=head2 as_string

Stringified signature of an element.

=head2 as_xpath

Build a nice XPath representation of a path inside the L<HTML::TreeBuilder> structure.

=head2 as_hash

Linearize element as an associative array (Perl hash).

=for Pod::Coverage BUILD

=head1 AUTHOR

Stanislaw Pusep <stas@sysd.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Stanislaw Pusep.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

