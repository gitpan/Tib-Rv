package Tib::Rv::Msg;


use vars qw/ $VERSION /;
$VERSION = '0.02';


use overload '""' => 'convertToString';
sub new
{
   my ( $proto ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { msg => undef }, $class;

   my ( $status ) = Tib::Rv::Msg_Create( $self->{msg} );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return $self;
}


sub _adopt
{
# mebbe two ways:
# Tib::Rv::Msg->_adopt( $msg ) -- create new
# existing $msg; $msg->_adopt( $msg ) -- reset self, throw this guy in
   my ( $proto, $msg ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { msg => $msg }, $class;
   return $self;
}


sub convertToString
{
   my ( $self ) = @_;
   my ( $str );
   my ( $status ) = Tib::Rv::Msg_ConvertToString( $self->{msg}, $str );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
   return $str;
}


sub addString
{
   my ( $self, $fieldName, $value, $fieldId ) = @_;
   $fieldId = 0 unless ( defined $fieldId );
   my ( $status ) = Tib::Rv::tibrvMsg_AddStringEx(
      $self->{msg}, $fieldName, $value, $fieldId );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


sub setSendSubject
{
   my ( $self, $subject ) = @_;
   my ( $status ) = Tib::Rv::tibrvMsg_SetSendSubject( $self->{msg}, $subject );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


sub DESTROY
{
   my ( $self ) = @_;
   return unless ( exists $self->{msg} );

   my ( $status ) = Tib::Rv::tibrvMsg_Destroy( $self->{msg} );
   delete $self->{msg};
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;
