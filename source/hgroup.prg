/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HGroup classes
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

//#define  CONTROL_FIRST_ID   34000
//#define TRANSPARENT 1

// CLASS HGroup

CLASS HGroup INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor)
   METHOD Activate()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor) CLASS HGroup

   nStyle := Hwg_BitOr(iif(nStyle == NIL, 0, nStyle), BS_GROUPBOX)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, , tcolor, bColor)

   ::title := cCaption
   ::Activate()

RETURN SELF

METHOD Activate() CLASS HGroup

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF

RETURN NIL
