use strict;
use warnings;

use Test::More tests => 10;
use Test::Mock::LWP;
use URI;

use_ok('Net::Google::PicasaWeb');

$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );
$Mock_response->set_always( is_error => '' );

my $service = Net::Google::PicasaWeb->new;

# Setup the list comments response
{
    open my $fh, 't/data/list_comments.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @comments = $service->list_comments;
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/default?kind=comment', 'URL is user/default');
is(scalar @comments, 1, 'found 1 comments');

my $comment = $comments[0];
is($comment->title, 'Liz', 'title is Liz');
is($comment->content, 'I do say! What an amusing image!', 'content is correct');
is($comment->author_name, 'Liz', 'author_name is Liz');
is($comment->author_uri, 'http://picasaweb.google.com/liz', 'author_uri is correct');

$service->list_comments( user_id => 'foobar', q => 'blah' );
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
ok(URI::eq($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/foobar?kind=comment&q=blah'), 'URL is user/foobar');
