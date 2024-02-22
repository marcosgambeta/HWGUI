/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStatic class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define  CONTROL_FIRST_ID   34000
#define TRANSPARENT 1

   // - HStatic

CLASS HStatic INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
      bColor, lTransp)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor, lTransp)
   METHOD Activate()
   METHOD SetValue(value) INLINE hwg_Setwindowtext(::handle, value)
   METHOD Init()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
      bColor, lTransp) CLASS HStatic

   // Enabling style for tooltips
   IF HB_ISCHAR(cTooltip)
      IF nStyle == NIL
         nStyle := SS_NOTIFY
      ELSE
         nStyle := Hwg_BitOr(nStyle, SS_NOTIFY)
      ENDIF
   ENDIF

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, ;
      bInit, bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption

   IF lTransp != NIL .AND. lTransp
      ::BackStyle := TRANSPARENT
      ::extStyle := Hwg_BitOr(::extStyle, WS_EX_TRANSPARENT)
   ENDIF

   ::Activate()

   RETURN Self

METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor, lTransp) CLASS HStatic

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor)

   ::title := cCaption
   ::style := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0

   // Enabling style for tooltips
   IF HB_ISCHAR(cTooltip)
      ::style := SS_NOTIFY
   ENDIF

   IF lTransp != NIL .AND. lTransp
      ::extStyle := Hwg_BitOr(::extStyle, WS_EX_TRANSPARENT)
   ENDIF

   RETURN Self

METHOD Activate() CLASS HStatic

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ;
         ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
         ::extStyle)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HStatic

   IF !::lInit
      ::Super:init()
      IF ::title != NIL
         hwg_Setwindowtext(::handle, ::title)
      ENDIF
   ENDIF

   RETURN  NIL
