/*
 * $Id: hownbtn.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HOwnButton class, which implements owner drawn buttons
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"
#define TRANSPARENT 1

CLASS HOwnButton INHERIT HControl

CLASS VAR cPath SHARED
   DATA winclass   INIT "OWNBTN"
   DATA lFlat
   DATA state
   DATA bClick
   DATA lPress  INIT .F.
   DATA lCheck  INIT .F.
   DATA xt, yt, widtht, heightt
   DATA oBitmap, xb, yb, widthb, heightb, lTransp, trColor
   DATA lEnabled INIT .T.
   DATA nOrder

   DATA m_bFirstTime INIT .T.
   DATA hTheme
   DATA Themed INIT .F.


   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight,   ;
              bInit, bSize, bPaint, bClick, lflat,             ;
              cText, color, oFont, xt, yt, widtht, heightt,       ;
              bmp, lResour, xb, yb, widthb, heightb, lTr, trColor, ;
              cTooltip, lEnabled, lCheck, bColor, bGfocus, bLfocus, themed)

   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Redefine(oWndParent, nId, bInit, bSize, bPaint, bClick, lflat, ;
                   cText, color, font, xt, yt, widtht, heightt,     ;
                   bmp, lResour, xb, yb, widthb, heightb, lTr,      ;
                   cTooltip, lEnabled, lCheck)
   METHOD Paint()
   METHOD DrawItems(hDC)
   METHOD MouseMove(wParam, lParam)
   METHOD MDown()
   METHOD MUp()
   METHOD Press() INLINE (::lPress := .T., ::MDown())
   METHOD Release()
   METHOD END()
   METHOD Enable()
   METHOD Disable()
   METHOD onClick()
   METHOD onGetFocus()
   METHOD onLostFocus()
   METHOD Refresh()
   METHOD SetText(cCaption) INLINE ::title := cCaption, ;
                hwg_Redrawwindow(::oParent:Handle, RDW_ERASE + RDW_INVALIDATE, ::nLeft, ::nTop, ::nWidth, ::nHeight)


ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight,   ;
           bInit, bSize, bPaint, bClick, lflat,             ;
           cText, color, oFont, xt, yt, widtht, heightt,       ;
           bmp, lResour, xb, yb, widthb, heightb, lTr, trColor, ;
           cTooltip, lEnabled, lCheck, bColor, bGfocus, bLfocus, themed) CLASS HOwnButton

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize, bPaint, cTooltip)

//   HB_SYMBOL_UNUSED(bGFocus)
//   HB_SYMBOL_UNUSED(bLFocus)

   IF oFont == NIL
      ::oFont := ::oParent:oFont
   ENDIF
   ::lflat := IIf(lflat == NIL, .F., lflat)
   ::bClick := bClick
   ::bGetFocus := bGFocus
   ::bLostFocus := bLfocus

   ::state := OBTN_INIT
   ::nOrder := IIf(oWndParent == NIL, 0, Len(oWndParent:aControls))

   ::title := cText
   ::tcolor := IIf(color == NIL, hwg_Getsyscolor(COLOR_BTNTEXT), color)
   IF bColor != NIL
      ::bcolor := bcolor
      ::brush := HBrush():Add(bcolor)
   ENDIF

   ::xt := IIf(xt == NIL, 0, xt)
   ::yt := IIf(yt == NIL, 0, yt)
   ::widtht := IIf(widtht == NIL, 0, widtht)
   ::heightt := IIf(heightt == NIL, 0, heightt)

   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lCheck != NIL
      ::lCheck := lCheck
   ENDIF
   ::themed := IIf(themed = NIL, .F., themed)
   IF bmp != NIL
      IF HB_ISOBJECT(bmp)
         ::oBitmap := bmp
      ELSE
         ::oBitmap := IIf((lResour != NIL .AND. lResour) .OR. HB_ISNUMERIC(bmp), ;
                           HBitmap():AddResource(bmp), ;
                           HBitmap():AddFile(IIf(::cPath != NIL, ::cPath + bmp, bmp)))
      ENDIF
   ENDIF
   ::xb := xb
   ::yb := yb
   ::widthb := IIf(widthb == NIL, 0, widthb)
   ::heightb := IIf(heightb == NIL, 0, heightb)
   ::lTransp := IIf(lTr != NIL, lTr, .F.)
   ::trColor := trColor
   IF bClick != NIL
      ::oParent:AddEvent(0, Self, {||::onClick()},,)
   ENDIF
   hwg_RegOwnBtn()
   ::Activate()

   RETURN Self

METHOD Activate() CLASS HOwnButton
   IF !Empty(::oParent:handle)
      ::handle := hwg_Createownbtn(::oParent:handle, ::id, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
      IF !::lEnabled
         hwg_Enablewindow(::handle, .F.)
         ::Disable()
      ENDIF
   ENDIF
   RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HOwnButton

   IF msg == WM_THEMECHANGED
      IF ::Themed
         IF HB_ISPOINTER(::hTheme)
            hwg_closethemedata(::htheme)
            ::hTheme := NIL
         ENDIF
         ::Themed := .F.
      ENDIF
      ::m_bFirstTime := .T.
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
      RETURN 0

   ELSEIF msg == WM_ERASEBKGND
      RETURN 0
   ELSEIF msg == WM_PAINT
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
      ELSE
         ::Paint()
      ENDIF
   ELSEIF msg == WM_MOUSEMOVE
      ::MouseMove(wParam, lParam)
   ELSEIF msg == WM_LBUTTONDOWN
      ::MDown()
   ELSEIF msg == WM_LBUTTONUP
      ::MUp()
   ELSEIF msg == WM_DESTROY
      ::END()
   ELSEIF msg == WM_SETFOCUS
      /*
      IF hb_IsBlock(::bGetfocus)
         Eval(::bGetfocus, Self, msg, wParam, lParam)
      ENDIF
      */
      ::onGetFocus()
   ELSEIF msg == WM_KILLFOCUS
      /*
      IF hb_IsBlock(::bLostfocus)
         Eval(::bLostfocus, Self, msg, wParam, lParam)
      ENDIF
      */
      IF !::lCheck
         ::release()
      ENDIF
      ::onLostFocus()
   ELSEIF msg = WM_CHAR .OR. msg = WM_KEYDOWN .OR. msg = WM_KEYUP
      IF wParam = VK_SPACE
			::Press()
         ::onClick()
         ::Release()
      ENDIF
   ELSE
      IF hb_IsBlock(::bOther)
         Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF
   ENDIF

   RETURN - 1

