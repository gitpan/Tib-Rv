package Tib::Rv;


use vars qw/ $VERSION /;

BEGIN
{
   $VERSION = '0.02';
   my ( $env_err ) = q/one of: TIB_HOME, TIB_RV_HOME, or TIBRV_DIR must be set
TIB_HOME must be your base Tibco directory, and it must contain "tibrv"; or:
TIB_RV_HOME or TIBRV_DIR must be your Rendezvous installation directory
/;
   unless ( exists $ENV{TIB_RV_HOME} )
   {
      if ( exists $ENV{TIBRV_DIR} )
      {
         $ENV{TIB_RV_HOME} = $ENV{TIBRV_DIR};
      } elsif ( exists $ENV{TIB_HOME} ) {
         $ENV{TIB_RV_HOME} = "$ENV{TIB_HOME}/tibrv";
      }
   }
   die $env_err
      unless ( -d "$ENV{TIB_RV_HOME}/include" and -d "$ENV{TIB_RV_HOME}/lib" );
}

use Inline C => Config =>
   AUTOWRAP => 'ENABLE',
   TYPEMAPS => 'typemap',
   LIBS => "-L$ENV{TIB_RV_HOME}/lib -ltibrv",
   INC => "-I$ENV{TIB_RV_HOME}/include";
use Inline C => 'DATA', NAME => 'Tib::Rv', VERSION => $VERSION;


use Carp;

use Tib::Rv::Status;
use Tib::Rv::Transport;
use Tib::Rv::QueueGroup;


use constant OK => 0;

use constant INIT_FAILURE => 1;
use constant INVALID_TRANSPORT => 2;
use constant INVALID_ARG => 3;
use constant NOT_INITIALIZED => 4;
use constant ARG_CONFLICT => 5;

use constant SERVICE_NOT_FOUND => 16;
use constant NETWORK_NOT_FOUND => 17;
use constant DAEMON_NOT_FOUND => 18;
use constant NO_MEMORY => 19;
use constant INVALID_SUBJECT => 20;
use constant DAEMON_NOT_CONNECTED => 21;
use constant VERSION_MISMATCH => 22;
use constant SUBJECT_COLLISION => 23;
use constant VC_NOT_CONNECTED => 24;

use constant NOT_PERMITTED => 27;

use constant INVALID_NAME => 30;
use constant INVALID_TYPE => 31;
use constant INVALID_SIZE => 32;
use constant INVALID_COUNT => 33;

use constant NOT_FOUND => 35;
use constant ID_IN_USE => 36;
use constant ID_CONFLICT => 37;
use constant CONVERSION_FAILED => 38;
use constant RESERVED_HANDLER => 39;
use constant ENCODER_FAILED => 40;
use constant DECODER_FAILED => 41;
use constant INVALID_MSG => 42;
use constant INVALID_FIELD => 43;
use constant INVALID_INSTANCE => 44;
use constant CORRUPT_MSG => 45;

use constant TIMEOUT => 50;
use constant INTR => 51;

use constant INVALID_DISPATCHABLE => 52;
use constant INVALID_DISPATCHER => 53;

use constant INVALID_EVENT => 60;
use constant INVALID_CALLBACK => 61;
use constant INVALID_QUEUE => 62;
use constant INVALID_QUEUE_GROUP => 63;

use constant INVALID_TIME_INTERVAL => 64;

use constant INVALID_IO_SOURCE => 65;
use constant INVALID_IO_CONDITION => 66;
use constant SOCKET_LIMIT => 67;

use constant OS_ERROR => 68;

use constant INSUFFICIENT_BUFFER => 70;
use constant EOF => 71;
use constant INVALID_FILE => 72;
use constant FILE_NOT_FOUND => 73;
use constant IO_FAILED => 74;

use constant NOT_FILE_OWNER => 80;

use constant TOO_MANY_NEIGHBORS => 90;
use constant ALREADY_EXISTS => 91;

use constant PORT_BUSY => 100;


sub die
{
   my ( $status ) = @_;
   $status = new Tib::Rv::Status( $status )
      unless ( UNIVERSAL::isa( $status, 'Tib::Rv::Status' ) );
   local( $Carp::CarpLevel ) = 1;
   croak "$status\n";
}


sub version
{
   return 'tibrv ' . tibrv_Version( ) . "; Tib::Rv $VERSION";
}


sub new
{
   my ( $proto ) = @_;
   my ( $class ) = ref( $proto ) || $proto;

   my ( $status ) = tibrv_Open( );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );

   return bless { }, $class;
}


sub DESTROY
{
   my ( $self ) = @_;

   my ( $status ) = tibrv_Close( );
   Tib::Rv::die( $status ) unless ( $status == Tib::Rv::OK );
}


1;


__DATA__

=pod

=head1 NAME

Tib::Rv - Perl bindings and Object-Oriented library for TIBCO's TIB/Rendezvous

=head1 SYNOPSIS

	use Tib::Rv;

	my ( $rv ) = new Tib::Rv;

	my ( $msg ) = new Tib::Rv::Msg;
	$msg->addString( field => 'value' );
	$msg->setSendSubject( 'ABC' );

	my ( $transport ) = new Tib::Rv::Transport;
	my ( $queue ) = new Tib::Rv::Queue;

	my ( $listener ) = $queue->createListener( $transport, 'ABC', sub
	{
	   my ( $msg ) = @_;
	   print "I got a message: $msg\n";
	} );
	my ( $timer ) =
	   $queue->createTimer( 1.5, sub { $transport->send( $msg ) } );
	$timer->onEvent;
	my ( $dispatcher ) = $queue->createDispatcher( 2 );
	sleep( 5 );

=head1 DESCRIPTION


