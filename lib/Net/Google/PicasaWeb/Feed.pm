use strict;
use warnings;

package Net::Google::PicasaWeb::Feed;
use Moose;

extends 'Net::Google::PicasaWeb::Base';

=head1 NAME

Net::Google::PicasaWeb::Feed - base class for feed entries

=head1 DESCRIPTION

Provides some common functions for feed-based objects.

=cut

has url => (
    is => 'rw',
    isa => 'Str',
);

has title => (
    is => 'rw',
    isa => 'Str',
);

has summary => (
    is => 'rw',
    isa => 'Str',
);

has author_name => (
    is => 'rw',
    isa => 'Str',
);

has author_uri => (
    is => 'rw',
    isa => 'Str',
);

has entry_id => (
    is => 'rw',
    isa => 'Str',
);

has user_id => (
    is => 'rw',
    isa => 'Str',
);

=head1 METHODS

=head2 from_feed

  my $feed = $class->from_feed($service, $entry);

This method creates the feed object from the service object and an L<XML::Twig::Elt> representing the element returned descring that object.

=cut

sub from_feed {
    my ($class, $service, $entry) = @_;

    my %params = (
        service  => $service,
        twig     => $entry,
        url      => $entry->field('id'),
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
