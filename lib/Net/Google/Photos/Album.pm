use strict;
use warnings;

package Net::Google::Photos::Album;
use Moose;

extends 'Net::Google::Photos::Base';

use Net::Google::Photos::Media;

=head1 NAME

Net::Google::Photos::Album - represents a single Picasa Web photo album

=head1 SYNOPSIS

  my @albums = $service->list_albums;
  for my $album (@albums) {
      print "Title: ", $album->title, "\n";
      print "Summary: ", $album->summary, "\n";
      print "Author: ", $album->author_name, " (", $album->author_uri, ")\n";
  }

=head1 DESCRIPTION

Represents an individual Picasa Web photo album.

=head1 ATTRIBUTES

=head2 title

This is the title of the albums.

=cut

has title => (
    is => 'rw',
    isa => 'Str',
);

=head2 summary

This is the summary of the album.

=cut

has summary => (
    is => 'rw',
    isa => 'Str',
);

=head2 author_name

This is the author/owner of the album.

=cut

has author_name => (
    is => 'rw',
    isa => 'Str',
);

=head2 author_uri

This is the URL to get to the author's public albums on Picasa Web.

=cut

has author_url => (
    is => 'rw',
    isa => 'Str',
);

=head2 cover

This is a link to the L<Net::Google::Photos::Media> object that is used as the album cover.

=cut

has cover => (
    is => 'rw',
    isa => 'Net::Google::Photos::Media',
);

=head1 METHODS

=cut

sub from_feed {
    my ($class, $service, $entry) = @_;

    my %params = (
        service => $service,
        twig    => $entry,
        title   => $entry->field('title'),
        summary => $entry->field('summary'),
    );

    if (my $author = $entry->first_child('author')) {
        $params{author_name} = $entry->field('name')
            if $entry->has_child('name');
        $params{author_uri}  = $entry->field('uri')
            if $entry->has_child('uri');
    }

    my $self = $class->new(\%params);

    my $media = Net::Google::Photos::Media->from_feed(
        $self->service, $entry->first_child('media:group')
    );
    $self->cover($media);

    return $self;
}

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
