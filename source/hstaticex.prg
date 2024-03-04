/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HStaticEx
 *
 * Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
 * www - http://sites.uol.com.br/culikr/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

//#translate :hBitmap       => :m_csbitmaps\[1\]
//#translate :dwWidth       => :m_csbitmaps\[2\]
//#translate :dwHeight      => :m_csbitmaps\[3\]
//#translate :hMask         => :m_csbitmaps\[4\]
//#translate :crTransparent => :m_csbitmaps\[5\]

#define TRANSPARENT 1
//#define BTNST_COLOR_BK_IN     1            // Background color when mouse is INside
//#define BTNST_COLOR_FG_IN     2            // Text color when mouse is INside
//#define BTNST_COLOR_BK_OUT    3             // Background color when mouse is OUTside
//#define BTNST_COLOR_FG_OUT    4             // Text color when mouse is OUTside
//#define BTNST_COLOR_BK_FOCUS  5           // Background color when the button is focused
//#define BTNST_COLOR_FG_FOCUS  6            // Text color when the button is focused
//#define BTNST_MAX_COLORS      6
//#define WM_SYSCOLORCHANGE               0x0015
//#define BS_TYPEMASK SS_TYPEMASK
//#define OFS_X 10 // distance from left/right side to beginning/end of text

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

   nStyle := IIf(nStyle = NIL, 0, nStyle)
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

#if 0 // old code for reference (to be deleted)
METHOD OnEvent(msg, wParam, lParam) CLASS  HStaticEx
   LOCAL nEval, pos

   IF hb_IsBlock(::bOther)
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
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
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
#else
METHOD OnEvent(msg, wParam, lParam) CLASS HStaticEx

   LOCAL nEval
   LOCAL pos

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != -1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF

   SWITCH msg

   CASE WM_ERASEBKGND
      RETURN 0

   CASE WM_KEYUP
      SWITCH wParam
      CASE VK_DOWN
         hwg_GetSkip(::oParent, ::handle, , 1)
         EXIT
      CASE VK_UP
         hwg_GetSkip(::oParent, ::handle, , -1)
         EXIT
      CASE VK_TAB
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
      ENDSWITCH
      RETURN 0

   CASE WM_SYSKEYUP
      IF (pos := At("&", ::title)) > 0 .AND. wParam == Asc(Upper(SubStr(::title, ++pos, 1)))
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN  0
      ENDIF
      EXIT

   CASE WM_GETDLGCODE
      RETURN DLGC_WANTARROWS + DLGC_WANTTAB

   ENDSWITCH

   RETURN -1
#endif

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
   LOCAL client_rect
   LOCAL szText
   LOCAL dwtext
   LOCAL nstyle
   LOCAL brBackground
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
      brBackground := IIf(!Empty(::brush), ::brush, ::hBrushDefault)
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

   IF hb_IsBlock(::bClick)
      //::oParent:lSuspendMsgsHandling := .T.
      Eval(::bClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

METHOD onDblClick() CLASS HStaticEx

   IF hb_IsBlock(::bDblClick)
      Eval(::bDblClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN NIL

METHOD Auto_Size(cValue) CLASS HStaticEx

   LOCAL ASize
   LOCAL nLeft
   LOCAL nAlign

   IF ::autosize
      nAlign := ::nStyleHS - SS_NOTIFY
      ASize := hwg_TxtRect(cValue, Self)
      // ajust VCENTER
      SWITCH nAlign
      CASE SS_RIGHT
         nLeft := ::nLeft + (::nWidth - ASize[1] - 2)
         EXIT
      CASE SS_CENTER
         nLeft := ::nLeft + Int((::nWidth - ASize[1] - 2) / 2)
         EXIT
      CASE SS_LEFT
         nLeft := ::nLeft
         EXIT
      #ifdef __XHARBOUR__
      DEFAULT
      #else
      OTHERWISE
      #endif
         nLeft := ::nLeft
      ENDSWITCH
      ::nWidth := ASize[1] + 2
      ::nHeight := ASize[2]
      ::nLeft := nLeft
      ::move(::nLeft, ::nTop)
   ENDIF

   RETURN NIL
