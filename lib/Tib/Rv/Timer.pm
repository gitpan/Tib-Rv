package Tib::Rv::Timer;
use base qw/ Tib::Rv::Event /;


use vars qw/ $VERSION /;
$VERSION = '0.02';


# 1.
# my ( $timer ) =
#    new Tib::Rv::Timer( $queue, $interval, sub { .. } );
# 2.
# my ( $timer ) = $queue->createTimer( $interval, sub { .. } );
# 3.
# package Tib::Rv::MyTimer;
# use base qw/ Tib::Rv::Timer /;
# sub new { .. }
# sub onEvent { .. }
sub new
{
   my ( $proto, $queue, $interval, $callback ) = @_;
   my ( $self ) = $proto->SUPER::new( $queue, $callback );

   $self->{interval} = $interval;

   my ( $status ) = Tib::Rv::Event_CreateTimer( $self->{event},
      $self->{queue}{queue}, $self->{internal_nomsg_callback}, $interval );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub interval
{
   my ( $self, $newInterval ) = @_;
   $self->resetTimerInterval( $newInterval ) if ( defined $newInterval );
   return $self->{interval};
}


sub resetTimerInterval
{
   my ( $self, $newInterval ) = @_;
   my ( $status ) =
      Tib::Rv::tibrvEvent_ResetTimerInterval( $self->{event}, $newInterval );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
   return $self->{interval} = $newInterval;
}


1;
