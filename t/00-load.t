#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'baconBits' ) || print "Bail out!\n";
}

diag( "Testing baconBits $baconBits::VERSION, Perl $], $^X" );
