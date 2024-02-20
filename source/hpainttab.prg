/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HPaintTab class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1

/* ------------------------------------------------------------------
 new class to PAINT Pages
------------------------------------------------------------------ */

CLASS HPaintTab INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA hDC

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, tColor, bColor)
   METHOD Activate()
   METHOD Paint(lpDis)
   METHOD showTextTabs(oPage, aItemPos)
   METHOD Refresh() VIRTUAL

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, tcolor, bColor) CLASS HPaintTab

   ::bPaint   := {|o, p|o:paint(p)}
   ::Super:New(oWndParent, nId, SS_OWNERDRAW + WS_DISABLED + WS_CLIPCHILDREN, nLeft, nTop, nWidth, nHeight, , ;
      , , ::bPaint, , tcolor, bColor)
   ::anchor := 15
   ::brush := NIL
   ::Name := "PaintTab"

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HPaintTab

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ENDIF

   RETURN NIL

METHOD Paint(lpdis) CLASS HPaintTab
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1 := drawInfo[4], y1 := drawInfo[5]
   LOCAL x2 := drawInfo[6], y2 := drawInfo[7]
   LOCAL i, client_rect
   LOCAL nPage := hwg_Sendmessage(::oParent:handle, TCM_GETCURFOCUS, 0, 0) + 1
   LOCAL oPage := iif(nPage > 0, ::oParent:Pages[nPage], ::oParent:Pages[1])

   ::disablebrush := oPage:brush
   IF oPage:brush != NIL
      IF ::oParent:nPaintHeight < ::oParent:TabHeightSize //40
         ::nHeight := 1
         ::move(, , , ::nHeight)
      ELSEIF oPage:brush != NIL
         hwg_Fillrect(hDC, x1 + 1, y1 + 2, x2 - 1, y2 - 0, oPage:brush:Handle) //obrush)
         ::oParent:RedrawControls()
      ENDIF
   ENDIF

   ::hDC := hwg_Getdc(::oParent:handle)
   FOR i = 1 TO Len(::oParent:Pages)
      oPage := ::oParent:Pages[i]
      client_rect := hwg_Tabitempos(::oParent:Handle, i - 1)
      oPage:aItemPos := client_rect
      IF oPage:brush != NIL
         IF nPage = oPage:PageOrder
            hwg_Fillrect(::hDC, client_rect[1], client_rect[2] + 1, client_rect[3], client_rect[4] + 2, oPage:brush:handle)
            IF hwg_Getfocus() = oPage:oParent:handle
               hwg_Inflaterect(@client_rect, -2, -2)
               hwg_Drawfocusrect(::hDC, client_rect)
            ENDIF
         ELSE
            hwg_Fillrect(::hDC, client_rect[1] + iif(i = nPage + 1, 2, 1), ;
               client_rect[2] + 1, ;
               client_rect[3] - iif(i = nPage - 1, 3, 2) - iif(i = Len(::oParent:Pages), 1, 0), ;
               client_rect[4] - 1, oPage:brush:Handle)
         ENDIF
      ENDIF
      IF oPage:brush != NIL .OR. oPage:tColor != NIL .OR. !oPage:lenabled
         ::showTextTabs(oPage, client_rect)
      ENDIF
   NEXT

   RETURN 0

