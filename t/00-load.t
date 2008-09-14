#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::Google::Photos' );
}

diag( "Testing Net::Google::Photos $Net::Google::Photos::VERSION, Perl $], $^X" );
