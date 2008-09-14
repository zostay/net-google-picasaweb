use strict;
use warnings;

package Net::Google::Photos::Feed;
use Moose;

extends 'Net::Google::Photos::Base';

=head1 NAME

Net::Google::Photos::Feed - base class for feed entries

=head1 DESCRIPTION

Provides some common functions for feed-based photos objects.

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

has author_url => (
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

has photo => (
    is => 'rw',
    isa => 'Net::Google::Photos::Media',
);

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
        $params{author_name} = $entry->field('name')
            if $entry->has_child('name');
        $params{author_uri}  = $entry->field('uri')
            if $entry->has_child('uri');
    }

    my $self = $class->new(\%params);

    if ($entry->has_child('media:group')) {
        my $media = Net::Google::Photos::Media->from_feed(
            $self->service, $entry->first_child('media:group')
        );
        $self->photo($media);
    }

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
