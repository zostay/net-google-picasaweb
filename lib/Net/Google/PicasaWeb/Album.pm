use strict;
use warnings;

package Net::Google::PicasaWeb::Album;
use Moose;

extends 'Net::Google::PicasaWeb::MediaFeed';

use Net::Google::PicasaWeb::Media;

=head1 NAME

Net::Google::PicasaWeb::Album - represents a single Picasa Web photo album

=head1 SYNOPSIS

  my @albums = $service->list_albums;
  for my $album (@albums) {
      print "Title: ", $album->title, "\n";
      print "Summary: ", $album->summary, "\n";
      print "Author: ", $album->author_name, " (", $album->author_uri, ")\n";

      $album->fetch_content( file => 'cover-photo.jpg' );
  }

=head1 DESCRIPTION

Represents an individual Picasa Web photo album.

=head1 ATTRIBUTES

=head2 title

This is the title of the album.

=head2 summary

This is the summary of the album.

=head2 author_name

This is the author/owner of the album.

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web.

=head2 photo

This is a link to the L<Net::Google::PicasaWeb::Media> object that is used to reference the cover photo and thumbnails of it.

=head1 METHODS

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

*list_photos = *list_media_entries;
*list_videos = *list_media_entries;

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

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
