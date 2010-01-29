use strict;
use warnings;

use Test::More tests => 23;
use Test::Mock::LWP;
use URI;

use_ok('Net::Google::PicasaWeb');

$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );
$Mock_response->set_always( is_error => '' );

my $service = Net::Google::PicasaWeb->new;

# Setup the list photos response
{
    open my $fh, 't/data/get_media_entry.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @photos = $service->get_media_entry(
    album_id => '1234567890',
    photo_id => '0987654321',
);
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/default/albumid/1234567890/photoid/0987654321', 'URL is correct');
is(scalar @photos, 1, 'found 1 photos');

my $media = $photos[0];
is($media->title, 'Nash2.jpg', 'title is Nash2.jpg');
is($media->summary, '', 'summary is empty');
is($media->author_name, 'Chuck G', 'author_name is Chuck G');
is($media->author_uri, 'http://picasaweb.google.com/captaincool', 'author_uri is correct');

my $photo = $media->photo;
is($photo->title, 'Nash2.jpg', 'photo title is correct');
is($photo->description, "", 'photo description is empty');

my $content = $photo->content;
is($content->url, 'http://lh3.ggpht.com/captaincool/R3qvUUE_CtI/AAAAAAAAAUI/6OfFN8oPdVs/Nash2.jpg', 'photo content URL is correct');
is($content->mime_type, 'image/jpeg', 'photo content MIME-Type is image/jpeg');
is($content->medium, 'image', 'photo content medium is image');

my @thumbnails = $photo->thumbnails;
is(scalar @thumbnails, 3, 'photo has 3 thumbnails');

{
    my $thumbnail = $thumbnails[0];
    is($thumbnail->url, 'http://lh3.ggpht.com/captaincool/R3qvUUE_CtI/AAAAAAAAAUI/6OfFN8oPdVs/s72/Nash2.jpg', 'photo thumbnail URL is correct');
    is($thumbnail->height, 54, 'photo thumbnail height is 54');
    is($thumbnail->width, 72, 'photo thumbnail width is 72');
}

{
    my $thumbnail = $thumbnails[1];
    is($thumbnail->url, 'http://lh3.ggpht.com/captaincool/R3qvUUE_CtI/AAAAAAAAAUI/6OfFN8oPdVs/s144/Nash2.jpg', 'photo thumbnail URL is correct');
    is($thumbnail->height, 108, 'photo thumbnail height is 108');
    is($thumbnail->width, 144, 'photo thumbnail width is 144');
}

{
    my $thumbnail = $thumbnails[2];
    is($thumbnail->url, 'http://lh3.ggpht.com/captaincool/R3qvUUE_CtI/AAAAAAAAAUI/6OfFN8oPdVs/s288/Nash2.jpg', 'photo thumbnail URL is correct');
    is($thumbnail->height, 216, 'photo thumbnail height is 216');
    is($thumbnail->width, 288, 'photo thumbnail width is 288');
}
