use warnings;
use strict;

package Net::Google::PicasaWeb;
use Moose;

use Carp;
use HTTP::Request::Common;
use LWP::UserAgent;
use Net::Google::AuthSub;
use URI;
use XML::Twig;

use Net::Google::PicasaWeb::Album;
use Net::Google::PicasaWeb::Comment;
use Net::Google::PicasaWeb::MediaEntry;

=head1 NAME

Net::Google::PicasaWeb - use Google's Picasa Web API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

  use Net::Google::PicasaWeb;

  my $service = Net::Google::PicasaWeb->new;

  # Login via one of these
  $service->login('jondoe@gmail.com', 'north23AZ');

  # Working with albums (see Net::Google::PicasaWeb::Album)
  my @albums = $service->list_albums( user_id => 'jondoe');
  $album->title('Quick Trip To Italy');

  # Listing photos (see Net::Google::PicasaWeb::MediaEntry)
  my @photos      = $album->list_media_entries; 
  my @recent      = $album->list_media_entries( max_results => 10 );
  my @puppies     = $album->list_media_entries( q => 'puppies' );
  my @all_puppies = $service->list_media_entries( q => 'puppies' );

  # Updating/Deleting photos (or video)
  $photo->title('Plz to love RealCat');

  # Listing tags
  my @user_tags  = $service->list_tags( user_id => 'jondoe' );
  my @album_tags = $album->list_tags;
  my @photo_tags = $photo->list_tags;

  # Listing comments (see Net::Google::PicasaWeb::Comment)
  my @recent         = $service->list_comments( user_id => 'jondoe', max_results => 10 );
  my @photo_comments = $photo->list_comments;

=head1 ATTRIBUTES

This module uses L<Moose> to handle attributes and such. These attributes are readable, writable, and may be passed to the constructor unless otherwise noted.

=head2 authenticator

This is an L<Net::Google::AuthSub> object used to handle authentication. The default is an instance set to use a service of "lh2" and a source of "Net::Google::PicasaWeb-VERSION".

=cut

