package Tib::Rv::IOMonitor;
use base qw/ Tib::Rv::Event /;


use vars qw/ $VERSION /;
$VERSION = '0.02';


sub new
{
   my ( $proto, $queue, $callback ) = @_;
   my ( $self ) = $proto->SUPER::new( $queue, $callback );

#   $self->{interval} = $interval;

#   my ( $status ) = Tib::Rv::Event_CreateTimer( $self->{event},
#      $self->{queue}{queue}, $self->{internal_nomsg_callback}, $interval );
#   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


1;
