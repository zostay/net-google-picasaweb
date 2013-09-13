package Net::Google::PicasaWeb::MediaFeed;
use Moose;

extends 'Net::Google::PicasaWeb::Feed';

# ABSTRACT: base class for media feed entries

=head1 DESCRIPTION

Provides some common functions for the media-based objects (the ones with photo/video links). This class extends L<Net::Google::PicasaWeb::Feed>.

=head1 ATTRIBUTES

=head2 photo

This is the photo for the media feed object. This returns a L<Net::Google::Picasa::Media>.

=cut

has photo => (
    is          => 'rw',
    isa         => 'Net::Google::PicasaWeb::Media',
);

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = super();

    if ($entry->has_child('media:group')) {
        my $media = Net::Google::PicasaWeb::Media->from_feed(
            $self->service, $entry->first_child('media:group')
        );
        $self->photo($media);
    }

    return $self;
};

__PACKAGE__->meta->make_immutable;

1;
