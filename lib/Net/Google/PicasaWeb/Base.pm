package Net::Google::PicasaWeb::Base;
use Moose;

# ABSTRACT: base class

with 'MooseX::Role::Matcher' => { default_match => 'id' };

=head1 DESCRIPTION

This defines some common tools available to many of the classes included with L<Net::Google::PicasaWeb>.

=head1 ATTRIBUTES

These are common attributes shared by subclasses.

=head2 service

This is a link back to the parent L<Net::Google::PicasaWeb> class responsible for communicating with the Picasa Web API.

=cut

has service => (
    is          => 'rw',
    isa         => 'Net::Google::PicasaWeb',
    required    => 1,
    weak_ref    => 1,
);

=head2 twig

This is the L<XML::Twig::Elt> the class was last updated with. This may be used to get more detailed information out of the elements in case there are features of it you want, but this library does not yet provide.

B<Note:> There is no guarantee that future versions of this library will be based upon L<XML::Twig>. As such, you should avoid depending on this if you can.

=cut

has twig => (
    is          => 'rw',
    isa         => 'XML::Twig::Elt',
);

__PACKAGE__->meta->make_immutable;

1;
