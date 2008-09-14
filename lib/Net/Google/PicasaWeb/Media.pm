use strict;
use warnings;

package Net::Google::PicasaWeb::Media;
use Moose;

extends 'Net::Google::PicasaWeb::Base';

=head1 NAME

Net::Google::PicasaWeb::Media - hold information about a photo or video

=head1 SYNOPSIS

  my @photos = $album->list_media_entries;
  for my $photo (@photos) {
      my $media_info = $photo->photo;

      print "Image Title: ", $media_info->title, "\n";
      print "Image Description: ", $media_info->description, "\n\n";

      my $main_photo = $media_info->content;
      print "Image URL: ", $main_photo->url, "\n";
      print "Image MIME Type: ", $main_photo->mime_type, "\n";
      print "Image Medium: ", $main_photo->medium, "\n";

      print "Thumbnails:\n\n";
      
      for my $thumbnail ($media_info->thumbnails) {
          print "    Thumbnail URL: ", $thumbnail->url, "\n";
          print "    Thumbnail Dimensions: ", 
              $thumbnail->width, "x", $thumbnail->height, "\n\n";

          my $photo_data = $thumbnail->fetch;
          $thumbnail->fetch( file => 'thumbnail.jpg' );
      }
    
      my $photo_data = $main_photo->fetch;
      $main_photo->fetch( file => 'photo.jpg' );
  }

=head1 DESCRIPTION

This is where you will find information about the photos, videos, and thumbnails themselves. You can get information about them with this object, such as the URL that can be used to download the media file. This object (and its children) also provide some features to fetching this information.

=head1 ATTRIBUTE

=head2 title

This is the title of the photo or video.

=cut

has title => (
    is => 'rw',
    isa => 'Str',
);

=head2 description

This is a description for the photo or video.

=cut

has description => (
    is => 'rw',
    isa => 'Str',
);

=head2 content

This is the main photo or video item attached to the media information entry. See L</MEDIA CONTENT> below for information about the object returned.

=cut

has content => (
    is => 'rw',
    isa => 'Net::Google::PicasaWeb::Media::Content',
);

=head2 thumbnails

This is an array of object containing information about the thumbnails that were attached when the photo was retrieved from the server.  See L</THUMBNAILS> below for information about these objects.

=cut

has thumbnails => (
    is => 'rw',
    isa => 'ArrayRef[Net::Google::PicasaWeb::Media::Thumbnail]',
);

sub from_feed {
    my ($class, $service, $media_group) = @_;

    my $content = $media_group->first_child('media:content');

    my %params = (
        service     => $service,
        twig        => $media_group,
        title       => $media_group->field('media:title'),
        description => $media_group->field('media:description'),
        content     => Net::Google::PicasaWeb::Media::Content->new(
            url       => $content->att('url'),
            mime_type => $content->att('type'),
            medium    => $content->att('medium'),
        ),
        thumbnails  => [
            map { 
                Net::Google::PicasaWeb::Media::Thumbnail->new(
                    url    => $_->att('url'),
                    width  => $_->att('width'),
                    height => $_->att('height'),
                )
            } $media_group->children('media:thumbnail')
        ],
    );       
    
    return $class->new(\%params);
}

sub fetch_content {
    my $self = shift;
    return $self->_fetch('content', @_);
}

sub fetch_thumbnail {
    my $self = shift;
    return $self->_fetch('thumbnail', @_);
}

sub _fetch {
    my ($self, $which, %params) = @_;
    my $url = $self->$which->url;

    my %header;
    $header{':content_file'} = $params{file} if $params{file};

    my $response = $self->service->user_agent->get($url, %header);

    if ($response->is_success) {
        return $response->content;
    }
    else {
        croak $response->status_line;
    }
}

package Net::Google::PicasaWeb::Media::Content;
use Moose;

=head1 MEDIA CONTENT

The object returned from the L</content> accessor is an object with the following accessors and methods.

=head2 ATTRIBUTES

=head3 url

This is the URL where the photo or video may be downloaded from.

=cut

has url => (
    is => 'rw',
    isa => 'Str',
);

=head3 mime_type

This is the MIME-Type of the photo or video.

=cut

has mime_type => (
    is => 'rw',
    isa => 'Str',
);

=head3 medium

This should be one of the following scalar values describing the media entry:

=over

=item *

image

=item *

video

=back

=cut

has medium => (
    is => 'rw',
    isa => 'Str',
);

package Net::Google::PicasaWeb::Media::Thumbnail;
use Moose;

=head1 THUMBNAILS

Each thumbnail returned represents an individual image resource used as a thumbnail for the main item. Each one has the following attributes and methods.

=head2 ATTRIBUTES

=head3 url

This is the URL where the thumbnail image can be pulled down from.

=cut

has url => (
    is => 'rw',
    isa => 'Str',
);

=head3 width

This is the pixel width of the image.

=cut

has width => (
    is => 'rw',
    isa => 'Int',
);

=head3 height

This is the pixel height of the image.

=cut

has height => (
    is => 'rw',
    isa => 'Int',
);

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
