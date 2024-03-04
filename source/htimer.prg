/*
 * $Id: htimer.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HTimer class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TIMER_FIRST_ID 33900

//-------------------------------------------------------------------------------------------------------------------//

CLASS HTimer INHERIT HObject

   CLASS VAR aTimers INIT {}

   DATA lInit INIT .F.
   DATA id
   DATA value
   DATA oParent
   DATA bAction

   DATA xName HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE IIf(!Empty(cName) .AND. hb_IsChar(cName) .AND. !(":" $ cName) .AND. !("[" $ cName), ;
      (::xName := cName, __objAddData(::oParent, cName), ::oParent: &(cName) := SELF), NIL)
   ACCESS Interval INLINE ::value
   ASSIGN Interval(x) INLINE ::value := x, hwg_Settimer(::oParent:handle, ::id, ::value)

   METHOD New(oParent, nId, value, bAction)
   METHOD Init()
   METHOD OnAction()
   METHOD End()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD New(oParent, nId, value, bAction) CLASS HTimer

   ::oParent := IIf(oParent == NIL, HWindow():GetMain():oDefaultParent, oParent)
   IF nId == NIL
      nId := TIMER_FIRST_ID
      DO WHILE AScan(::aTimers, {|o|o:id == nId}) != 0
         nId++
      ENDDO
   ENDIF
   ::id := nId
   ::value := IIf(hb_IsNumeric(value), value, 0)
   ::bAction := bAction
   /*
   IF ::value > 0
      hwg_Settimer(oParent:handle, ::id, ::value)
   ENDIF
   */

   ::Init()
   AAdd(::aTimers, SELF)
   ::oParent:AddObject(SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD Init() CLASS HTimer

   IF !::lInit .AND. !Empty(::oParent:handle)
      IF ::value > 0
         hwg_Settimer(::oParent:handle, ::id, ::value)
      ENDIF
      ::lInit := .T.
   ENDIF

RETURN  NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD End() CLASS HTimer

   LOCAL i

   IF (i := AScan(::aTimers, {|o|o:id == ::id})) > 0
      IF ::oParent != NIL
         hwg_Killtimer(::oParent:handle, ::id)
      ENDIF
      ADel(::aTimers, i)
      ASize(::aTimers, Len(::aTimers) - 1)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD OnAction() CLASS HTimer

   hwg_TimerProc(, ::id, ::interval)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

FUNCTION hwg_TimerProc(hWnd, idTimer, Time)

   LOCAL i := AScan(HTimer():aTimers, {|o|o:id == idTimer})

   // parameter not used
   HB_SYMBOL_UNUSED(hWnd)

   IF i != 0 .AND. HTimer():aTimers[i]:value > 0 .AND. hb_isBlock(HTimer():aTimers[i]:bAction)
      Eval(HTimer():aTimers[i]:bAction, HTimer():aTimers[i], time)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE CleanTimers

   LOCAL oTimer
   LOCAL i

   FOR i := 1 TO Len(HTimer():aTimers)
      oTimer := HTimer():aTimers[i]
      hwg_Killtimer(oTimer:oParent:handle, oTimer:id)
   NEXT

RETURN

//-------------------------------------------------------------------------------------------------------------------//

#pragma BEGINDUMP

#include <hbapi.h>

HB_FUNC_TRANSLATE(TIMERPROC, HWG_TIMERPROC)

#pragma ENDDUMP

//-------------------------------------------------------------------------------------------------------------------//
