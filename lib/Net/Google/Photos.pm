use warnings;
use strict;

package Net::Google::Photos;
use Moose;

use Carp;
use LWP::UserAgent;
use Net::Google::AuthSub;

=head1 NAME

Net::Google::Photos - use Google's Photos API (Picasa Web)

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use Net::Google::Photos;

  my $service = Net::Google::Photos->new;

  # Login via one of these
  $service->login('jondoe@gmail.com', 'north23AZ');

  # Working with albums (see Net::Google::Photos::Album)
  my @albums = $service->list_albums( user_id => 'jondoe');
  my $album = $service->add_album(
      title              => 'Trip To Italy',
      summary            => 'This was the recent trip I took to Italy.'
      location           => 'Italy',
      access             => 'public',
      commenting_enabled => 1,
      timestamp          => DateTime->new( year => 2008, month => 6, day => 12 ),
      keywords           => [ qw( italy vacation ) ],
  );
  $album->title('Quick Trip To Italy');
  $album->save;
  $album->delete;

  # Listing photos (see Net::Google::Photos::Entry)
  my @photos      = $album->list_entries; 
  my @recent      = $album->list_entries( max_results => 10 );
  my @puppies     = $album->list_entries( q => 'puppies' );
  my @all_puppies = $service->list_entries( q => 'puppies' );

  # Adding photos (or video)
  my $photo = $album->add_entry(
      title     => 'plz-to-love-realcat.jpg',
      summary   => 'Real cat wants attention too.',
      mime_type => 'image/jpeg',

      # as a filename
      file      => '/path/to/plz-to-love-realcat.jpg',
      
      # or as an IO handle
      handle    => $plz_to_love_realcat_fh,

      # or as a scalar
      photo     => $plz_to_love_realcat_data,
  );

  # Updating/Deleting photos (or video)
  $photo->title('Plz to love RealCat');
  $photo->save;
  $photo->delete;

  # Listing tags
  my @user_tags  = $service->list_tags( user_id => 'jondoe' );
  my @album_tags = $album->list_tags;
  my @photo_tags = $photo->list_tags;

  # Add tags to/delete tags from a photo
  $photo->add_tag('awesome');
  $photo->delete_tag('awesome');

  # Listing comments (see Net::Google::Photos::Comment)
  my @recent         = $service->list_comments( user_id => 'jondoe', max_results => 10 );
  my @photo_comments = $photo->list_comments;

  # Add/delete comments
  my $comment = $photo->add_comment( content => 'great photo!' );
  $comment->delete;

=head1 ATTRIBUTES

This module uses L<Moose> to handle attributes and such. These attributes are readable, writable, and may be passed to the constructor unless otherwise noted.

=head2 authenticator

This is an L<Net::Google::AuthSub> object used to handle authentication. The default is an instance set to use a service of "lh2" and a source of "Net::Google::Photos-VERSION".

=cut

has authenticator => (
    is => 'rw',
    isa => 'Net::Google::AuthSub',
    default => sub {
        Net::Google::AuthSub->new(
            service => 'lh2', # Picasa Web Albums
            source  => 'Net::Google::Photos-'.$VERSION,
        );
    },
);

=head2 user_agent

This is an L<LWP::UserAgent> object used to handle web communication. 

=cut

has user_agent => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    default => sub {
        LWP::UserAgent->new(
            cookie_jar => {},
        );
    },
);

=head1 METHODS

=head2 new

  my $service = Net::Google::Photos->new(%params);

See the L</ATTRIBUTES> section for a list of possible parameters.

=head2 login

  my $success = $service->login($username, $password, %options);

This is a shortcut for performing:

  $service->authenticator->login($username, $password, %options);

It has some additional error handling. This method will return a true value on success or die on error.

See L<Net::Google::AuthSub>.

=cut

sub login {
    my $self     = shift;
    my $response = $self->authenticator->login(@_);

    croak "Error logging in: $@"                 unless defined $response;
    croak "Error logging in: ", $response->error unless $response->is_success;

    return 1;
}

=head2 list_albums

  my @albums = $service->list_albums(%params);

This will list a set of albums available from Picasa Web Albums. If no C<%params> are set, then this will list the albums belonging to the authenticated user. If the user is not authenticated, this will probably not return anything. Further control is gained by specifying one or more of the following parameters:

=over

=item user_id

This is the user ID to request a list of albums from. The defaults to "default", which lists those belonging to the current authenticated user.

=item access

This is the L<http://code.google.com/apis/picasaweb/reference.html#Visibility|visibility value> to limit the returned results to.

=item thumbsize

By passing a single scalar or an array reference of scalars, you may select the size or sizes of thumbnails attached to the album returned. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|album parameters> documentation for a description of valid values.

=item imgmax

This is a single scalar selecting the size of the main image to return with the albums found. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|album parameters> documentation for a description of valid values.

=item tag

This is a tag name to use to filter the albums returned.

=item q

This is a full-text query string to filter the albums returned.

=item max_results

This is the maximum number of results to be returned.

=item start_index

This is the 1-based index of the first result to be returned.

=item bbox

This is the bounding box of geo coordinates to search for albums within. The coordinates are given as an array reference of exactly 4 values given in the following order: west, south, east, north.

=item l

This may be set to the name of a geo location to search for albums within. For example, "London".

=cut

sub list_albums {
    ### YOU ARE HERE
}

=back

=head2 add_album

=head2 list_tags

=head2 list_comments

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-google-photos at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Google-Photos>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Google::Photos

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Google-Photos>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Google-Photos>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Google-Photos>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Google-Photos>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to Simon Wistow for L<Net::Google::AuthSub>, which took care of all the
authentication details.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Net::Google::Photos
