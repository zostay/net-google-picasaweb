use strict;
use warnings;

use Test::More tests => 4;
use Test::Mock::LWP;

use_ok('Net::Google::PicasaWeb');

# Setup env_proxy()
$Mock_ua->mock( env_proxy => sub { } );
$Mock_ua->set_isa( 'LWP::UserAgent' );

my $service = Net::Google::PicasaWeb->new;

ok($service->login('username', 'password'), 'login success');

$Mock_response->mock( is_success => sub { '' } );

eval {
    $service->login('username', 'password');
};

ok($@, 'got an error on bad response');
like($@, qr/^error logging in: /, 'error starts correctly');