METHOD Init() CLASS HOwnButton

   IF !::lInit
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      ::Super:Init()
   ENDIF

   RETURN NIL

METHOD Redefine(oWndParent, nId, bInit, bSize, bPaint, bClick, lflat, ;
                cText, color, font, xt, yt, widtht, heightt,     ;
                bmp, lResour, xb, yb, widthb, heightb, lTr,      ;
                cTooltip, lEnabled, lCheck) CLASS HOwnButton

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0,, bInit, bSize, bPaint, cTooltip)

   ::lflat := IIf(lflat == NIL, .F., lflat)
   ::bClick := bClick
   ::state := OBTN_INIT

   ::title := cText
   ::tcolor := IIf(color == NIL, hwg_Getsyscolor(COLOR_BTNTEXT), color)
   ::ofont := font
   ::xt := IIf(xt == NIL, 0, xt)
   ::yt := IIf(yt == NIL, 0, yt)
   ::widtht := IIf(widtht == NIL, 0, widtht)
   ::heightt := IIf(heightt == NIL, 0, heightt)

   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lEnabled != NIL
      ::lEnabled := lEnabled
   ENDIF
   IF lCheck != NIL
      ::lCheck := lCheck
   ENDIF

   IF bmp != NIL
      IF HB_ISOBJECT(bmp)
         ::oBitmap := bmp
      ELSE
         ::oBitmap := IIf(lResour, HBitmap():AddResource(bmp), HBitmap():AddFile(bmp))
      ENDIF
   ENDIF
   ::xb := xb
   ::yb := yb
   ::widthb := IIf(widthb == NIL, 0, widthb)
   ::heightb := IIf(heightb == NIL, 0, heightb)
   ::lTransp := IIf(lTr != NIL, lTr, .F.)
   hwg_RegOwnBtn()

   RETURN Self

