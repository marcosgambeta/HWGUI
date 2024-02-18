/*
 * $Id: hctrlex.prg 2076 2013-06-13 15:37:33Z druzus $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HStaticEx, HGroupEx
 *
 * Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#translate :hBitmap       => :m_csbitmaps\[1\]
#translate :dwWidth       => :m_csbitmaps\[2\]
#translate :dwHeight      => :m_csbitmaps\[3\]
#translate :hMask         => :m_csbitmaps\[4\]
#translate :crTransparent => :m_csbitmaps\[5\]

#define TRANSPARENT 1
#define BTNST_COLOR_BK_IN     1            // Background color when mouse is INside
#define BTNST_COLOR_FG_IN     2            // Text color when mouse is INside
#define BTNST_COLOR_BK_OUT    3             // Background color when mouse is OUTside
#define BTNST_COLOR_FG_OUT    4             // Text color when mouse is OUTside
#define BTNST_COLOR_BK_FOCUS  5           // Background color when the button is focused
#define BTNST_COLOR_FG_FOCUS  6            // Text color when the button is focused
#define BTNST_MAX_COLORS      6
#define WM_SYSCOLORCHANGE               0x0015
#define BS_TYPEMASK SS_TYPEMASK
#define OFS_X 10 // distance from left/right side to beginning/end of text

CLASS HStaticEx INHERIT HStatic

   CLASS VAR winclass   INIT "STATIC"
   DATA AutoSize INIT .F.
   DATA nStyleHS
   DATA bClick, bDblClick
   DATA hBrushDefault  HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
      bColor, lTransp, bClick, bDblClick, bOther)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor, lTransp, bClick, bDblClick, bOther)
   METHOD SetText(value) INLINE ::SetValue(value)
   METHOD SetValue(cValue)
   METHOD Auto_Size(cValue)  HIDDEN
   METHOD Init()
   METHOD PAINT(lpDis)
   METHOD onClick()
   METHOD onDblClick()
   METHOD OnEvent(msg, wParam, lParam)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
      bColor, lTransp, bClick, bDblClick, bOther) CLASS HStaticEx

   nStyle := iif(nStyle = Nil, 0, nStyle)
   ::nStyleHS := nStyle - Hwg_BitAND(nStyle, WS_VISIBLE + WS_DISABLED + WS_CLIPSIBLINGS + ;
      WS_CLIPCHILDREN + WS_BORDER + WS_DLGFRAME + ;
      WS_VSCROLL + WS_HSCROLL + WS_THICKFRAME + WS_TABSTOP)
   nStyle += SS_NOTIFY + WS_CLIPCHILDREN

   ::BackStyle := OPAQUE
   IF (lTransp != NIL .AND. lTransp)
      ::BackStyle := TRANSPARENT
      ::extStyle := Hwg_BitOr(::extStyle, WS_EX_TRANSPARENT)
      bPaint := {|o, p|o:paint(p)}
      nStyle += SS_OWNERDRAW - ::nStyleHS
   ELSEIF ::nStyleHS > 32 .OR. ::nStyleHS = 2
      bPaint := {|o, p|o:paint(p)}
      nStyle += SS_OWNERDRAW - ::nStyleHS
   ENDIF

   ::hBrushDefault := HBrush():Add(hwg_Getsyscolor(COLOR_BTNFACE))
   ::bOther := bOther
   // ::title := cCaption

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor, lTransp)

   // ::Activate()

   ::bClick := bClick
   IF ::id > 2
      ::oParent:AddEvent(STN_CLICKED, Self, {||::onClick()})
   ENDIF
   ::bDblClick := bDblClick
   ::oParent:AddEvent(STN_DBLCLK, Self, {||::onDblClick()})

   RETURN Self

METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor, lTransp, bClick, bDblClick, bOther) CLASS HStaticEx

   IF (lTransp != NIL .AND. lTransp)
      ::extStyle := Hwg_BitOr(::extStyle, WS_EX_TRANSPARENT)
      bPaint := {|o, p|o:paint(p)}
      ::BackStyle := TRANSPARENT
   ENDIF

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, cCaption, oFont, bInit, ;
      bSize, bPaint, ctooltip, tcolor, bcolor)

   ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   // Enabling style for tooltips
   ::style := SS_NOTIFY
   ::bOther := bOther
   ::bClick := bClick
   IF ::id > 2
      ::oParent:AddEvent(STN_CLICKED, Self, {||::onClick()})
   ENDIF
   ::bDblClick := bDblClick
   ::oParent:AddEvent(STN_DBLCLK, Self, {||::onDblClick()})

   RETURN Self

METHOD Init() CLASS HStaticEx

   IF !::lInit
      ::Super:init()
      IF ::nHolder != 1
         ::nHolder := 1
         hwg_Setwindowobject(::handle, Self)
         Hwg_InitStaticProc(::handle)
      ENDIF
      IF ::classname == "HSTATIC"
         ::Auto_Size(::Title)
      ENDIF
      IF ::title != NIL
         hwg_Setwindowtext(::handle, ::title)
      ENDIF
   ENDIF

   RETURN  NIL

METHOD OnEvent(msg, wParam, lParam) CLASS  HStaticEx
   LOCAL nEval, pos

   IF ::bOther != NIL
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != - 1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_ERASEBKGND
      RETURN 0
   ELSEIF msg = WM_KEYUP
      IF wParam = VK_DOWN
         hwg_GetSkip(::oParent, ::handle, , 1)
      ELSEIF wParam = VK_UP
         hwg_GetSkip(::oParent, ::handle, , -1)
      ELSEIF wParam = VK_TAB
         hwg_GetSkip(::oParent, ::handle, , iif(hwg_IsCtrlShift(.F., .T.), -1, 1))
      ENDIF
      RETURN 0
   ELSEIF msg == WM_SYSKEYUP
      IF (pos := At("&", ::title)) > 0 .AND. wParam == Asc(Upper(SubStr(::title, ++pos, 1)))
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN  0
      ENDIF
   ELSEIF msg = WM_GETDLGCODE
      RETURN DLGC_WANTARROWS + DLGC_WANTTAB
   ENDIF

   RETURN - 1

METHOD SetValue(cValue) CLASS HStaticEx

   ::Auto_Size(cValue)
   IF ::backstyle = TRANSPARENT .AND. ::Title != cValue .AND. hwg_Iswindowvisible(::handle)
      hwg_Setdlgitemtext(::oParent:handle, ::id, cValue)
      IF ::backstyle = TRANSPARENT .AND. ::Title != cValue .AND. hwg_Iswindowvisible(::handle)
         hwg_Redrawwindow(::oParent:Handle, RDW_ERASE + RDW_INVALIDATE + RDW_ERASENOW + RDW_INTERNALPAINT, ::nLeft, ::nTop, ::nWidth, ::nHeight)
         hwg_Updatewindow(::oParent:Handle)
      ENDIF
   ELSEIF ::backstyle != TRANSPARENT
      hwg_Setdlgitemtext(::oParent:handle, ::id, cValue)
   ENDIF
   ::Title := cValue

   RETURN NIL

METHOD Paint(lpDis) CLASS HStaticEx
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpDis)
   LOCAL client_rect, szText
   LOCAL dwtext, nstyle, brBackground
   LOCAL dc := drawInfo[3]

   client_rect := hwg_Copyrect({ drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7] })
   szText := hwg_Getwindowtext(::handle)

   // Map "Static Styles" to "Text Styles"
   nstyle := ::nStyleHS  // ::style
   IF nStyle - SS_NOTIFY < DT_SINGLELINE
      hwg_Setastyle(@nstyle, @dwtext)
   ELSE
      dwtext := nStyle - DT_NOCLIP
   ENDIF

   // Set transparent background
   hwg_Setbkmode(dc, ::backstyle)
   IF ::BackStyle = OPAQUE
      brBackground := iif(!Empty(::brush), ::brush, ::hBrushDefault)
      hwg_Fillrect(dc, client_rect[1], client_rect[2], client_rect[3], client_rect[4], brBackground:handle)
   ENDIF

   IF ::tcolor != NIL .AND. ::isEnabled()
      hwg_Settextcolor(dc, ::tcolor)
   ELSEIF !::isEnabled()
      hwg_Settextcolor(dc, 16777215)
      hwg_Drawtext(dc, szText, { client_rect[1] + 1, client_rect[2] + 1, client_rect[3] + 1, client_rect[4] + 1 }, dwtext)
      hwg_Setbkmode(dc, TRANSPARENT)
      hwg_Settextcolor(dc, 10526880)
   ENDIF
   // Draw the text
   hwg_Drawtext(dc, szText, client_rect, dwtext)

   RETURN NIL

METHOD onClick() CLASS HStaticEx

   IF ::bClick != NIL
      //::oParent:lSuspendMsgsHandling := .T.
      Eval(::bClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

METHOD onDblClick() CLASS HStaticEx

   IF ::bDblClick != NIL
      Eval(::bDblClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

METHOD Auto_Size(cValue) CLASS HStaticEx
   LOCAL ASize, nLeft, nAlign

   IF ::autosize
      nAlign := ::nStyleHS - SS_NOTIFY
      ASize := hwg_TxtRect(cValue, Self)
      // ajust VCENTER
      IF nAlign == SS_RIGHT
         nLeft := ::nLeft + (::nWidth - ASize[1] - 2)
      ELSEIF nAlign == SS_CENTER
         nLeft := ::nLeft + Int((::nWidth - ASize[1] - 2) / 2)
      ELSEIF nAlign == SS_LEFT
         nLeft := ::nLeft
      ENDIF
      ::nWidth := ASize[1] + 2
      ::nHeight := ASize[2]
      ::nLeft := nLeft
      ::move(::nLeft, ::nTop)
   ENDIF

   RETURN NIL

CLASS HButtonX INHERIT HButton

   CLASS VAR winclass   INIT "BUTTON"
   DATA bClick
   DATA cNote  HIDDEN
   DATA lFlat INIT .F.

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, bGFocus)
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, bGFocus)
   METHOD Init()
   METHOD onClick()
   METHOD onGetFocus()
   METHOD onLostFocus()
   METHOD onEvent(msg, wParam, lParam)
   METHOD NoteCaption(cNote)  SETGET

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
      tcolor, bColor, bGFocus) CLASS HButtonX

   nStyle := Hwg_BitOr(iif(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON + BS_NOTIFY)
   ::lFlat := Hwg_BitAND(nStyle, BS_FLAT) != 0

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint,, cTooltip, ;
      tcolor, bColor, bGFocus)

   ::bClick := bClick
   ::bGetFocus  := bGFocus
   ::oParent:AddEvent(BN_SETFOCUS, Self, {||::onGetFocus()})
   ::oParent:AddEvent(BN_KILLFOCUS, self, {||::onLostFocus()})

   IF ::id > IDCANCEL .OR. ::bClick != NIL
      IF ::id < IDABORT
         hwg_GetParentForm(Self):AddEvent(BN_CLICKED, Self, {||::onClick()})
      ENDIF
      IF hwg_GetParentForm(Self):Classname != ::oParent:Classname .OR. ::id > IDCANCEL
         ::oParent:AddEvent(BN_CLICKED, Self, {||::onClick()})
      ENDIF
   ENDIF

   RETURN Self

METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, cCaption, bGFocus) CLASS HButtonX

   HControl():New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
      bSize, bPaint, cTooltip, tcolor, bColor)

   ::title   := cCaption
   ::bGetFocus  := bGFocus
   ::oParent:AddEvent(BN_SETFOCUS, Self, {||::onGetFocus()})
   ::oParent:AddEvent(BN_KILLFOCUS, self, {||::onLostFocus()})
   ::bClick  := bClick
   IF ::id > IDCANCEL .OR. ::bClick != NIL
      IF ::id < IDABORT
         hwg_GetParentForm(Self):AddEvent(BN_CLICKED, Self, {||::onClick()})
      ENDIF
      IF hwg_GetParentForm(Self):Classname != ::oParent:Classname .OR. ::id > IDCANCEL
         ::oParent:AddEvent(BN_CLICKED, Self, {||::onClick()})
      ENDIF
   ENDIF

   RETURN Self

METHOD Init() CLASS HButtonX

   IF !::lInit
      IF !(hwg_GetParentForm(Self):classname == ::oParent:classname .AND. ;
            hwg_GetParentForm(Self):Type >= WND_DLG_RESOURCE) .OR. ;
            !hwg_GetParentForm(Self):lModal .OR. ::nHolder = 1
         ::nHolder := 1
         hwg_Setwindowobject(::handle, Self)
         HWG_INITBUTTONPROC(::handle)
      ENDIF
      ::Super:init()
   ENDIF

   RETURN  NIL

METHOD onevent(msg, wParam, lParam) CLASS HButtonX

   IF msg = WM_SETFOCUS .AND. ::oParent:oParent = NIL
   ELSEIF msg = WM_KILLFOCUS
      IF hwg_GetParentForm(Self):handle != ::oParent:Handle
         hwg_Invalidaterect(::handle, 0)
         hwg_Sendmessage(::handle, BM_SETSTYLE, BS_PUSHBUTTON, 1)
      ENDIF
   ELSEIF msg = WM_KEYDOWN
      IF (wParam == VK_RETURN .OR. wParam == VK_SPACE)
         hwg_Sendmessage(::handle, WM_LBUTTONDOWN, 0, hwg_Makelparam(1, 1))
         RETURN 0
      ENDIF
      IF !hwg_ProcKeyList(Self, wParam)
         IF wParam = VK_TAB
            hwg_GetSkip(::oparent, ::handle, , iif(hwg_IsCtrlShift(.F., .T.), -1, 1))
            RETURN 0
         ELSEIF wParam = VK_LEFT .OR. wParam = VK_UP
            hwg_GetSkip(::oparent, ::handle, , -1)
            RETURN 0
         ELSEIF wParam = VK_RIGHT .OR. wParam = VK_DOWN
            hwg_GetSkip(::oparent, ::handle, , 1)
            RETURN 0
         ENDIF
      ENDIF
   ELSEIF msg == WM_KEYUP
      IF (wParam == VK_RETURN .OR. wParam == VK_SPACE)
         hwg_Sendmessage(::handle, WM_LBUTTONUP, 0, hwg_Makelparam(1, 1))
         RETURN 0
      ENDIF
   ELSEIF msg = WM_GETDLGCODE .AND. !Empty(lParam)
      IF wParam = VK_RETURN .OR. wParam = VK_TAB
      ELSEIF hwg_Getdlgmessage(lParam) = WM_KEYDOWN .AND. wParam != VK_ESCAPE
      ELSEIF hwg_Getdlgmessage(lParam) = WM_CHAR .OR. wParam = VK_ESCAPE
         RETURN - 1
      ENDIF
      RETURN DLGC_WANTMESSAGE
   ENDIF

   RETURN - 1

METHOD onClick() CLASS HButtonX

   IF ::bClick != NIL
      Eval(::bClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

METHOD NoteCaption(cNote) CLASS HButtonX

   IF cNote != NIL
      IF Hwg_BitOr(::Style, BS_COMMANDLINK) > 0
         hwg_Sendmessage(::Handle, BCM_SETNOTE, 0, hwg_Ansitounicode(cNote))
      ENDIF
      ::cNote := cNote
   ENDIF

   RETURN ::cNote

METHOD onGetFocus() CLASS HButtonX
   LOCAL res := .T., nSkip

   IF !hwg_CheckFocus(Self, .F.) .OR. ::bGetFocus = NIL
      RETURN .T.
   ENDIF
   IF ::bGetFocus != NIL
      nSkip := iif(hwg_Getkeystate(VK_UP) < 0 .OR. (hwg_Getkeystate(VK_TAB) < 0 .AND. hwg_Getkeystate(VK_SHIFT) < 0), -1, 1)
      ::oParent:lSuspendMsgsHandling := .T.
      res := Eval(::bGetFocus, ::title, Self)
      ::oParent:lSuspendMsgsHandling := .F.
      IF res != NIL .AND. Empty(res)
         hwg_WhenSetFocus(Self, nSkip)
         IF ::lflat
            hwg_Invalidaterect(::oParent:Handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
         ENDIF
      ENDIF
   ENDIF

   RETURN res

METHOD onLostFocus() CLASS HButtonX

   IF ::lflat
      hwg_Invalidaterect(::oParent:Handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
   ENDIF
   ::lnoWhen := .F.
   IF ::bLostFocus != NIL .AND. hwg_Selffocus(hwg_Getparent(hwg_Getfocus()), hwg_getparentform(Self):Handle)
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bLostFocus, ::title, Self)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

CLASS HGroupEx INHERIT HGroup

   DATA oRGroup
   DATA oBrush
   DATA lTransparent HIDDEN

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
      cCaption, oFont, bInit, bSize, bPaint, tcolor, bColor, lTransp, oRGroup)
   METHOD Init()
   METHOD Paint(lpDis)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
      oFont, bInit, bSize, bPaint, tcolor, bColor, lTransp, oRGroup) CLASS HGroupEx

   ::oRGroup := oRGroup
   ::oBrush := iif(bColor != NIL, ::brush, NIL)
   ::lTransparent := iif(lTransp != NIL, lTransp, .F.)
   ::backStyle := iif((lTransp != NIL .AND. lTransp) .OR. ::bColor != NIL, TRANSPARENT, OPAQUE)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
      oFont, bInit, bSize, bPaint, tcolor, bColor)

   RETURN Self

METHOD Init() CLASS HGroupEx
   LOCAL nbs

   IF !::lInit
      ::Super:Init()
      // *-IF ::backStyle = TRANSPARENT .OR. ::bColor != NIL
      IF ::oBrush != NIL .OR. ::backStyle = TRANSPARENT
         nbs := HWG_GETWINDOWSTYLE(::handle)
         nbs := hwg_Modstyle(nbs, BS_TYPEMASK, BS_OWNERDRAW + WS_DISABLED)
         HWG_SETWINDOWSTYLE(::handle, nbs)
         ::bPaint   := {|o, p|o:paint(p)}
      ENDIF
      IF ::oRGroup != NIL
         ::oRGroup:Handle := ::handle
         ::oRGroup:id := ::id
         ::oFont := ::oRGroup:oFont
         ::oRGroup:lInit := .F.
         ::oRGroup:Init()
      ELSE
         IF ::oBrush != NIL
            hwg_Setwindowpos(::Handle, NIL, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE)
         ELSE
            hwg_Setwindowpos(::Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE + SWP_NOACTIVATE + SWP_NOSENDCHANGING)
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

METHOD PAINT(lpdis) CLASS HGroupEx
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL DC := drawInfo[3]
   LOCAL ppnOldPen, pnFrmDark, pnFrmLight, iUpDist
   LOCAL szText, aSize, dwStyle
   LOCAL rc  := hwg_Copyrect({ drawInfo[4], drawInfo[5], drawInfo[6] - 1, drawInfo[7] - 1 })
   LOCAL rcText

   // determine text length
   szText := ::Title
   aSize := hwg_TxtRect(iif(Empty(szText), "A", szText), Self)
   // distance from window top to group rect
   iUpDist := (aSize[2] / 2)
   dwStyle := ::Style //HWG_GETWINDOWSTYLE(::handle) //GetStyle();
   rcText := { 0, rc[2] + iUpDist, 0, rc[2] + iUpDist  }
   IF Empty(szText)
   ELSEIF hb_BitAnd(dwStyle, BS_CENTER) == BS_RIGHT // right aligned
      rcText[3] := rc[3] + 2 - OFS_X
      rcText[1] := rcText[3] - aSize[1]
   ELSEIF hb_BitAnd(dwStyle, BS_CENTER) == BS_CENTER  // text centered
      rcText[1] := (rc[3] - rc[1]  - aSize[1]) / 2
      rcText[3] := rcText[1] + aSize[1]
   ELSE //((!(dwStyle & BS_CENTER)) || ((dwStyle & BS_CENTER) == BS_LEFT))// left aligned   / default
      rcText[1] := rc[1] + OFS_X
      rcText[3] := rcText[1] + aSize[1]
   ENDIF
   hwg_Setbkmode(dc, TRANSPARENT)

   IF Hwg_BitAND(dwStyle, BS_FLAT) != 0  // "flat" frame
      //pnFrmDark  := hwg_Createpen(PS_SOLID, 1, hwg_Rgb(0, 0, 0)))
      pnFrmDark  := HPen():Add(PS_SOLID, 1, hwg_Rgb(64, 64, 64))
      pnFrmLight := HPen():Add(PS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
      ppnOldPen := hwg_Selectobject(dc, pnFrmDark:Handle)
      hwg_Moveto(dc, rcText[1] - 2, rcText[2])
      hwg_Lineto(dc, rc[1], rcText[2])
      hwg_Lineto(dc, rc[1], rc[4])
      hwg_Lineto(dc, rc[3], rc[4])
      hwg_Lineto(dc, rc[3], rcText[4])
      hwg_Lineto(dc, rcText[3], rcText[4])
      hwg_Selectobject(dc, pnFrmLight:handle)
      hwg_Moveto(dc, rcText[1] - 2, rcText[2] + 1)
      hwg_Lineto(dc, rc[1] + 1, rcText[2] + 1)
      hwg_Lineto(dc, rc[1] + 1, rc[4] - 1)
      hwg_Lineto(dc, rc[3] - 1, rc[4] - 1)
      hwg_Lineto(dc, rc[3] - 1, rcText[4] + 1)
      hwg_Lineto(dc, rcText[3], rcText[4] + 1)
   ELSE // 3D frame
      pnFrmDark  := HPen():Add(PS_SOLID, 1, hwg_Getsyscolor(COLOR_3DSHADOW))
      pnFrmLight := HPen():Add(PS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
      ppnOldPen := hwg_Selectobject(dc, pnFrmDark:handle)
      hwg_Moveto(dc, rcText[1] - 2, rcText[2])
      hwg_Lineto(dc, rc[1], rcText[2])
      hwg_Lineto(dc, rc[1], rc[4] - 1)
      hwg_Lineto(dc, rc[3] - 1, rc[4] - 1)
      hwg_Lineto(dc, rc[3] - 1, rcText[4])
      hwg_Lineto(dc, rcText[3], rcText[4])
      hwg_Selectobject(dc, pnFrmLight:handle)
      hwg_Moveto(dc, rcText[1] - 2, rcText[2] + 1)
      hwg_Lineto(dc, rc[1] + 1, rcText[2] + 1)
      hwg_Lineto(dc, rc[1] + 1, rc[4] - 1)
      hwg_Moveto(dc, rc[1], rc[4])
      hwg_Lineto(dc, rc[3], rc[4])
      hwg_Lineto(dc, rc[3], rcText[4] - 1)
      hwg_Moveto(dc, rc[3] - 2, rcText[4] + 1)
      hwg_Lineto(dc, rcText[3], rcText[4] + 1)
   ENDIF
   // draw text (if any)
   IF !Empty(szText) // !(dwExStyle & (BS_ICON|BS_BITMAP)))
      hwg_Setbkmode(dc, TRANSPARENT)
      IF ::oBrush != NIL
         hwg_Fillrect(DC, rc[1] + 2, rc[2] + iUpDist + 2, rc[3] - 2, rc[4] - 2, ::brush:handle)
         IF !::lTransparent
            hwg_Fillrect(DC, rcText[1] - 2, rc[2] + 1, rcText[3] + 1, rc[2] + iUpDist + 2, ::brush:handle)
         ENDIF
      ENDIF
      hwg_Drawtext(dc, szText, rcText, DT_VCENTER + DT_LEFT + DT_SINGLELINE + DT_NOCLIP)
   ENDIF
   // cleanup
   hwg_Deleteobject(pnFrmLight)
   hwg_Deleteobject(pnFrmDark)
   hwg_Selectobject(dc, ppnOldPen)

   RETURN NIL
