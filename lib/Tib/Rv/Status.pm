package Tib::Rv::Status;


use vars qw/ $VERSION /;
$VERSION = '0.02';


use overload '""' => 'convertToString', '0+' => 'convertToNum', fallback => 1;


sub new
{
   my ( $proto, $status ) = @_;
   my ( $class ) = ref( $proto ) || $proto;
   my ( $self ) = bless { status => $status }, $class;
   return $self;
}


sub convertToString { return Tib::Rv::tibrvStatus_GetText( shift->{status} ) }
sub convertToNum { return shift->{status} }


1;
