package Tib::Rv::Queue;


use vars qw/ $VERSION /;
$VERSION = '0.02';


use Tib::Rv::Listener;
use Tib::Rv::Timer;
use Tib::Rv::IOMonitor;
use Tib::Rv::Dispatcher;


sub new
{
   my ( $proto ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { queue => undef }, $class;

   my ( $status ) = Tib::Rv::Queue_Create( $self->{queue} );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub createListener
{
   my ( $self, $transport, $subject, $callback ) = @_;
   return new Tib::Rv::Listener( $self, $transport, $subject, $callback );
}


sub createTimer
{
   my ( $self, $interval, $callback ) = @_;
   return new Tib::Rv::Timer( $self, $interval, $callback );
}


sub createIOMonitor
{
   my ( $self, $callback ) = @_;
   return new Tib::Rv::IOMonitor( $self, $callback );
}


sub timedDispatch
{
   my ( $self, $timeout ) = @_;
   my ( $status ) =
      Tib::Rv::tibrvQueue_TimedDispatch( $self->{queue}, $timeout );
   Tib::Rv::die( $status )
      unless ( $status == Tib::Rv::OK or $status == Tib::Rv::TIMEOUT );
   return $status;
}


sub createDispatcher
{
   my ( $self, $idleTimeout ) = @_;
   return new Tib::Rv::Dispatcher( $self, $idleTimeout );
}


sub DESTROY
{
   my ( $self, $callback ) = @_;
   return unless ( exists $self->{queue} );

   my ( $status ) = Tib::Rv::Queue_DestroyEx( $self->{queue}, $callback );
   delete $self->{queue};
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;
