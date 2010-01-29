use strict;
use warnings;

use Test::More tests => 8;
use Test::Mock::LWP;
use URI;

use_ok('Net::Google::PicasaWeb');

$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );
$Mock_response->set_always( is_error => '' );

my $service = Net::Google::PicasaWeb->new;

# Setup the list albums response
{
    open my $fh, 't/data/list_tags.xml' or die "failed to open test data: $!";
    $Mock_response->set_always( content => do { local $/; <$fh> } );
}

my @tags = $service->list_tags;
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
is($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/default?kind=tag', 'URL is user/default');
is(scalar @tags, 2, 'found 2 tags');

is($tags[0], 'invisible', 'tag 1 is invisible');
is($tags[1], 'bike', 'tag 2 is bike');

$service->list_tags( user_id => 'foobar', q => 'blah' );
is($Mock_request->{new_args}[1], 'GET', 'method is GET');
ok(URI::eq($Mock_request->{new_args}[2], 'http://picasaweb.google.com/data/feed/api/user/foobar?kind=tag&q=blah'), 'URL is user/foobar');
