package Tib::Rv::Listener;
use base qw/ Tib::Rv::Event /;


use vars qw/ $VERSION /;
$VERSION = '0.02';


# 1.
# my ( $event ) =
#    new Tib::Rv::Listener( $queue, $transport, $subject, sub { .. } );
# 2.
# my ( $event ) = $queue->createListener( $transport, $subject, sub { .. } );
# 3.
# package Tib::Rv::MyListener;
# use base qw/ Tib::Rv::Listener /;
# sub new { .. }
# sub onEvent { .. }
sub new
{
   my ( $proto, $queue, $transport, $subject, $callback ) = @_;
   my ( $self ) = $proto->SUPER::new( $queue, $callback );

   @{ $self }{ qw/ transport subject / } = ( $transport, $subject );

   my ( $status ) = Tib::Rv::Event_CreateListener( $self->{event},
      $self->{queue}{queue}, $self->{internal_msg_callback},
      $self->{transport}{transport}, $self->{subject} );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub transport { return shift->{transport} }
sub subject { return shift->{subject} }


1;
