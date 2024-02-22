/*
 * $Id: hcontrol.prg 2015 2013-03-13 10:41:37Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HControl class
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

   //- HControl

CLASS HControl INHERIT HCustomWindow

   DATA   id
   DATA   tooltip
   DATA   lInit           INIT .F.
   DATA   lnoValid        INIT .F.
   DATA   lnoWhen         INIT .F.
   DATA   nGetSkip        INIT 0
   DATA   Anchor          INIT 0
   DATA   BackStyle       INIT OPAQUE
   DATA   lNoThemes       INIT .F.
   DATA   DisablebColor
   DATA   DisableBrush
   DATA   xControlSource
   DATA   xName           HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE ::AddName(cName)

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      oFont, bInit, bSize, bPaint, cTooltip, tcolor, bColor)
   METHOD Init()
   METHOD AddName(cName) HIDDEN
   METHOD NewId()
   METHOD Show(nShow) INLINE ::Super:Show(nShow), iif(::oParent:lGetSkipLostFocus, ;
      hwg_Postmessage(hwg_Getactivewindow(), WM_NEXTDLGCTL, iif(::oParent:FindControl(, hwg_Getfocus()) != NIL, 0, ::handle), 1), .T.)
   METHOD Hide() INLINE (::oParent:lGetSkipLostFocus := .F., ::Super:Hide())
   METHOD Disable() INLINE (iif(hwg_Selffocus(::Handle), hwg_Sendmessage(hwg_Getactivewindow(), WM_NEXTDLGCTL, 0, 0),), hwg_Enablewindow(::handle, .F.))
   METHOD Enable()
   METHOD IsEnabled() INLINE hwg_Iswindowenabled(::Handle)
   METHOD Enabled(lEnabled) SETGET
   METHOD SetFont(oFont)
   METHOD Setfocus(lValid)
   METHOD GetText() INLINE hwg_Getwindowtext(::handle)
   METHOD SetText(c) INLINE hwg_Setwindowtext(::Handle, c), ::title := c, ::Refresh()
   METHOD Refresh()     VIRTUAL
   METHOD onAnchor(x, y, w, h)
   METHOD SetToolTip(ctooltip)
   METHOD ControlSource(cControlSource) SETGET
   METHOD DisableBackColor(DisableBColor) SETGET
   METHOD END()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, ;
      bInit, bSize, bPaint, cTooltip, tcolor, bColor) CLASS HControl

   ::oParent := iif(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := iif(nId == NIL, ::NewId(), nId)
   ::style   := Hwg_BitOr(iif(nStyle == NIL, 0, nStyle), ;
      WS_VISIBLE + WS_CHILD)
   ::nLeft   := iif(nLeft = NIL, 0, nLeft)
   ::nTop    := iif(nTop = NIL, 0, nTop)
   ::nWidth  := iif(nWidth = NIL, 0, nWidth)
   ::nHeight := iif(nHeight = NIL, 0, nHeight)
   ::oFont   := oFont
   ::bInit   := bInit
   IF HB_ISNUMERIC(bSize)
      ::Anchor := bSize
   ELSE
      ::bSize   := bSize
   ENDIF
   ::bPaint  := bPaint
   ::tooltip := cTooltip
   ::Setcolor(tcolor, bColor)
   ::oParent:AddControl(Self)

   RETURN Self

METHOD NewId() CLASS HControl
   LOCAL oParent := ::oParent, i := 0, nId

   DO WHILE oParent != NIL
      nId := CONTROL_FIRST_ID + 1000 * i + Len(::oParent:aControls)
      oParent := oParent:oParent
      i++
   ENDDO
   IF AScan(::oParent:aControls, {|o|o:id == nId}) != 0
      nId --
      DO WHILE nId >= CONTROL_FIRST_ID .AND. ;
            AScan(::oParent:aControls, {|o|o:id == nId}) != 0
         nId --
      ENDDO
   ENDIF

   RETURN nId

METHOD AddName(cName) CLASS HControl
   LOCAL nPos

   IF !Empty(cName) .AND. HB_ISCHAR(cName) .AND. ::oParent != Nil .AND. !"[" $ cName
      IF (nPos := RAt(":", cName)) > 0 .OR. (nPos := RAt(">", cName)) > 0
         cName := SubStr(cName, nPos + 1)
      ENDIF
      ::xName := cName
      __objAddData(::oParent, cName)
      ::oParent: &(cName) := Self
   ENDIF

   RETURN NIL

METHOD INIT() CLASS HControl
   LOCAL oForm := hwg_GetParentForm(Self)

   IF !::lInit
      ::oparent:lSuspendMsgsHandling := .T.
      IF Len(::aControls) = 0 .AND. ::winclass != "SysTabControl32" .AND. ValType(oForm) != "N"
         hwg_Addtooltip(oForm:handle, ::handle, ::tooltip)
      ENDIF
      ::oparent:lSuspendMsgsHandling := .F.
      IF ::oFont != NIL .AND. ValType(::oFont) != "N" .AND. ::oParent != NIL
         hwg_Setctrlfont(::oParent:handle, ::id, ::oFont:handle)
      ELSEIF oForm != NIL .AND. ValType(oForm) != "N" .AND. oForm:oFont != NIL
         hwg_Setctrlfont(::oParent:handle, ::id, oForm:oFont:handle)
      ELSEIF ::oParent != NIL .AND. ::oParent:oFont != NIL
         hwg_Setctrlfont(::handle, ::id, ::oParent:oFont:handle)
      ENDIF
      IF oForm != NIL .AND. oForm:Type != WND_DLG_RESOURCE .AND. (::nLeft + ::nTop + ::nWidth + ::nHeight  != 0)
         // fix init position in FORM reduce  flickering
         hwg_Setwindowpos(::Handle, NIL, ::nLeft, ::nTop, ::nWidth, ::nHeight, SWP_NOACTIVATE + SWP_NOSIZE + SWP_NOZORDER + SWP_NOOWNERZORDER + SWP_NOSENDCHANGING) //+ SWP_DRAWFRAME)
      ENDIF
      IF ISBLOCK(::bInit)
         ::oparent:lSuspendMsgsHandling := .T.
         Eval(::bInit, Self)
         ::oparent:lSuspendMsgsHandling := .F.
      ENDIF
      IF ::lnoThemes
         HWG_SETWINDOWTHEME(::handle, 0)
      ENDIF
      ::lInit := .T.
   ENDIF

   RETURN NIL

METHOD Setfocus(lValid) CLASS HControl
   LOCAL lSuspend := ::oParent:lSuspendMsgsHandling

   IF !hwg_Iswindowenabled(::Handle)
      ::oParent:lSuspendMsgsHandling  := .T.
      hwg_Sendmessage(hwg_Getactivewindow(), WM_NEXTDLGCTL, 0, 0)
      ::oParent:lSuspendMsgsHandling  := lSuspend
   ELSE
      ::oParent:lSuspendMsgsHandling  := !Empty(lValid)
      IF hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE
         hwg_Setfocus(::handle)
      ELSE
         hwg_Sendmessage(hwg_Getactivewindow(), WM_NEXTDLGCTL, ::handle, 1)
      ENDIF
      ::oParent:lSuspendMsgsHandling  := lSuspend
   ENDIF
   IF hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE
      hwg_GetParentForm(Self):nFocus := ::Handle
   ENDIF

   RETURN NIL

METHOD Enable() CLASS HControl
   LOCAL lEnable := hwg_Iswindowenabled(::Handle), nPos, nNext

   hwg_Enablewindow(::handle, .T.)
   IF ::oParent:lGetSkipLostFocus .AND. !lEnable .AND. Hwg_BitaND(HWG_GETWINDOWSTYLE(::Handle), WS_TABSTOP) > 0
      nNext := Ascan(::oParent:aControls, {|o|hwg_Ptrtoulong(o:Handle) = hwg_Ptrtoulong(hwg_Getfocus())})
      nPos  := Ascan(::oParent:acontrols, {|o|hwg_Ptrtoulong(o:Handle) = hwg_Ptrtoulong(::handle)})
      IF nPos < nNext
         hwg_Sendmessage(hwg_Getactivewindow(), WM_NEXTDLGCTL, ::handle, 1)
      ENDIF
   ENDIF

   RETURN NIL

METHOD DisableBackColor(DisableBColor)

   IF DisableBColor != NIL
      ::DisableBColor := DisableBColor
      IF ::Disablebrush != NIL
         ::Disablebrush:Release()
      ENDIF
      ::Disablebrush := HBrush():Add(::DisableBColor)
      IF !::IsEnabled() .AND. hwg_Iswindowvisible(::Handle)
         hwg_Invalidaterect(::Handle, 0)
      ENDIF
   ENDIF

   RETURN ::DisableBColor

METHOD SetFont(oFont) CLASS HControl

   IF oFont != NIL
      IF HB_ISOBJECT(oFont)
         ::oFont := oFont:SetFontStyle()
         hwg_Setwindowfont(::Handle, ::oFont:Handle, .T.)
      ENDIF
   ELSEIF ::oParent:oFont != NIL
      hwg_Setwindowfont(::handle, ::oParent:oFont:handle, .T.)
   ENDIF

   RETURN ::oFont

METHOD SetToolTip(cToolTip) CLASS HControl

   IF HB_ISCHAR(cToolTip) .AND. cToolTip != ::ToolTip
      hwg_Settooltiptitle(hwg_GetparentForm(Self):handle, ::handle, ctooltip)
      ::Tooltip := cToolTip
   ENDIF

   RETURN ::tooltip

METHOD Enabled(lEnabled) CLASS HControl

   IF lEnabled != NIL
      IF lEnabled
         ::enable()
      ELSE
         ::disable()
      ENDIF
   ENDIF

   RETURN ::isEnabled()

METHOD ControlSource(cControlSource) CLASS HControl
   LOCAL temp

   IF cControlSource != NIL .AND. !Empty(cControlSource) .AND. __objHasData(Self, "BSETGETFIELD")
      ::xControlSource := cControlSource
      temp := SubStr(cControlSource, At("->", cControlSource) + 2)
      ::bSetGetField := iif("->" $ cControlSource, FieldWBlock(temp, Select(SubStr(cControlSource, 1, At("->", cControlSource) - 1))), FieldBlock(cControlSource))
   ENDIF

   RETURN ::xControlSource

METHOD END() CLASS HControl

   ::Super:END()
   IF ::tooltip != NIL
      hwg_Deltooltip(::oParent:handle, ::handle)
      ::tooltip := NIL
   ENDIF

   RETURN NIL

METHOD onAnchor(x, y, w, h) CLASS HControl
   LOCAL nAnchor, nXincRelative, nYincRelative, nXincAbsolute, nYincAbsolute
   LOCAL x1, y1, w1, h1, x9, y9, w9, h9
   LOCAL nCxv, nCyh

   nAnchor := ::anchor
   x9 := x1 := ::nLeft
   y9 := y1 := ::nTop
   w9 := w1 := ::nWidth
   h9 := h1 := ::nHeight
   // *- calculo relativo
   nXincRelative := Iif(x > 0, w / x, 1)
   nYincRelative := Iif(y > 0, h / y, 1)
   // *- calculo ABSOLUTE
   nXincAbsolute := (w - x)
   nYincAbsolute := (h - y)
   IF nAnchor >= ANCHOR_VERTFIX
      // *- vertical fixed center
      nAnchor -= ANCHOR_VERTFIX
      y1 := y9 + Round((h - y) * ((y9 + h9 / 2) / y), 2)
   ENDIF
   IF nAnchor >= ANCHOR_HORFIX
      // *- horizontal fixed center
      nAnchor -= ANCHOR_HORFIX
      x1 := x9 + Round((w - x) * ((x9 + w9 / 2) / x), 2)
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTREL
      // relative - RIGHT RELATIVE
      nAnchor -= ANCHOR_RIGHTREL
      x1 := w - Round((x - x9 - w9) * nXincRelative, 2) - w9
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMREL
      // relative - BOTTOM RELATIVE
      nAnchor -= ANCHOR_BOTTOMREL
      y1 := h - Round((y - y9 - h9) * nYincRelative, 2) - h9
   ENDIF
   IF nAnchor >= ANCHOR_LEFTREL
      // relative - LEFT RELATIVE
      nAnchor -= ANCHOR_LEFTREL
      IF x1 != x9
         w1 := x1 - (Round(x9 * nXincRelative, 2)) + w9
      ENDIF
      x1 := Round(x9 * nXincRelative, 2)
   ENDIF
   IF nAnchor >= ANCHOR_TOPREL
      // relative  - TOP RELATIVE
      nAnchor -= ANCHOR_TOPREL
      IF y1 != y9
         h1 := y1 - (Round(y9 * nYincRelative, 2)) + h9
      ENDIF
      y1 := Round(y9 * nYincRelative, 2)
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTABS
      // Absolute - RIGHT ABSOLUTE
      nAnchor -= ANCHOR_RIGHTABS
      IF HWG_BITAND(::Anchor, ANCHOR_LEFTREL) != 0
         w1 := Int(nxIncAbsolute) - (x1 - x9) + w9
      ELSE
         IF x1 != x9
            w1 := x1 - (x9 + Int(nXincAbsolute)) + w9
         ENDIF
         x1 := x9 +  Int(nXincAbsolute)
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMABS
      // Absolute - BOTTOM ABSOLUTE
      nAnchor -= ANCHOR_BOTTOMABS
      IF HWG_BITAND(::Anchor, ANCHOR_TOPREL) != 0
         h1 := Int(nyIncAbsolute) - (y1 - y9) + h9
      ELSE
         IF y1 != y9
            h1 := y1 - (y9 + Int(nYincAbsolute)) + h9
         ENDIF
         y1 := y9 +  Int(nYincAbsolute)
      ENDIF
   ENDIF
   IF nAnchor >= ANCHOR_LEFTABS
      // Absolute - LEFT ABSOLUTE
      nAnchor -= ANCHOR_LEFTABS
      IF x1 != x9
         w1 := x1 - x9 + w9
      ENDIF
      x1 := x9
   ENDIF
   IF nAnchor >= ANCHOR_TOPABS
      // Absolute - TOP ABSOLUTE
      IF y1 != y9
         h1 := y1 - y9 + h9
      ENDIF
      y1 := y9
   ENDIF
   // REDRAW AND INVALIDATE SCREEN
   IF (x1 != X9 .OR. y1 != y9 .OR. w1 != w9 .OR. h1 != h9)
      IF hwg_Iswindowvisible(::handle)
         nCxv := iif(HWG_BITAND(::style, WS_VSCROLL) != 0, hwg_Getsystemmetrics(SM_CXVSCROLL) + 1, 3)
         nCyh := iif(HWG_BITAND(::style, WS_HSCROLL) != 0, hwg_Getsystemmetrics(SM_CYHSCROLL) + 1, 3)
         IF (x1 != x9 .OR. y1 != y9) .AND. x9 < ::oParent:nWidth
            hwg_Invalidaterect(::oParent:handle, 1, Max(x9 - 1, 0), Max(y9 - 1, 0), ;
               x9 + w9 + nCxv, y9 + h9 + nCyh)
         ELSE
            IF w1 < w9
               hwg_Invalidaterect(::oParent:handle, 1, x1 + w1 - nCxv - 1, Max(y1 - 2, 0), ;
                  x1 + w9 + 2, y9 + h9 + nCxv + 1)
            ENDIF
            IF h1 < h9
               hwg_Invalidaterect(::oParent:handle, 1, Max(x1 - 5, 0), y1 + h1 - nCyh - 1, ;
                  x1 + w9 + 2, y1 + h9 + nCYh)
            ENDIF
         ENDIF
         IF ((x1 != x9 .OR. y1 != y9) .AND. (ISBLOCK(::bPaint) .OR. ;
               x9 + w9 > ::oParent:nWidth)) .OR. (::backstyle = TRANSPARENT .AND. ;
               (::Title != NIL .AND. !Empty(::Title))) .OR. __ObjHasMsg(Self, "oImage")
            IF __ObjHasMsg(Self, "oImage") .OR. ::backstyle = TRANSPARENT //.OR. w9 != w1
               hwg_Invalidaterect(::oParent:handle, 1, Max(x1 - 1, 0), Max(y1 - 1, 0), x1 + w1 + 1, y1 + h1 + 1)
            ELSE
               hwg_Redrawwindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT)
            ENDIF
         ELSE
            IF Len(::aControls) = 0 .AND. ::Title != NIL
               hwg_Invalidaterect(::handle, 0)
            ENDIF
            IF w1 > w9
               hwg_Invalidaterect(::oParent:handle, 1, Max(x1 + w9 - nCxv - 1, 0), ;
                  Max(y1, 0), x1 + w1 + nCxv, y1 + h1 + 2)
            ENDIF
            IF h1 > h9
               hwg_Invalidaterect(::oParent:handle, 1, Max(x1, 0), ;
                  Max(y1 + h9 - nCyh - 1, 1), x1 + w1 + 2, y1 + h1 + nCyh)
            ENDIF
         ENDIF
         // redefine new position e new size
         ::Move(x1, y1, w1, h1, HWG_BITAND(::Style, WS_CLIPSIBLINGS + WS_CLIPCHILDREN) = 0)
      ELSE
         ::Move(x1, y1, w1, h1, 0)
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.

INIT PROCEDURE starttheme()
hwg_Initthemelib()

EXIT PROCEDURE endtheme()
hwg_Endthemelib()
