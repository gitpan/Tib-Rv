# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tib::Rv;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my ( $rv ) = new Tib::Rv;
print $rv->version, "\n";
my ( $msg ) = new Tib::Rv::Msg;
$msg->addString( field => 'value' );
$msg->setSendSubject( "ABC" );
my ( $transport ) = new Tib::Rv::Transport;
my ( $queue ) = new Tib::Rv::Queue;

my ( $listener ) = $queue->createListener( $transport, 'ABC', sub
{
   my ( $msg ) = @_;
   print "Listener: $msg\n";
} );
print "listening on ", $listener->subject, "\n";
my ( $timer ) = $queue->createTimer( 1.5, sub { $transport->send( $msg ) } );
$timer->onEvent;
my ( $status );
my ( $dispatcher ) = $queue->createDispatcher( 2 );
sleep( 5 );
undef $timer;
undef $listener;
$queue->DESTROY( sub { print "finished\n" } );
print "ok 2\n";
