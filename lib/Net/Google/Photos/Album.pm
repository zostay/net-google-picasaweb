use strict;
use warnings;

package Net::Google::Photos::Album;
use Moose;

extends 'Net::Google::Photos::Feed';

use Net::Google::Photos::Media;

=head1 NAME

Net::Google::Photos::Album - represents a single Picasa Web photo album

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

This is a link to the L<Net::Google::Photos::Media> object that is used to reference the cover photo and thumbnails of it.

=head1 METHODS

=head2 list_media_entries

  my @photos = $album->list_media_entries(%params);

Lists photos and video entries in the album. Options may be used to modify the photos returned.

=over

=item access

This is the L<http://code.google.com/apis/picasaweb/reference.html#Visibility|visibility value> to limit the returned results to.

=item thumbsize

By passing a single scalar or an array reference of scalars, you may select the size or sizes of thumbnails attached to the photo returned. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|parameters> documentation for a description of valid values.

=item imgmax

This is a single scalar selecting the size of the main image to return with the photos found. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|parameters> documentation for a description of valid values.

=item tag

This is a tag name to use to filter the photos returned.

=item q

This is a full-text query string to filter the photos returned.

=item max_results

This is the maximum number of results to be returned.

=item start_index

This is the 1-based index of the first result to be returned.

=item bbox

This is the bounding box of geo coordinates to search for photos within. The coordinates are given as an array reference of exactly 4 values given in the following order: west, south, east, north.

=item l

This may be set to the name of a geo location to search for photos within. For example, "London".

=back

=cut

sub list_media_entries {
    my ($self, %params) = @_;

    return $self->service->list_entries(
        'Net::Google::Photos::MediaEntry',
        [ 'user', $self->user_id, 'albumid', $self->entry_id ],
        %params,
    );
}

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
