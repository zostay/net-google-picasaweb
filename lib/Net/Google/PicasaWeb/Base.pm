use strict;
use warnings;

package Net::Google::PicasaWeb::Base;
use Moose;

with 'MooseX::Role::Matcher' => { default_match => 'id' };

=head1 NAME

Net::Google::PicasaWeb::Base - base class

=head1 DESCRIPTION

This defines some common tools available to many of the classes included with L<Net::Google::PicasaWeb>.

=head1 ATTRIBUTES

These are common attributes shared by subclasses.

=head2 service

This is a link back to the parent L<Net::Google::PicasaWeb> class responsible for communicating with the Picasa Web API.

=cut

has service => (
    is => 'rw',
    isa => 'Net::Google::PicasaWeb',
    required => 1,
    weaken => 1,
);

=head2 twig

This is the L<XML::Twig::Elt> the class was last updated with. This may be used to get more detailed information out of the elements in case there are features of it you want, but this library does not yet provide.

B<Note:> There is no guarantee that future versions of this library will be based upon L<XML::Twig>. As such, you should avoid depending on this if you can.

=cut

has twig => (
    is => 'rw',
    isa => 'XML::Twig::Elt',
);

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
