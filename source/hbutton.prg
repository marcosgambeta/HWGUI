/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HButton class
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

   // - HButton

CLASS HButton INHERIT HControl

   CLASS VAR winclass INIT "BUTTON"

   DATA bClick

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
              cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
              tcolor, bColor)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
                    tcolor, bColor, cCaption)
   METHOD Init()
ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
           cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
           tcolor, bColor) CLASS HButton

   nStyle := Hwg_BitOr(IIF(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON)

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, ;
              IIF(nWidth  == NIL, 90, nWidth), ;
              IIF(nHeight == NIL, 30, nHeight), ;
              oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
   ::bClick  := bClick
   ::title   := cCaption
   ::Activate()

   IF bClick != NIL
      IF ::oParent:className == "HSTATUS"
         ::oParent:oParent:AddEvent(0, ::id, bClick)
      ELSE
         ::oParent:AddEvent(0, ::id, bClick)
      ENDIF
   ENDIF

RETURN Self

METHOD Activate() CLASS HButton
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createbutton(::oParent:handle, ::id, ::style, ;
                                ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
                                ::title)
      ::Init()
   ENDIF
RETURN NIL

METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
                 cTooltip, tcolor, bColor, cCaption) CLASS HButton

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
              bSize, bPaint, cTooltip, tcolor, bColor)

   ::title   := cCaption

   IF bClick != NIL
      ::oParent:AddEvent(0, ::id, bClick)
   ENDIF
RETURN Self

METHOD Init() CLASS HButton

   ::super:Init()
   IF ::title != NIL
      hwg_Setwindowtext(::handle, ::title)
   ENDIF
RETURN  NIL