METHOD showTextTabs(oPage, aItemPos) CLASS HPaintTab
   LOCAL nStyle, BmpSize := 0, size := 0, aTxtSize, aItemRect
   LOCAL nActive := oPage:oParent:GetActivePage(), hTheme

   AEval(oPage:oParent:Pages, {|p|size += p:aItemPos[3] - p:aItemPos[1]})
   nStyle := SS_CENTER + DT_VCENTER + DT_SINGLELINE + DT_END_ELLIPSIS
   ::hDC := iif(::hDC = NIL, hwg_Getdc(::oParent:handle), ::hDC)
   IF (hwg_Isthemedload())
      hTheme := NIL
      IF ::WindowsManifest
         hTheme := hwg_openthemedata(::oParent:handle, "TAB")
      ENDIF
      hTheme := iif(Empty(hTheme), NIL, hTheme)
   ENDIF
   hwg_Setbkmode(::hDC, TRANSPARENT)
   IF oPage:oParent:oFont != NIL
      hwg_Selectobject(::hDC, oPage:oParent:oFont:handle)
   ENDIF
   IF oPage:lEnabled
      hwg_Settextcolor(::hDC, iif(Empty(oPage:tColor), hwg_Getsyscolor(COLOR_WINDOWTEXT), oPage:tColor))
   ELSE
      hwg_Settextcolor(::hDC, hwg_Getsyscolor(COLOR_BTNHIGHLIGHT))
   ENDIF
   aTxtSize := hwg_TxtRect(oPage:caption, oPage:oParent)
   IF oPage:oParent:himl != NIL
      BmpSize := ((aItemPos[3] - aItemPos[1]) - (oPage:oParent:aBmpSize[1] + aTxtSize[1])) / 2
      BmpSize += oPage:oParent:aBmpSize[1]
      BmpSize := Max(BmpSize, oPage:oParent:aBmpSize[1])
   ENDIF
   aItemPos[3] := iif(size > oPage:oParent:nWidth .AND. aItemPos[1] + BmpSize + aTxtSize[1] > oPage:oParent:nWidth - 44, oPage:oParent:nWidth - 44, aItemPos[3])
   aItemRect := { aItemPos[1] + iif(oPage:PageOrder = nActive + 1, 1, 0), aItemPos[2], aItemPos[3] - iif(oPage:PageOrder = Len(oPage:oParent:Pages), 2, iif(oPage:PageOrder = nActive - 1, 1, 0)), aItemPos[4] - 1   }
   IF Hwg_BitAnd(oPage:oParent:Style, TCS_BOTTOM) = 0
      IF hTheme != NIL .AND. oPage:brush = NIL
         hwg_drawthemebackground(hTheme, ::hDC, BP_PUSHBUTTON, 0, aItemRect, NIL)
      ELSE
         hwg_Fillrect(::hDC, aItemPos[1] + BmpSize + 3, aItemPos[2] + 4, aItemPos[3] - 3, aItemPos[4] - 5, ;
            iif(oPage:brush != NIL, oPage:brush:Handle, hwg_Getstockobject(NULL_BRUSH)))
      ENDIF
      IF nActive = oPage:PageOrder                       // 4
         hwg_Drawtext(::hDC, oPage:caption, aItemPos[1] + BmpSize - 1, aItemPos[2] - 1, aItemPos[3], aItemPos[4] - 1, nstyle)
      ELSE
         IF oPage:lEnabled = .F.
            hwg_Drawtext(::hDC, oPage:caption, aItemPos[1] + BmpSize - 1, aItemPos[2] + 1, aItemPos[3] + 1, aItemPos[4] + 1, nstyle)
            hwg_Settextcolor(::hDC, hwg_Getsyscolor(COLOR_GRAYTEXT))
         ENDIF
         hwg_Drawtext(::hDC, oPage:caption, aItemPos[1] + BmpSize - 1, aItemPos[2] + 1, aItemPos[3] + 1, aItemPos[4] + 1, nstyle)
      ENDIF
   ELSE
      IF hTheme != NIL .AND. oPage:brush = NIL
         hwg_drawthemebackground(hTheme, ::hDC, BP_PUSHBUTTON, 0, aItemRect, NIL)
      ELSE
         hwg_Fillrect(::hDC, aItemPos[1] + 3, aItemPos[2] + 3, aItemPos[3] - 4, aItemPos[4] - 5, iif(oPage:brush != NIL, oPage:brush:Handle, hwg_Getstockobject(NULL_BRUSH))) // oPage:oParent:brush:Handle))
      ENDIF
      IF nActive = oPage:PageOrder                       // 4
         hwg_Drawtext(::hDC, oPage:caption, aItemPos[1], aItemPos[2] + 2, aItemPos[3], aItemPos[4] + 2, nstyle)
      ELSE
         IF oPage:lEnabled = .F.
            hwg_Drawtext(::hDC, oPage:caption, aItemPos[1] + 1, aItemPos[2] + 1, aItemPos[3] + 1, aItemPos[4] + 1, nstyle)
            hwg_Settextcolor(::hDC, hwg_Getsyscolor(COLOR_GRAYTEXT))
         ENDIF
         hwg_Drawtext(::hDC, oPage:caption, aItemPos[1], aItemPos[2], aItemPos[3], aItemPos[4], nstyle)
      ENDIF
   ENDIF
   IF oPage:lEnabled .AND. oPage:brush = NIL
      hwg_Invalidaterect(::oParent:handle, 0, aItemPos[1], aItemPos[2], aItemPos[1] + aItemPos[3], aItemPos[2] + aItemPos[4])
   ENDIF

   RETURN NIL
