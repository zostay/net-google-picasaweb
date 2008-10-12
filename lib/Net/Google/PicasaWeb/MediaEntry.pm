use strict;
use warnings;

package Net::Google::PicasaWeb::MediaEntry;
use Moose;

extends 'Net::Google::PicasaWeb::MediaFeed';

=head1 NAME

Net::Google::PicasaWeb::MediaEntry - represents a single Picasa Web photo or video

=head1 SYNOPSIS

  my @photos = $album->list_photos;
  for my $photo (@photos) {
      print "Title: ", $photo->title, "\n";
      print "Summary: ", $photo->summary, "\n";
      print "Author: ", $photo->author_name, " (", $photo->author_uri, ")\n";

      $photo->fetch_content( file => 'photo.jpg' );
  }

=head1 DESCRIPTION

Represents an individual Picasa Web photo.

=head1 ATTRIBUTES

=head2 title

This is the title of the photo.

=head2 summary

This is the summary description of the photo.

=head2 author_name

This is the author/owner of the photo.

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web.

=head2 photo

This is a link to the L<Net::Google::PicasaWeb::Media> object that is used to reference the photo itself and its thumbnails.

=head2 album_id

This is the ID of the album that the photo belongs to.

=cut

has album_id => (
    is => 'rw',
    isa => 'Str',
);

=head1 METHODS

=cut

override from_feed => sub {
    my ($class, $service, $entry) = @_;
    my $self = $class->super($service, $entry);

    $self->album_id($entry->field('gphoto:albumid'));
    return $self;
};

=head2 list_tags

Lists tags used in the albums.

This method takes the L<Net::Google::PicasaWeb/STANDARD LIST OPTIONS>.

=cut

sub list_tags {
    my ($self, %params) = @_;
    $params{kind} = 'tag';

    return $self->service->list_entries(
        'Net::Google::PicasaWeb::Tag',
        $self->url,
        %params
    );
}

=head2 list_comments

Lists comments used in the albums.

This method takes the L<Net::Google::PicasaWeb/STANDARD LIST OPTIONS>.

=cut

sub list_comments {
    my ($self, %params) = @_;
    $params{kind} = 'comment';

    return $self->service->list_entries(
        'Net::Google::PicasaWeb::Comment',
        $self->url,
        %params
    );
}

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
