package Tib::Rv::Transport;


use vars qw/ $VERSION /;
$VERSION = '0.02';


sub new
{
   my ( $proto, $service, $network, $daemon ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { transport => undef }, $class;

   my ( $status ) = Tib::Rv::Transport_Create( $self->{transport},
      $service, $network, $daemon );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub send
{
   my ( $self, $msg ) = @_;
   my ( $status ) =
      Tib::Rv::tibrvTransport_Send( $self->{transport}, $msg->{msg} );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


sub DESTROY
{
   my ( $self ) = @_;
   return unless ( defined $self->{transport} );

   my ( $status ) = Tib::Rv::tibrvTransport_Destroy( $self->{transport} );
   delete $self->{transport};
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;