=head1 AUTHOR

Paul Sturm, sturm@branewave.com


TIB/Rendezvous copyright notice:

/*
 * Copyright (c) 1998-2000 TIBCO Software Inc.
 * All rights reserved.
 * TIB/Rendezvous is protected under US Patent No. 5,187,787.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 *
 * @(#)tibrv.h  2.9
 */


=head1 SEE ALSO

http://www.tibco.com
file:///$TIB_HOME/tibrv/doc

=cut


__C__

#include <tibrv/tibrv.h>


tibrv_status tibrv_Open( );
tibrv_status tibrv_Close( );
const char * tibrv_Version( );
const char * tibrvStatus_GetText( tibrv_status status );
tibrv_status tibrvMsg_Destroy( tibrvMsg message );
tibrv_status tibrvMsg_AddStringEx( tibrvMsg message,
   const char * fieldName, const char * value, tibrv_u16 fieldId );
tibrv_status tibrvMsg_SetSendSubject( tibrvMsg message, const char * subject); 
tibrv_status tibrvTransport_Destroy( tibrvTransport transport );
tibrv_status tibrvTransport_Send( tibrvTransport transport, tibrvMsg message );
tibrv_status tibrvQueue_TimedDispatch( tibrvQueue queue, tibrv_f64 timeout );
tibrv_status tibrvEvent_ResetTimerInterval( tibrvEvent event,
   tibrv_f64 newInterval );
tibrv_status tibrvDispatcher_Destroy( tibrvDispatchable dispatcher );



tibrv_status Msg_Create( SV * sv_message )
{
   tibrvMsg message = (tibrvMsg)NULL;
   tibrv_status status = tibrvMsg_Create( &message );
   sv_setiv( sv_message, (IV)message );
   return status;
}


tibrv_status Msg_ConvertToString( tibrvMsg message, SV * string )
{
   const char ** str;
   tibrv_status status = tibrvMsg_ConvertToString( message, str );
   sv_setpv( string, *str );
   return status;
}


tibrv_status Transport_Create( SV * sv_transport, const char * service,
   const char * network, const char * daemon ) 
{
   tibrvTransport transport = (tibrvTransport)NULL;
   tibrv_status status =
      tibrvTransport_Create( &transport, service, network, daemon );
   sv_setiv( sv_transport, (IV)transport );
   return status;
}


tibrv_status Queue_Create( SV * sv_queue )
{
   tibrvQueue queue = (tibrvQueue)NULL;
   tibrv_status status = tibrvQueue_Create( &queue );
   sv_setiv( sv_queue, (IV)queue );
   return status;
}


static void Queue_Destroyer( tibrvQueue destroyedQueue, void * closure )
{
   dSP;
   PUSHMARK( SP );
   perl_call_sv( (SV *)closure, G_VOID | G_DISCARD );
}


tibrv_status Queue_DestroyEx( tibrvQueue queue, SV * callback )
{
   tibrvQueueOnComplete completionFn = NULL;
   if ( SvOK( callback ) ) completionFn = Queue_Destroyer;
   return tibrvQueue_DestroyEx( queue, completionFn, callback );
}


/*
static void Event_Destroyer( tibrvQueue destroyedQueue, void * closure )
{
   dSP;
   PUSHMARK( SP );
   perl_call_sv( (SV *)closure, G_VOID | G_DISCARD );
}
*/


/* no closure data here -- it gets closure data from constructor
 * so to support this, we'd have to store both callbacks in the closure
 * and have a "completionCallback" parameter in constructor
 */
tibrv_status Event_DestroyEx( tibrvEvent event )
{
   return tibrvEvent_DestroyEx( event, NULL );
}


static void event_nomsg_callback( SV * callback )
{
   dSP;
   PUSHMARK( SP );
   perl_call_sv( callback, G_VOID | G_DISCARD );
}


void Event_Listener( tibrvEvent event, tibrvMsg message, void * closure )
{
   dSP;

   ENTER;
   SAVETMPS;

   PUSHMARK( SP );
   XPUSHs( sv_2mortal( newSViv( (IV)message ) ) );
   PUTBACK;

   perl_call_sv( (SV *)closure, G_VOID | G_DISCARD );

   FREETMPS;
   LEAVE;
}


tibrv_status Event_CreateListener( SV * sv_event, tibrvQueue queue,
   SV * callback, tibrvTransport transport, const char * subject )
{
   tibrvEvent event = (tibrvEvent)NULL;
   tibrv_status status = tibrvEvent_CreateListener( &event, queue,
      Event_Listener, transport, subject, callback );
   sv_setiv( sv_event, (IV)event );
   return status;
}


void Event_Timer( tibrvEvent event, tibrvMsg message, void * closure )
{
   event_nomsg_callback( (SV *)closure );
}


tibrv_status Event_CreateTimer( SV * sv_event, tibrvQueue queue,
   SV * callback, tibrv_f64 interval )
{
   tibrvEvent event = (tibrvEvent)NULL;
   tibrv_status status = tibrvEvent_CreateTimer( &event, queue, Event_Timer,
      interval, callback );
   sv_setiv( sv_event, (IV)event );
   return status;
}


tibrv_status Dispatcher_Create( SV * sv_dispatcher,
   tibrvDispatchable dispatchable, tibrv_f64 idleTimeout )
{
   tibrvDispatcher dispatcher = (tibrvDispatcher)NULL;
   tibrv_status status = tibrvDispatcher_CreateEx( &dispatcher, dispatchable,
      idleTimeout );
printf( "Dispatcher_Create( %lf )\n", idleTimeout );
   sv_setiv( sv_dispatcher, (IV)dispatcher );
   return status;
}