METHOD Paint() CLASS HOwnButton
   LOCAL pps, hDC
   LOCAL aCoors, state

   pps := hwg_Definepaintstru()

   hDC := hwg_Beginpaint(::handle, pps)

   aCoors := hwg_Getclientrect(::handle)

   IF ::state == OBTN_INIT
      ::state := OBTN_NORMAL
   ENDIF
   IF ::nWidth != aCoors[3] .OR. ::nHeight != aCoors[4]
      ::nWidth := aCoors[3]
      ::nHeight := aCoors[4]
   ENDIF
   IF ::Themed .AND. ::m_bFirstTime
      ::m_bFirstTime := .F.
      IF (hwg_Isthemedload())
         IF HB_ISPOINTER(::hTheme)
            hwg_closethemedata(::htheme)
         ENDIF
         IF ::WindowsManifest
            ::hTheme := hwg_openthemedata(::handle, "BUTTON")
         ENDIF
         ::hTheme := IIf(EMPTY(::hTheme), NIL, ::hTheme)
      ENDIF
      IF Empty(::hTheme)
         ::Themed := .F.
      ENDIF
   ENDIF
   IF ::Themed
      IF !::lEnabled
         state := PBS_DISABLED
      ELSE
         state := IIf(::state == OBTN_PRESSED, PBS_PRESSED, PBS_NORMAL)
      ENDIF
      IF ::lCheck
         state := OBTN_PRESSED
      ENDIF
   ENDIF

   IF ::lFlat
      IF ::Themed
         //hwg_Setbkmode(hdc, TRANSPARENT)
         IF ::handle = hwg_Getfocus() .AND. ::lCheck
            hwg_drawthemebackground(::hTheme, hdc, BP_PUSHBUTTON, PBS_PRESSED, aCoors, NIL)
         ELSEIF ::state != OBTN_NORMAL
             hwg_drawthemebackground(::hTheme, hdc, BP_PUSHBUTTON, state, aCoors, NIL)
         ELSE
            // hwg_Setbkmode(hdc, 1)
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 0)
         ENDIF
      ELSE
         IF ::state == OBTN_NORMAL
            IF !hwg_Selffocus(::handle, hwg_Getfocus())
               // NORM
               hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 0)
            ELSE
               hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 1)
            ENDIF
         ELSEIF ::state == OBTN_MOUSOVER
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 1)
         ELSEIF ::state == OBTN_PRESSED
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 2)
         ENDIF
      ENDIF
   ELSE
      IF ::Themed
         //hwg_Setbkmode(hdc, TRANSPARENT)
         IF hwg_Selffocus(::handle, hwg_Getfocus()) .AND. ::lCheck
            hwg_drawthemebackground(::hTheme, hdc, BP_PUSHBUTTON, PBS_PRESSED, aCoors, NIL)
         ELSE //IF ::state != OBTN_NORMAL
            hwg_drawthemebackground(::hTheme, hdc, BP_PUSHBUTTON, state, aCoors, NIL)
         //ELSE
         //   hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 0)
         ENDIF
      ELSE
         IF ::state == OBTN_NORMAL
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 5)
         ELSEIF ::state == OBTN_PRESSED
            hwg_Drawbutton(hDC, 0, 0, aCoors[3], aCoors[4], 6)
         ENDIF
      ENDIF
   ENDIF

   ::DrawItems(hDC)

   hwg_Endpaint(::handle, pps)
   RETURN NIL

