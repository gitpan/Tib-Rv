package Tib::Rv::Event;


use vars qw/ $VERSION /;
$VERSION = '0.02';


use Tib::Rv::Msg;


# package Tib::Rv::Listener (also IOMonitor, Timer) (subclassed from Event?)
# new( $queue, $transport, $subject, $callback );
# get:
# queue( )
# transport( )
# subject( )
# callback( )
# onEvent( $msg )
#   default behaviour: calls $callback( $msg ) if defined $callback
# otherwise, subclass and override onEvent( $msg )
# for IOMonitor, Timer, ignore $msg
# DESTROY: unregister event interest
# $queue->createListener( $transport, $subject, $callback )
# $queue->createIOMonitor( $socket, $ioType, $callback )
# $queue->createTimer( $interval, $callback )
sub new
{
   my ( $proto, $queue, $callback ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { queue => $queue, event => undef }, $class;

   $self->{callback} = defined $callback ? $callback : sub { print "@_\n" };
   $self->{internal_nomsg_callback} = sub { $self->onEvent( ) };
   $self->{internal_msg_callback} =
      sub { $self->onEvent( Tib::Rv::Msg->_adopt( shift ) ) };

   return $self;
}


sub queue { return shift->{queue} }
sub callback { return shift->{callback} }


sub onEvent
{
   my ( $self, $msg ) = @_;
   my ( @args ) = defined $msg ? ( $msg ) : ( );
   $self->callback->( @args );
}


# callback not supported
sub DESTROY
{
   my ( $self ) = @_;
   return unless ( exists $self->{event} );

   my ( $status ) = Tib::Rv::Event_DestroyEx( $self->{event} );
   delete $self->{event};
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;
