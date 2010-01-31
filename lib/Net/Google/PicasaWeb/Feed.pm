use strict;
use warnings;

package Net::Google::PicasaWeb::Feed;
use Moose;

extends 'Net::Google::PicasaWeb::Base';

=head1 NAME

Net::Google::PicasaWeb::Feed - base class for feed entries

=head1 DESCRIPTION

Provides some common functions for feed-based objects. This class extends L<Net::Google::PicasaWeb::Base>.

=head1 ATTRIBUTES

All feed-based objects have these attributes. However, they may not all be used.

=head2 url

The URL used to get information about the object.

=cut

has url => (
    is => 'rw',
    isa => 'Str',
);

=head2 title

The title of the object.

=cut

has title => (
    is => 'rw',
    isa => 'Str',
);

=head2 summary

The summary of the object. This is the long description of the album or caption of the photo.

=cut

has summary => (
    is => 'rw',
    isa => 'Str',
);

=head2 author_name

This is the author/owner of the object.

=cut

has author_name => (
    is => 'rw',
    isa => 'Str',
);

=head2 author_uri

This is the URL to get the author's public albums on Picasa Web.

=cut

has author_uri => (
    is => 'rw',
    isa => 'Str',
);

=head2 entry_id

This is the ID that may be used with the object type to uniquely identify (and lookup) this object.

=cut

has entry_id => (
    is => 'rw',
    isa => 'Str',
);

=head2 user_id

This is the account ID of the user.

=cut

has user_id => (
    is => 'rw',
    isa => 'Str',
);

=head2 latitude

This is the geo-coded latitude of the object.

=cut

has latitude => (
    is => 'rw',
    isa => 'Num',
);

=head2 longitude

This is the geo-coded longitude of the object.

=cut

has longitude => (
    is => 'rw',
    isa => 'Num',
);

=head1 METHODS

=head2 from_feed

  my $feed = $class->from_feed($service, $entry);

This method creates the feed object from the service object and an L<XML::Twig::Elt> representing the element returned descring that object.

=cut

sub from_feed {
    my ($class, $service, $entry) = @_;

    my $url = $entry->field('id');
    $url =~ s/^\s+//; $url =~ s/\s+$//;
    $url =~ s{/data/entry/}{/data/feed/};

    my %params = (
        service  => $service,
        twig     => $entry,
        url      => $url,
        title    => $entry->field('title'),
        summary  => $entry->field('summary'),
        entry_id => $entry->field('gphoto:id'),
        user_id  => $entry->field('gphoto:user'),
    );

    if (my $author = $entry->first_child('author')) {
        $params{author_name} = $author->field('name')
            if $author->has_child('name');
        $params{author_uri}  = $author->field('uri')
            if $author->has_child('uri');
        $params{user_id}   ||= $author->field('gphoto:user')
            if $author->has_child('gphoto:user');
    }

    if (my $georss = $entry->first_child('georss:where')) {
        if (my $point = $georss->first_child('gml:Point')) {      
            if (my $pos = $point->field('gml:pos') ) {
                
                $pos =~ s/^\s+//;
                my ($lat, $lon) = split /\s+/, $pos, 2;

                $params{latitude}  = $lat;
                $params{longitude} = $lon;
            }
        }
    } 

    return $class->new(\%params);
}

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
