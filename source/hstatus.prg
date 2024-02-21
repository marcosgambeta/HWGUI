/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStatus classes
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

   // - HStatus

CLASS HStatus INHERIT HControl

   CLASS VAR winclass INIT "msctls_statusbar32"
   DATA aParts
   DATA nStatusHeight INIT 0
   DATA bDblClick
   DATA bRClick

   METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight)
   METHOD Activate()
   METHOD Init()
   METHOD Notify(lParam)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts)
   METHOD SetTextPanel(nPart, cText, lRedraw)
   METHOD GetTextPanel(nPart)
   METHOD SetIconPanel(nPart, cIcon, nWidth, nHeight)
   METHOD StatusHeight(nHeight)
   METHOD Resize(xIncrSize)
   METHOD onAnchor(x, y, w, h)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight) CLASS HStatus

   bSize  := iif(bSize != NIL, bSize, {|o, x, y|o:Move(0, y - ::nStatusHeight, x, ::nStatusHeight)})
   nStyle := Hwg_BitOr(iif(nStyle == NIL, 0, nStyle), ;
      WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS)
   ::Super:New(oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, ;
      bSize, bPaint)
   ::nStatusHeight := iif(nHeight = NIL, ::nStatusHeight, nHeight)
   ::aParts    := aParts
   ::bDblClick := bDblClick
   ::bRClick   := bRClick

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HStatus

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatuswindow(::oParent:handle, ::id)
      ::StatusHeight(::nStatusHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HStatus

   IF !::lInit
      IF !Empty(::aParts)
         hwg_InitStatus(::oParent:handle, ::handle, Len(::aParts), ::aParts)
      ENDIF
      ::Super:Init()
   ENDIF

   RETURN  NIL

METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts) CLASS hStatus

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::style := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::aParts := aParts

   RETURN Self

METHOD Notify(lParam) CLASS HStatus

   LOCAL nCode := hwg_Getnotifycode(lParam)
   LOCAL nParts := hwg_Getnotifysbparts(lParam) - 1

#define NM_DBLCLK    (NM_FIRST-3)
#define NM_RCLICK    (NM_FIRST-5)    // uses NMCLICK struct
#define NM_RDBLCLK   (NM_FIRST-6)

   DO CASE
   CASE nCode == NM_CLICK
   CASE nCode == NM_DBLCLK
      IF ::bdblClick != NIL
         Eval(::bdblClick, Self, nParts)
      ENDIF
   CASE nCode == NM_RCLICK
      IF ::bRClick != NIL
         Eval(::bRClick, Self, nParts)
      ENDIF
   ENDCASE

   RETURN NIL

METHOD StatusHeight(nHeight) CLASS HStatus
   LOCAL aCoors

   IF nHeight != NIL
      aCoors := hwg_Getwindowrect(::handle)
      IF nHeight != 0
         IF ::lInit .AND. __ObjHasMsg(::oParent, "AOFFSET")
            ::oParent:aOffset[4] -= (aCoors[4] - aCoors[2])
         ENDIF
         hwg_Sendmessage(::handle, ;           // (HWND) handle to destination control
            SB_SETMINHEIGHT, nHeight, 0)      // (UINT) message ID  // = (WPARAM)(int) minHeight;
         hwg_Sendmessage(::handle, WM_SIZE, 0, 0)
         aCoors := hwg_Getwindowrect(::handle)
      ENDIF
      ::nStatusHeight := (aCoors[4] - aCoors[2]) - 1
      IF __ObjHasMsg(::oParent, "AOFFSET")
         ::oParent:aOffset[4] += (aCoors[4] - aCoors[2])
      ENDIF
   ENDIF

   RETURN ::nStatusHeight

METHOD GetTextPanel(nPart) CLASS HStatus
   LOCAL ntxtLen, cText := ""

   ntxtLen := hwg_Sendmessage(::handle, SB_GETTEXTLENGTH, nPart - 1, 0)
   cText := Replicate(Chr(0), ntxtLen)
   hwg_Sendmessage(::handle, SB_GETTEXT, nPart - 1, @cText)

   RETURN cText

METHOD SetTextPanel(nPart, cText, lRedraw) CLASS HStatus

   //hwg_Writestatuswindow(::handle, nPart-1, cText)
   hwg_Sendmessage(::handle, SB_SETTEXT, nPart - 1, cText)
   IF lRedraw != NIL .AND. lRedraw
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF

   RETURN NIL

METHOD SetIconPanel(nPart, cIcon, nWidth, nHeight) CLASS HStatus
   LOCAL oIcon

   DEFAULT nWidth := 16
   DEFAULT nHeight := 16
   DEFAULT cIcon := ""

   IF HB_IsNumeric(cIcon) .OR. At(".", cIcon) = 0
      //oIcon := HIcon():addResource(cIcon, nWidth, nHeight)
      oIcon := HIcon():addResource(cIcon, nWidth, nHeight, LR_LOADMAP3DCOLORS + ;
         iif(Empty(HWG_GETWINDOWTHEME(::handle)), LR_LOADTRANSPARENT, 0))
   ELSE
      oIcon := HIcon():addFile(cIcon, nWidth, nHeight)
   ENDIF
   IF !Empty(oIcon)
      hwg_Sendmessage(::handle, SB_SETICON, nPart - 1, oIcon:handle)
   ENDIF

   RETURN NIL

METHOD Resize(xIncrSize) CLASS HStatus
   LOCAL i

   IF !Empty(::aParts)
      FOR i := 1 TO Len(::aParts)
         ::aParts[i] := Round(::aParts[i] * xIncrSize, 0)
      NEXT
      hwg_InitStatus(::oParent:handle, ::handle, Len(::aParts), ::aParts)
   ENDIF

   RETURN NIL

METHOD onAnchor(x, y, w, h) CLASS HStatus

   IF ::Super:onAnchor(x, y, w, h)
      ::Resize(Iif(x > 0, w / x, 1))
   ENDIF

   RETURN .T.