has authenticator => (
    is => 'rw',
    isa => 'Net::Google::AuthSub',
    default => sub {
        Net::Google::AuthSub->new(
            service => 'lh2', # Picasa Web Albums
            source  => 'Net::Google::PicasaWeb-'.$VERSION,
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

  my $service = Net::Google::PicasaWeb->new(%params);

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

=back

This method also takes the L</STANDARD LIST OPTIONS>.

=cut

sub list_albums {
    my ($self, %params) = @_;
    $params{kind} = 'album';

    my $user_id = delete $params{user_id} || 'default';
    return $self->list_entries(
        'Net::Google::PicasaWeb::Album',
        [ 'user', $user_id ],
        %params
    );
}

=head2 list_tags

Returns a list of tags that have been used by the logged user or the user named in the C<user_id> parameter.

This method accepts this parameters:

=over

=item user_id

The ID of the user to find tags for. Defaults to the current user.

=back

This method also takes all the L</STANDARD LIST OPTIONS>.

=cut

# This is a tiny cheat that allows us to reuse the list_entries method
{
    package Net::Google::PicasaWeb::Tag;

    sub from_feed {
        my ($class, $service, $entry) = @_;
        return $entry->field('title');
    }
}

sub list_tags {
    my ($self, %params) = @_;
    $params{kind} = 'tag';

    my $user_id = delete $params{user_id} || 'default';
    return $self->list_entries(
        'Net::Google::PicasaWeb::Tag',
        [ 'user', $user_id ],
        %params
    );
}

=head2 list_comments

Returns comments on photos for the current account or the account given by the C<user_id> parameter.

It accepts the following parameters:

=over

=item user_id

This is the ID of the user to search for comments within. The comments returned will be commons on photos owned by this user. The default is to search the comments of the authenticated user.

=back

This method also accepts the L</STANDARD LIST OPTIONS>.

=cut

sub list_comments {
    my ($self, %params) = @_;
    $params{kind} = 'comment';

    my $user_id = delete $params{user_id} || 'default';
    return $self->list_entries(
        'Net::Google::PicasaWeb::Comment',
        [ 'user', $user_id ],
        %params
    );
}

sub _feed_url {
    my ($self, $path, $query) = @_;

    $path = join '/', @$path if ref $path;

    my $uri = URI->new('http://picasaweb.google.com/data/feed/api/' . $path);
    $uri->query_form($query) if $query;

    return $uri;
}

=head2 list_media_entries

=head2 list_photos

=head2 list_videos

Returns photos and videos based on the query options given. If a C<user_id> option is set, the photos returned will be those related to the named user ID. Without a user ID, the photos will be pulled from the general community feed.

It accepts the following parameters:

=over

=item user_id

If given, the photos will be limited to those owned by this user. If it is set to "default", then the authenticated user will be used. If no C<user_id> is set, then the community feed will be used rather than a specific user.

=back

This method also accepts the L</STANDARD LIST OPTIONS>.

The L</list_photos> and L</list_videos> methods are synonyms for L</list_media_entries>.

=cut

sub list_media_entries {
    my ($self, %params) = @_;
    $params{kind} = 'photo';

    my $user_id = delete $params{user_id};
    my $path   = [ 'user', $user_id ] if $user_id;
       $path ||= 'all';

    return $self->list_entries(
        'Net::Google::PicasaWeb::MediaEntry',
        $path,
        %params
    );
}

*list_photos = *list_media_entries;
*list_videos = *list_media_entries;

=head1 HELPERS

These helper methods are used to do some of the work.

=head2 request

  my $response = $service->request($method, $path, $query, $content);

This handles the details of making a request to the Google Picasa Web API.

=cut

sub request {
    my $self    = shift;
    my $method  = shift;
    my $path    = shift;
    my $query   = $method eq 'GET' ? shift : undef;
    my $content = shift;

    my @headers = $self->authenticator->auth_params;

    my $url = $self->_feed_url($path, $query);
    
    my $request;
    {
        local $_ = $method;
        if    (/GET/)    { $request = GET   ($url, @headers) }
        elsif (/POST/)   { $request = POST  ($url, @headers, Content => $content) }
        elsif (/PUT/)    { $request = PUT   ($url, @headers, Content => $content) }
        elsif (/DELETE/) { $request = DELETE($url, @headers) }
        else             { confess "unkonwn method [$_]" }
    }

    return $self->user_agent->request($request);
}

=head2 list_entries

  my @entries = $service->list_entries($class, $path, %params);

This is used by the C<list_*> methods to pull and initialize lists of objects from feeds.

=cut

sub list_entries {
    my ($self, $class, $path, %params) = @_;

    my $response = $self->request( GET => $path => [ %params ] );

    if ($response->is_error) {
        croak $response->status_line;
    }

    my @items;
    my $feed = XML::Twig->new( 
        map_xmlns => {
            'http://search.yahoo.com/mrss/'         => 'media',
            'http://schemas.google.com/photos/2007' => 'gphoto',
        },
        twig_handlers => {
            'entry' => sub {
                push @items, $class->from_feed($self, $_);
            },
        },
    );
    $feed->parse($response->content);

    return @items;
}


=head1 STANDARD LIST OPTIONS

Several of the listing methods return entries that can be modified by setting the following options.

=over

=item access

This is the L<http://code.google.com/apis/picasaweb/reference.html#Visibility|visibility value> to limit the returned results to.

=item thumbsize

This option is only used when listing albums and photos or videos.

By passing a single scalar or an array reference of scalars, you may select the size or sizes of thumbnails attached to the items returned. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|parameters> documentation for a description of valid values.

=item imgmax

This option is only used when listing albums and photos or videos.

This is a single scalar selecting the size of the main image to return with the items found. Please see the L<http://code.google.com/apis/picasaweb/reference.html#Parameters|parameters> documentation for a description of valid values.

=item tag

This option is only used when listing albums and photos or videos.

This is a tag name to use to filter the items returned.

=item q

This is a full-text query string to filter the items returned.

=item max_results

This is the maximum number of results to be returned.

=item start_index

This is the 1-based index of the first result to be returned.

=item bbox

This option is only used when listing albums and photos or videos.

This is the bounding box of geo coordinates to search for items within. The coordinates are given as an array reference of exactly 4 values given in the following order: west, south, east, north.

=item l

This option is only used when listing albums and photos or videos.

This may be set to the name of a geo location to search for items within. For example, "London".

=back

=head1 AUTHOR

Andrew Sterling Hanenkamp, C<< <hanenkamp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-google-photos at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Google-PicasaWeb>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Google::PicasaWeb

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Google-PicasaWeb>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Google-PicasaWeb>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Google-PicasaWeb>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Google-PicasaWeb>

=back

=head1 ACKNOWLEDGEMENTS

Thanks to:

=over

=item *

Robert May for responding to email messages quickly and transfering ownership of the C<Net::Google::PicasaWeb> namespace and providing some sample code to examine.

=item *

Simon Wistow for L<Net::Google::AuthSub>, which took care of all the authentication details.

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Andrew Sterling Hanenkamp

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Net::Google::PicasaWeb
