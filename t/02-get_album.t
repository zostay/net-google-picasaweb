use strict;
use warnings;

use Test::More tests => 21;
use Test::Mock::LWP;
use URI;

use_ok('Net::Google::PicasaWeb');

$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );
$Mock_response->set_always( is_error => '' );

my $service = Net::Google::PicasaWeb->new;

# Setup the list albums response
{
    open my $fh, 't/data/get_album.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @albums = $service->get_album( album_id => '1234567890' );
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/default/albumid/1234567890', 'URL is correct');
is(scalar @albums, 1, 'found 1 albums');

my $album = $albums[0];
is($album->title, 'lolcats', 'title is lolcats');
is($album->summary, 'Hilarious Felines', 'summary is Hilarious Felines');
is($album->author_name, 'Liz', 'author_name is Liz');
is($album->author_uri, 'http://picasaweb.google.com/liz', 'author_uri is correct');

my $photo = $album->photo;
is($photo->title, 'lolcats', 'photo title is correct');
is($photo->description, "Hilarious Felines", 'photo description is correct');

$Mock_response->set_always( is_success => 1 );
$Mock_response->set_always( content => 'FAKE DATA' );
$Mock_ua->mock( get => sub { my $self = shift; $self->{get_args} = \@_; $Mock_response } );

my $content = $photo->content;
is($content->url, 'http://lh5.ggpht.com/liz/SI4jmlkNUFE/AAAAAAAAAzU/J1V3PUhHEoI/Lolcats.jpg', 'photo content URL is correct');
is($content->mime_type, 'image/jpeg', 'photo content MIME-Type is image/jpeg');
is($content->medium, 'image', 'photo content medium is image');
is($content->fetch, 'FAKE DATA', 'fetched the data');

is($Mock_ua->{get_args}[0], $content->url, 'URL is correct');

my @thumbnails = $photo->thumbnails;
is(scalar @thumbnails, 1, 'photo has 1 thumbnail');

my $thumbnail = $thumbnails[0];
is($thumbnail->url, 'http://lh5.ggpht.com/liz/SI4jmlkNUFE/AAAAAAAAAzU/J1V3PUhHEoI/s160-c/Lolcats.jpg', 'photo thumbnail URL is correct');
is($thumbnail->height, 160, 'photo thumbnail height is 160');
is($thumbnail->width, 160, 'photo thumbnail width is 160');
is($thumbnail->fetch, 'FAKE DATA', 'fetched the data');

is($Mock_ua->{get_args}[0], $thumbnail->url, 'URL is correct');