METHOD DrawItems(hDC) CLASS HOwnButton
   LOCAL x1, y1, x2, y2, aCoors

   aCoors := hwg_Getclientrect(::handle)
   IF !EMPTY(::brush)
      hwg_Fillrect(hDC, aCoors[1] + 2, aCoors[2] + 2, aCoors[3] - 2, aCoors[4] - 2, ::Brush:handle)
   ENDIF

   IF ::oBitmap != NIL
      IF ::widthb == 0
         ::widthb := ::oBitmap:nWidth
         ::heightb := ::oBitmap:nHeight
      ENDIF
      x1 := IIf(::xb != NIL .AND. ::xb != 0, ::xb, ;
                 Round((::nWidth - ::widthb) / 2, 0))
      y1 := IIf(::yb != NIL .AND. ::yb != 0, ::yb, ;
                 Round((::nHeight - ::heightb) / 2, 0))
      IF ::lEnabled
         IF ::oBitmap:ClassName() == "HICON"
            hwg_Drawicon(hDC, ::oBitmap:handle, x1, y1)
         ELSE
            IF ::lTransp
               hwg_Drawtransparentbitmap(hDC, ::oBitmap:handle, x1, y1, ::trColor)
            ELSE
               hwg_Drawbitmap(hDC, ::oBitmap:handle,, x1, y1, ::widthb, ::heightb)
            ENDIF
         ENDIF
      ELSE
         hwg_Drawgraybitmap(hDC, ::oBitmap:handle, x1, y1)
      ENDIF
   ENDIF

   IF ::title != NIL
      IF ::oFont != NIL
         hwg_Selectobject(hDC, ::oFont:handle)
      ENDIF
      IF ::lEnabled
         hwg_Settextcolor(hDC, ::tcolor)
      ELSE
         //hwg_Settextcolor(hDC, hwg_Rgb(255, 255, 255))
         hwg_Settextcolor(hDC, hwg_Getsyscolor(COLOR_INACTIVECAPTION))
      ENDIF
      x1 := IIf(::xt != 0, ::xt, 4)
      y1 := IIf(::yt != 0, ::yt, 4)
      x2 := ::nWidth - 4
      y2 := ::nHeight - 4
      hwg_Settransparentmode(hDC, .T.)
      hwg_Drawtext(hDC, ::title, x1, y1, x2, y2, ;
                IIf(::xt != 0, DT_LEFT, DT_CENTER) + IIf(::yt != 0, DT_TOP, DT_VCENTER + DT_SINGLELINE))
      hwg_Settransparentmode(hDC, .F.)
   ENDIF

   RETURN NIL

METHOD MouseMove(wParam, lParam) CLASS HOwnButton
   LOCAL xPos, yPos
   LOCAL res := .F.

   HB_SYMBOL_UNUSED(wParam)

   IF ::state != OBTN_INIT
      xPos := hwg_Loword(lParam)
      yPos := hwg_Hiword(lParam)
      IF xPos > ::nWidth .OR. yPos > ::nHeight
         hwg_Releasecapture()
         res := .T.
      ENDIF

      IF res .AND. !::lPress
         ::state := OBTN_NORMAL
         hwg_Invalidaterect(::handle, 0)
         hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
         //hwg_Postmessage(::handle, WM_PAINT, 0, 0)
      ENDIF
      IF ::state == OBTN_NORMAL .AND. !res
         ::state := OBTN_MOUSOVER
         hwg_Invalidaterect(::handle, 0)
         //hwg_Postmessage(::handle, WM_PAINT, 0, 0)
         hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
         hwg_Setcapture(::handle)
      ENDIF
   ENDIF
   RETURN NIL

