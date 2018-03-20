/*
 * $Id: hmonthc.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HMonthCalendar class
 *
 * Copyright 2008 Luiz Rafael Culik (luiz at xharbour.com.br
 * www - http://www.xharbour.org
*/

//--------------------------------------------------------------------------//


#include "hbclass.ch"
#include "guilib.ch"

#define MCS_DAYSTATE             1
#define MCS_MULTISELECT          2
#define MCS_WEEKNUMBERS          4
#define MCS_NOTODAYCIRCLE        8
#define MCS_NOTODAY             16

//--------------------------------------------------------------------------//

CLASS HMonthCalendar INHERIT HControl

   CLASS VAR winclass   INIT "SysMonthCal32"

   DATA value
   DATA bChange

   METHOD New( oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
               oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
               lWeekNumbers )
   METHOD Activate()
   METHOD Init()
   METHOD SetValue( dValue )
   METHOD GetValue()

ENDCLASS

//--------------------------------------------------------------------------//

METHOD New( oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
            oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
            lWeekNumbers ) CLASS HMonthCalendar

   ::Super:New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,bInit, ;
                  ,,ctooltip )

   ::value   := Iif( Valtype(vari)=="D" .And. !Empty(vari), vari, Date() )

   ::bChange := bChange

   ::Activate()
Return Self

//--------------------------------------------------------------------------//

METHOD Activate CLASS HMonthCalendar

   If !empty(::oParent:handle )
      ::handle := hwg_Initmonthcalendar ( ::oParent:handle, , ;
                  ::nLeft, ::nTop, ::nWidth, ::nHeight )
      hwg_Setwindowobject( ::handle,Self )		  
//      MonthCalendarChange(::handle,{||
        hwg_Monthcalendar_setaction(::handle,{||::value:=hwg_Getmonthcalendardate( ::handle )})
      ::Init()
   EndIf

Return Nil

//--------------------------------------------------------------------------//

METHOD Init() CLASS HMonthCalendar

   If !::lInit
      ::Super:Init()
      If !Empty( ::value )
         hwg_Setmonthcalendardate( ::handle , ::value )
      EndIf
   EndIf

Return Nil

//--------------------------------------------------------------------------//

METHOD SetValue( dValue ) CLASS HMonthCalendar

   If Valtype(dValue)=="D" .And. !Empty(dValue)
      hwg_Setmonthcalendardate( ::handle, dValue )
      ::value := dValue
   EndIf

Return Nil

//--------------------------------------------------------------------------//

METHOD GetValue() CLASS HMonthCalendar

//   ::value := 

Return (::value)
