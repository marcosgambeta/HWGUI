/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HPage class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

CLASS HPage INHERIT HObject

   DATA xCaption     HIDDEN
   ACCESS Caption INLINE ::xCaption
   ASSIGN Caption(xC) INLINE ::xCaption := xC, ::SetTabText(::xCaption)
   DATA lEnabled  INIT .T. // HIDDEN
   DATA PageOrder INIT 1
   DATA oParent
   DATA tcolor, bcolor
   DATA brush
   DATA oFont   // not implemented
   DATA aItemPos       INIT {}
   DATA Tooltip

   METHOD New(cCaption, nPage, lEnabled, tcolor, bcolor, cTooltip)
   METHOD Enable() INLINE ::Enabled(.T.)
   METHOD Disable() INLINE ::Enabled(.F.)
   METHOD GetTabText() INLINE hwg_Gettabname(::oParent:Handle, ::PageOrder - 1)
   METHOD SetTabText(cText)
   METHOD Refresh() INLINE ::oParent:ShowPage(::PageOrder)
   METHOD Enabled(lEnabled) SETGET
   METHOD Setcolor(tcolor, bcolor)

ENDCLASS

   //----------------------------------------------------//

METHOD New(cCaption, nPage, lEnabled, tcolor, bcolor, cTooltip) CLASS HPage

   cCaption := iif(cCaption == NIL, "New Page", cCaption)
   ::lEnabled := iif(lEnabled != NIL, lEnabled, .T.)
   ::Pageorder := nPage
   ::Tooltip := cTooltip
   ::Setcolor(tColor, bColor)

   RETURN Self

METHOD Setcolor(tcolor, bColor) CLASS HPage

   IF tcolor != NIL
      ::tcolor := tcolor
   ENDIF
   IF bColor != NIL
      ::bColor := bColor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add(bColor)
   ENDIF
   IF ::oParent = NIL .OR. (bColor = NIL .AND. tcolor = NIL)
      RETURN NIL
   ENDIF
   hwg_Invalidaterect(::oParent:Handle, 1)
   ::oParent:SetPaintSizePos(iif(bColor = NIL, 1, -1))

   RETURN NIL

METHOD SetTabText(cText) CLASS HPage

   IF Len(::aItemPos) = 0
      RETURN NIL
   ENDIF

   hwg_Settabname(::oParent:Handle, ::PageOrder - 1, cText)
   ::xCaption := cText
   hwg_Invalidaterect(::oParent:handle, 0, ::aItemPos[1], ::aItemPos[2], ::aItemPos[1] + ::aItemPos[3], ::aItemPos[2] + ::aItemPos[4])
   hwg_Invalidaterect(::oParent:Handle, 1)

   RETURN NIL

METHOD Enabled(lEnabled) CLASS HPage
   LOCAL nActive

   IF lEnabled != NIL .AND. ::lEnabled != lEnabled
      ::lEnabled := lEnabled
      IF lEnabled .AND. (::PageOrder != ::oParent:nActive .OR. !hwg_Iswindowenabled(::oParent:Handle))
         IF !hwg_Iswindowenabled(::oParent:Handle)
            ::oParent:Enable()
            ::oParent:setTab(::PageOrder)
         ENDIF
      ENDIF
      ::oParent:ShowDisablePage(::PageOrder)
      IF ::PageOrder = ::oParent:nActive .AND. !::lenabled
         nActive := SetTabFocus(::oParent, ::oParent:nActive, VK_RIGHT)
         IF nActive > 0 .AND. ::oParent:Pages[nActive]:lEnabled
            ::oParent:setTab(nActive)
         ENDIF
      ENDIF
      IF Ascan(::oParent:Pages, {|p|p:lEnabled}) = 0
         ::oParent:Disable()
         hwg_Sendmessage(::oParent:handle, TCM_SETCURSEL, -1, 0)
      ENDIF
   ENDIF

   RETURN ::lEnabled

STATIC FUNCTION SetTabFocus(oCtrl, nPage, nKeyDown)
   LOCAL i, nSkip, nStart, nEnd, nPageAcel

   IF nKeyDown = VK_LEFT .OR. nKeyDown = VK_RIGHT  // 37,39
      nEnd := iif(nKeyDown = VK_LEFT, 1, Len(oCtrl:aPages))
      nSkip := iif(nKeyDown = VK_LEFT, -1, 1)
      nStart := nPage + nSkip
      FOR i = nStart TO nEnd STEP nSkip
         IF oCtrl:pages[i]:enabled
            IF (nSkip > 0 .AND. i > nStart) .OR. (nSkip < 0 .AND. i < nStart)
               hwg_Sendmessage(oCtrl:handle, TCM_SETCURFOCUS, i - nSkip - 1, 0) // BOTOES
            ENDIF
            RETURN i
         ELSEIF i = nEnd
            IF oCtrl:pages[i - nSkip]:enabled
               hwg_Sendmessage(oCtrl:handle, TCM_SETCURFOCUS, i - (nSkip * 2) - 1, 0) // BOTOES
               RETURN (i - nSkip)
            ENDIF
            RETURN nPage
         ENDIF
      NEXT
   ELSE
      nPageAcel := hwg_FindTabAccelerator(oCtrl, nKeyDown)
      IF nPageAcel = 0
         hwg_Msgbeep()
      ENDIF
   ENDIF

   RETURN nPage

#if 0
FUNCTION hwg_FindTabAccelerator(oPage, nKey) // using hwg_FindTabAccelerator from htab.prg

   LOCAL i, pos, cKey

   cKey := Upper(Chr(nKey))
   FOR i = 1 TO Len(oPage:aPages)
      IF (pos := At("&", oPage:Pages[i]:caption)) > 0 .AND. cKey  == Upper(SubStr(oPage:Pages[i]:caption, ++pos, 1))
         IF oPage:pages[i]:Enabled
            hwg_Sendmessage(oPage:handle, TCM_SETCURFOCUS, i - 1, 0)
         ENDIF
         RETURN  i
      ENDIF
   NEXT

   RETURN 0
#endif
