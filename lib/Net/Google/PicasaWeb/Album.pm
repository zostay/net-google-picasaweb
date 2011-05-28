use strict;
use warnings;

# ABSTRACT: represents a single Picasa Web photo album

package Net::Google::PicasaWeb::Album;
use Moose;

extends 'Net::Google::PicasaWeb::MediaFeed';

use Net::Google::PicasaWeb::Media;

=head1 SYNOPSIS

  my @albums = $service->list_albums;
  for my $album (@albums) {
      print "Title: ", $album->title, "\n";
      print "Summary: ", $album->summary, "\n";
      print "Author: ", $album->author_name, " (", $album->author_uri, ")\n";

      $album->fetch_content( file => 'cover-photo.jpg' );
  }

=head1 DESCRIPTION

Represents an individual Picasa Web photo album. This class extends L<Net::Google::PicasaWeb::Feed>.

=head1 ATTRIBUTES

=head2 url

The URL used to get the album information. See L<Net::Google::PicasaWeb::Feed/url>.

=head2 title

This is the title of the album. See L<Net::Google::PicasaWeb::Feed/title>.

=head2 summary

This is the summary of the album. See L<Net::Google::PicasaWeb::Feed/summary>.

=head2 author_name

This is the author/owner of the album. See L<Net::Google::PicasaWeb::Feed/author_name>.

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web. See L<Net::Google::PicasaWeb::Feed/author_uri>.

=head2 entry_id

This is the identifier of the album used to look up a specific album in the API. This is the album ID. See L<Net::Google::PicasaWeb::Feed/entry_id>.

=head2 latitude

The goe-coded latitude set on the album. See L<Net::Google::PicasaWeb::Feed/latitude>.

=head2 longitude

The geo-coded longitude set on the album. See L<Net::Google::PicasaWeb::Feed/longitude>.

=head2 photo

This is a link to the L<Net::Google::PicasaWeb::Media> object that is used to reference the cover photo and thumbnails of it.

=head2 bytes_used

This is the size of the album in bytes.

=cut

has bytes_used => (
    is          => 'rw',
    isa         => 'Int',
    predicate   => 'has_bytes_used',
);

=head2 number_of_photos

This is the number of photos in the albums.

=cut

has number_of_photos => (
    is          => 'rw',
    isa         => 'Int',
    predicate   => 'has_number_of_photos',
);

=head1 METHODS

=cut

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = $class->super($service, $entry);

    $self->bytes_used($entry->field('gphoto:bytesUsed'))
        if $entry->field('gphoto:bytesUsed');
    $self->number_of_photos($entry->field('gphoto:numphotos'))
        if $entry->field('gphoto:numphotos');;

    return $self;
};

=head2 list_media_entries

=head2 list_photos

=head2 list_videos

  my @photos = $album->list_media_entries(%params);

Lists photos and video entries in the album. Options may be used to modify the photos returned.

This method takes the L<Net::Google::PicasaWeb/STANDARD LIST OPTIONS>.

The L</list_photos> and L</list_videos> methods are synonyms for L</list_media_entries>.

=cut

sub list_media_entries {
    my ($self, %params) = @_;
    $params{kind} = 'photo';

    return $self->service->list_entries(
        'Net::Google::PicasaWeb::MediaEntry',
        $self->url,
        %params,
    );
}

sub list_photos { shift->list_media_entries(@_) }
sub list_videos { shift->list_media_entries(@_) }

=head2 list_tags

Lists tags used in the albums.

This method takes the L<Net::Google::PicasaWeb/STANDARD LIST OPTIONS>.

=cut

sub list_tags {
    my ($self, %params) = @_;
    $params{kind} = 'tag';

    my $user_id = delete $params{user_id} || 'default';
    return $self->service->list_entries(
        'Net::Google::PicasaWeb::Tag',
        $self->url,
        %params
    );
}

1;
