use strict;
use warnings;

use Test::More tests => 37;
use Test::Mock::LWP;
use URI;

use_ok('Net::Google::PicasaWeb');

$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );
$Mock_response->set_always( is_error => '' );

my $service = Net::Google::PicasaWeb->new;

# Setup the list photos response
{
    open my $fh, 't/data/list_media_entries.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @photos = $service->list_media_entries;
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/all?kind=photo', 'URL is all');
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

$service->list_photos( user_id => 'foobar', q => 'blah' );
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
ok(URI::eq($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/foobar?kind=photo&q=blah'), 'URL is user/foobar');

# Setup the list albums response
{
    open my $fh, 't/data/list_tags.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @tags = $media->list_tags;
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/captaincool/albumid/5149978741790672209/photoid/5150621887373445842?kind=tag', 'URL is photoid URL');
is(scalar @tags, 2, 'found 2 tags');

is($tags[0], 'invisible', 'tag 1 is invisible');
is($tags[1], 'bike', 'tag 2 is bike');

# Setup the list comments response
{
    open my $fh, 't/data/list_comments.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @comments = $media->list_comments;
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/captaincool/albumid/5149978741790672209/photoid/5150621887373445842?kind=comment', 'URL is photoid URL');
is(scalar @comments, 1, 'found 1 comments');

my $comment = $comments[0];
is($comment->title, 'Liz', 'title is Liz');
is($comment->content, 'I do say! What an amusing image!', 'content is correct');
is($comment->author_name, 'Liz', 'author_name is Liz');
is($comment->author_uri, 'http://picasaweb.google.com/liz', 'author_uri is correct');

