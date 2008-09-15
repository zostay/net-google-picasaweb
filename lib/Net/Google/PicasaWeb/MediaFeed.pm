use strict;
use warnings;

package Net::Google::PicasaWeb::MediaFeed;
use Moose;

extends 'Net::Google::PicasaWeb::Feed';

=head1 NAME

Net::Google::PicasaWeb::MediaFeed - base class for media feed entries

=head1 DESCRIPTION

Provides some common functions for the media-based objects (the ones with photo/video links).

=cut

has photo => (
    is => 'rw',
    isa => 'Net::Google::PicasaWeb::Media',
);

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = $class->super($service, $entry);

    my $media = Net::Google::PicasaWeb::Media->from_feed(
        $self->service, $entry->first_child('media:group')
    );
    $self->photo($media);

    return $self;
};

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