METHOD MDown() CLASS HOwnButton
   IF ::state != OBTN_PRESSED
      ::state := OBTN_PRESSED
      hwg_Sendmessage(::Handle, WM_SETFOCUS, 0, 0)
      hwg_Invalidaterect(::handle, 0)
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ELSEIF ::lCheck
      ::state := OBTN_NORMAL
      hwg_Invalidaterect(::handle, 0)
      hwg_Postmessage(::handle, WM_PAINT, 0, 0)
   ENDIF
   RETURN NIL

METHOD MUp() CLASS HOwnButton
//   IF ::state == OBTN_PRESSED
      IF !::lPress
         //::state := OBTN_NORMAL  // IIf(::lFlat, OBTN_MOUSOVER, OBTN_NORMAL)
         ::state := IIf(::lFlat, OBTN_MOUSOVER, OBTN_NORMAL)
      ENDIF
      IF ::lCheck
         IF ::lPress
            ::Release()
         ELSE
            ::Press()
         ENDIF
      ENDIF
      IF hb_IsBlock(::bClick)
         hwg_Releasecapture()
         Eval(::bClick, ::oParent, ::id)
         Release()
      ENDIF
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_FRAME + RDW_INTERNALPAINT + RDW_UPDATENOW)

   RETURN NIL

METHOD Refresh() CLASS HOwnButton
   hwg_Invalidaterect(::handle, 0)
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_FRAME + RDW_INTERNALPAINT + RDW_UPDATENOW)
   RETURN NIL


METHOD Release() CLASS HOwnButton
   ::lPress := .F.
   ::state := OBTN_NORMAL
   hwg_Invalidaterect(::handle, 0)
   hwg_Redrawwindow(::handle, RDW_FRAME + RDW_INTERNALPAINT + RDW_UPDATENOW + RDW_INVALIDATE)
   //hwg_Postmessage(::handle, WM_PAINT, 0, 0)
   RETURN NIL


METHOD onGetFocus() CLASS HOwnButton
   LOCAL res := .T., nSkip

   IF ::bGetFocus == NIL .OR. !hwg_CheckFocus(Self, .F.)
      RETURN .T.
   ENDIF
   nSkip := IIf(hwg_Getkeystate(VK_UP) < 0 .OR. (hwg_Getkeystate(VK_TAB) < 0 .AND. hwg_Getkeystate(VK_SHIFT) < 0), -1, 1)
   IF hb_IsBlock(::bGetFocus)
      ::oparent:lSuspendMsgsHandling := .T.
      res := Eval(::bGetFocus, ::title, Self)
      IF res != NIL .AND. EMPTY(res)
         hwg_WhenSetFocus(Self, nSkip)
      ENDIF
   ENDIF
   ::oparent:lSuspendMsgsHandling := .F.
   RETURN res

METHOD onLostFocus() CLASS HOwnButton

    IF ::bLostFocus != NIL .AND. !hwg_CheckFocus(Self, .T.)
       RETURN .T.
   ENDIF
    IF hb_IsBlock(::bLostFocus)
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bLostFocus, ::title, Self)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF
    RETURN NIL

METHOD onClick() CLASS HOwnButton
   IF hb_IsBlock(::bClick)
      //::oParent:lSuspendMsgsHandling := .T.
      Eval(::bClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF
   RETURN NIL


METHOD END() CLASS HOwnButton

   ::Super:END()
   ::oFont := NIL
   IF ::oBitmap != NIL
      ::oBitmap:Release()
      ::oBitmap := NIL
   ENDIF
   hwg_Postmessage(::handle, WM_CLOSE, 0, 0)
   RETURN NIL

METHOD Enable() CLASS HOwnButton

   hwg_Enablewindow(::handle, .T.)
   ::lEnabled := .T.
   hwg_Invalidaterect(::handle, 0)
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   //::Init() BECAUSE ERROR GPF

   RETURN NIL

METHOD Disable() CLASS HOwnButton

   ::state := OBTN_INIT
   ::lEnabled := .F.
   hwg_Invalidaterect(::handle, 0)
   hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   hwg_Enablewindow(::handle, .F.)

   RETURN NIL
