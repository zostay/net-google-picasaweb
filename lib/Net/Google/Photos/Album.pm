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

This method takes the L<Net::Google::Photos/STANDARD LIST OPTIONS>.

=back

=cut

sub list_media_entries {
    my ($self, %params) = @_;
    $params{kind} = 'photo';

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
