package Tib::Rv::Dispatcher;


use vars qw/ $VERSION /;
$VERSION = '0.02';


# mebbe have a master QueueGroup that everything automatically
# gets added to, then a $rv->loop( ) that dispatches on QueueGroup
# w/a exit flag?
# add default queue to the queue group (in Tib::Rv new)
# $rv->createTimer, createIOMonitor, createListener
#   => default queue->createWhatever
sub new
{
   my ( $proto, $dispatchable, $idleTimeout ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) =
      bless { dispatcher => undef, dispatchable => $dispatchable }, $class;
   $self->{idleTimeout} =
      defined $idleTimeout ? $idleTimeout : Tib::Rv::WAIT_FOREVER;

   my ( $status ) = Tib::Rv::Dispatcher_Create( $self->{dispatcher},
      $dispatchable->{queue}, $self->{idleTimeout} );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub dispatchable { return shift->{dispatchable} }
sub idleTimeout { return shift->{idleTimeout} }


# blah -- tibrvDispatcher_Destroy gets called automatically when
# idleTimeout times out, or you can call it manually!
# how would the idleTimeout inform this object?  Listening on
# DISPATCHER.THREAD_EXITED?
sub DESTROY
{
   my ( $self ) = @_;
   return unless ( exists $self->{dispatcher} );

   my ( $status ) = Tib::Rv::tibrvDispatcher_Destroy( $self->{dispatcher} );
   delete $self->{dispatcher};
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;
