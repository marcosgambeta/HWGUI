/*
 *$Id: hcwindow.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HCustomWindow class
 *
 * Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1
#define EVENTS_MESSAGES 1
#define EVENTS_ACTIONS  2
#define RT_MANIFEST  24

#if 0 // TODO: old code for reference (to be deleted)
STATIC aCustomEvents := { ;
       { WM_NOTIFY, WM_PAINT, WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORBTN, WM_CTLCOLORLISTBOX, ;
         WM_COMMAND, WM_DRAWITEM, WM_SIZE, WM_DESTROY }, ;
       { ;
         {|o, w, l|onNotify(o, w, l)}                                 , ;
         {|o, w   |IIf(o:bPaint != NIL, Eval(o:bPaint, o, w), -1)}  , ;
         {|o, w, l|onCtlColor(o, w, l)}                               , ;
         {|o, w, l|onCtlColor(o, w, l)}                               , ;
         {|o, w, l|onCtlColor(o, w, l)}                               , ;
         {|o, w, l|onCtlColor(o, w, l)}                               , ;
         {|o, w, l|onCommand(o, w, l)}                                , ;
         {|o, w, l|onDrawItem(o, w, l)}                               , ;
         {|o, w, l|onSize(o, w, l)}                                   , ;
         {|o      |onDestroy(o)}                                          ;
       } ;
     }
#endif

CLASS HCustomWindow INHERIT HObject

CLASS VAR oDefaultParent SHARED
CLASS VAR WindowsManifest INIT !EMPTY(hwg_Findresource(, 1, RT_MANIFEST)) SHARED

   DATA handle        INIT 0
   DATA oParent
   DATA title
   ACCESS Caption  INLINE ::title
   ASSIGN Caption(x) INLINE ::SetTextClass(x)
   DATA Type       INIT 0
   DATA nTop, nLeft, nWidth, nHeight
   DATA minWidth   INIT - 1
   DATA maxWidth   INIT - 1
   DATA minHeight  INIT - 1
   DATA maxHeight  INIT - 1
   DATA tcolor, bcolor, brush
   DATA style
   DATA extStyle      INIT 0
   DATA lHide         INIT .F.
   DATA oFont
   DATA aEvents       INIT {}
   DATA lSuspendMsgsHandling  INIT .F.
   DATA lGetSkipLostFocus     INIT .F.
   DATA aNotify       INIT {}
   DATA aControls     INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bScroll
   DATA bOther
   DATA bRefresh
   DATA cargo
   DATA HelpId        INIT 0
   DATA nHolder       INIT 0

   DATA lClosable     INIT .T. //disable Menu and Button Close in WINDOW

   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, oCtrl, bAction, lNotify, cMethName)
   METHOD FindControl(nId, nHandle)
   METHOD Hide()              INLINE (::lHide := .T., hwg_Hidewindow(::handle))
   METHOD Show(nShow)       INLINE (::lHide := .F., hwg_Showwindow(::handle, nShow))
   METHOD Move(x1, y1, width, height, nRePaint)
   METHOD onEvent(msg, wParam, lParam)
   METHOD END()
   METHOD SetColor(tcolor, bColor, lRepaint)
   METHOD Refresh(lAll, oCtrl)
   METHOD Anchor(oCtrl, x, y, w, h)
   METHOD SetTextClass(x) HIDDEN
   METHOD Closable(lClosable) SETGET
   METHOD Release()        INLINE ::DelControl(Self)

ENDCLASS

METHOD AddEvent(nEvent, oCtrl, bAction, lNotify, cMethName) CLASS HCustomWindow

   AAdd(IIf(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), ;
         { nEvent, IIf(ValType(oCtrl) == "N", oCtrl, oCtrl:id), bAction })
   IF bAction != Nil .AND. ValType(oCtrl) == "O"  //.AND. ValType(oCtrl) != "N"
      IF cMethName != Nil //.AND. !__objHasMethod(oCtrl, cMethName)
         __objAddInline(oCtrl, cMethName, bAction)
      ENDIF
   ENDIF
   RETURN nil

METHOD FindControl(nId, nHandle) CLASS HCustomWindow

   LOCAL bSearch := IIf(nId != NIL, {|o|o:id == nId}, {|o|hwg_Ptrtoulong(o:handle) == hwg_Ptrtoulong(nHandle)})
   LOCAL i := Len(::aControls)
   LOCAL oCtrl

   DO WHILE i > 0
      IF Len(::aControls[i]:aControls) > 0 .AND. ;
         (oCtrl := ::aControls[i]:FindControl(nId, nHandle)) != nil
         RETURN oCtrl
      ENDIF
      IF Eval(bSearch, ::aControls[i])
         RETURN ::aControls[i]
      ENDIF
      i --
   ENDDO
   RETURN Nil

METHOD DelControl(oCtrl) CLASS HCustomWindow
   LOCAL h := oCtrl:handle, id := oCtrl:id
   LOCAL i := AScan(::aControls, {|o|o:handle == h})

   hwg_Sendmessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      ADel(::aControls, i)
      ASize(::aControls, Len(::aControls) - 1)
   ENDIF

   h := 0
   FOR i := Len(::aEvents) TO 1 STEP - 1
      IF ::aEvents[i, 2] == id
         ADel(::aEvents, i)
         h++
      ENDIF
   NEXT

   IF h > 0
      ASize(::aEvents, Len(::aEvents) - h)
   ENDIF

   h := 0
   FOR i := Len(::aNotify) TO 1 STEP - 1
      IF ::aNotify[i, 2] == id
         ADel(::aNotify, i)
         h++
      ENDIF
   NEXT

   IF h > 0
      ASize(::aNotify, Len(::aNotify) - h)
   ENDIF

   RETURN NIL

METHOD Move(x1, y1, width, height, nRePaint) CLASS HCustomWindow
   LOCAL rect, nHx := 0, nWx := 0

   x1     := IIF(x1     = NIL, ::nLeft, x1)
   y1     := IIF(y1     = NIL, ::nTop, y1)
   width  := IIF(width  = NIL, ::nWidth, width)
   height := IIF(height = NIL, ::nHeight, height)
   IF Hwg_BitAnd(::style, WS_CHILD) = 0
      rect := hwg_Getwindowrect(::Handle)
      nHx := rect[4] - rect[2]  - hwg_Getclientrect(::Handle)[4] - ;
                 IIF(Hwg_BitAnd(::style, WS_HSCROLL) > 0, hwg_Getsystemmetrics(SM_CYHSCROLL), 0)
      nWx := rect[3] - rect[1]  - hwg_Getclientrect(::Handle)[3] - ;
                 IIF(Hwg_BitAnd(::style, WS_VSCROLL) > 0, hwg_Getsystemmetrics(SM_CXVSCROLL), 0)
   ENDIF

   IF nRePaint = Nil
      hwg_Movewindow(::handle, x1, y1, Width + nWx, Height + nHx)
   ELSE
      hwg_Movewindow(::handle, x1, y1, Width + nWx, Height + nHx, nRePaint)
   ENDIF

   //IF x1 != NIL
      ::nLeft := x1
   //ENDIF
   //IF y1 != NIL
      ::nTop  := y1
   //ENDIF
   //IF width != NIL
      ::nWidth := width
   //ENDIF
   //IF height != NIL
      ::nHeight := height
   //ENDIF
   //hwg_Movewindow(::handle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

   RETURN NIL

#if 0 // TODO: old code for reference (to be deleted)
METHOD onEvent(msg, wParam, lParam) CLASS HCustomWindow
   LOCAL i

   // Writelog("== "+::Classname()+Str(msg)+IIF(wParam!=NIL, Str(wParam), "NIL")+IIF(lParam!=NIL, Str(lParam), "NIL"))

   IF msg = WM_GETMINMAXINFO
      IF ::minWidth  > - 1 .OR. ::maxWidth  > - 1 .OR. ;
         ::minHeight > - 1 .OR. ::maxHeight > - 1
         hwg_Minmaxwindow(::handle, lParam, ;
                       IIf(::minWidth  > - 1, ::minWidth, nil), ;
                       IIf(::minHeight > - 1, ::minHeight, nil), ;
                       IIf(::maxWidth  > - 1, ::maxWidth, nil), ;
                       IIf(::maxHeight > - 1, ::maxHeight, nil))
         RETURN 0
      ENDIF
   ENDIF

   IF (i := AScan(aCustomEvents[EVENTS_MESSAGES], msg)) != 0
      RETURN Eval(aCustomEvents[EVENTS_ACTIONS, i], Self, wParam, lParam)

   ELSEIF ::bOther != NIL

      RETURN Eval(::bOther, Self, msg, wParam, lParam)

   ENDIF

   RETURN - 1
#endif

METHOD onEvent(msg, wParam, lParam) CLASS HCustomWindow

   IF msg == WM_GETMINMAXINFO
      IF ::minWidth > -1 .OR. ::maxWidth > -1 .OR. ::minHeight > -1 .OR. ::maxHeight > -1
         hwg_Minmaxwindow(::handle, lParam, ;
            IIf(::minWidth  > -1, ::minWidth, NIL), ;
            IIf(::minHeight > -1, ::minHeight, NIL), ;
            IIf(::maxWidth  > -1, ::maxWidth, NIL), ;
            IIf(::maxHeight > -1, ::maxHeight, NIL))
         RETURN 0
      ENDIF
   ENDIF

   SWITCH msg

   CASE WM_NOTIFY
      RETURN Eval({|o, w, l|onNotify(o, w, l)}, Self, wParam, lParam)

   CASE WM_PAINT
      RETURN Eval({|o, w|IIf(o:bPaint != NIL, Eval(o:bPaint, o, w), -1)}, Self, wParam, lParam)

   CASE WM_CTLCOLORSTATIC
   CASE WM_CTLCOLOREDIT
   CASE WM_CTLCOLORBTN
   CASE WM_CTLCOLORLISTBOX
      RETURN Eval({|o, w, l|onCtlColor(o, w, l)}, Self, wParam, lParam)

   CASE WM_COMMAND
      RETURN Eval({|o, w, l|onCommand(o, w, l)}, Self, wParam, lParam)

   CASE WM_DRAWITEM
      RETURN Eval({|o, w, l|onDrawItem(o, w, l)}, Self, wParam, lParam)

   CASE WM_SIZE
      RETURN Eval({|o, w, l|onSize(o, w, l)}, Self, wParam, lParam)

   CASE WM_DESTROY
      RETURN Eval({|o|onDestroy(o)}, Self, wParam, lParam)

#ifdef __XHARBOUR__
   DEFAULT
#else
   OTHERWISE
#endif
      IF ::bOther != NIL
         RETURN Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

   ENDSWITCH

   RETURN -1

METHOD END() CLASS HCustomWindow
LOCAL aControls, i, nLen

   IF ::nHolder != 0

      ::nHolder := 0
      hwg_DecreaseHolders(::handle) // Self)
      aControls := ::aControls
      nLen := Len(aControls)
      FOR i := 1 TO nLen
          aControls[i]:End()
      NEXT
   ENDIF

   RETURN NIL


METHOD Refresh(lAll, oCtrl) CLASS HCustomWindow
   LOCAL nlen, i, hCtrl := hwg_Getfocus(), oCtrlTmp, lRefresh

	 oCtrl := IIF(oCtrl == Nil, Self, oCtrl)
	 lAll  := IIF(lAll  == Nil, .F., lAll)
	 nLen  := LEN(oCtrl:aControls)

   IF hwg_Iswindowvisible(::Handle) .OR. nLen > 0
      FOR i = 1 to nLen
         oCtrlTmp := oCtrl:aControls[i]
         lRefresh := !Empty(__ObjHasMethod(oCtrlTmp, "REFRESH"))
         IF ((oCtrlTmp:Handle != hCtrl .OR. LEN(oCtrlTmp:aControls) = 0) .OR. lAll) .AND. ;
            (!oCtrlTmp:lHide .OR. __ObjHasMsg(oCtrlTmp, "BSETGET"))
  	        IF LEN(oCtrlTmp:aControls) > 0
  	            ::Refresh(lAll, oCtrlTmp)
		        ELSEIF !Empty(lRefresh) .AND. (lAll .OR. ASCAN(::GetList, {|o|o:Handle == oCtrlTmp:handle}) > 0)
               oCtrlTmp:Refresh()
               IF oCtrlTmp:bRefresh != Nil  
                  EVAL(oCtrlTmp:bRefresh, oCtrlTmp)
               ENDIF   
            ELSEIF hwg_Iswindowenabled(oCtrlTmp:Handle) .AND. !oCtrlTmp:lHide .AND. !lRefresh
               oCtrlTmp:SHOW(SW_SHOWNOACTIVATE)
				    ENDIF  
         ENDIF
      NEXT
      IF oCtrl:bRefresh != Nil .AND. oCtrl:handle != hCtrl
         Eval(oCtrl:bRefresh, Self)
      ENDIF
   ELSEIF oCtrl:bRefresh != Nil
      Eval(oCtrl:bRefresh, Self)
   ENDIF  
   RETURN Nil


METHOD SetTextClass(x) CLASS HCustomWindow

   IF __ObjHasMsg(Self, "SETVALUE") .AND. ::winClass != "STATIC" .AND. ::winclass != "BUTTON" 
   ELSEIF __ObjHasMsg(Self, "SETTEXT")
      ::SetText(x)
   ELSE
      ::title := x
      hwg_Sendmessage(::handle, WM_SETTEXT, 0, ::Title)
   ENDIF
   RETURN NIL

METHOD SetColor(tcolor, bColor, lRepaint) CLASS HCustomWindow

   IF tcolor != NIL
      ::tcolor := tcolor
      IF bColor == NIL .AND. ::bColor == NIL
         bColor := hwg_Getsyscolor(COLOR_3DFACE)
      ENDIF
   ENDIF

   IF bColor != NIL
      ::bColor := bColor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add(bColor)
   ENDIF

   IF lRepaint != NIL .AND. lRepaint
      hwg_Redrawwindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF
   RETURN Nil

METHOD Anchor(oCtrl, x, y, w, h) CLASS HCustomWindow
   LOCAL nlen, i, x1, y1

   IF oCtrl = Nil .OR.;
       ASCAN(oCtrl:aControls, {|o|__ObjHasMsg(o, "ANCHOR") .AND. o:Anchor > 0}) = 0
      RETURN .F.
   ENDIF

   nlen := Len(oCtrl:aControls)
   FOR i = nLen TO 1 STEP -1
      IF __ObjHasMsg(oCtrl:aControls[i], "ANCHOR") .AND. oCtrl:aControls[i]:anchor > 0
         x1 := oCtrl:aControls[i]:nWidth
         y1 := oCtrl:aControls[i]:nHeight
         oCtrl:aControls[i]:onAnchor(x, y, w, h)
         IF Len(oCtrl:aControls[i]:aControls) > 0
            ::Anchor(oCtrl:aControls[i], x1, y1, oCtrl:aControls[i]:nWidth, oCtrl:aControls[i]:nHeight)
         ENDIF
      ENDIF
   NEXT
   RETURN .T.

METHOD Closable(lClosable) CLASS HCustomWindow
   Local hMenu

   IF lClosable != Nil
      IF !lClosable
         hMenu := hwg_Enablemenusystemitem(::Handle, SC_CLOSE, .F.)
      ELSE
         hMenu := hwg_Enablemenusystemitem(::Handle, SC_CLOSE, .T.)
      ENDIF
      IF !EMPTY(hMenu)
         ::lClosable := lClosable
      ENDIF
   ENDIF
   RETURN ::lClosable

STATIC FUNCTION onNotify(oWnd, wParam, lParam)
   LOCAL iItem, oCtrl := oWnd:FindControl(wParam), nCode, res
   LOCAL n

   IF oCtrl == NIL
      FOR n := 1 TO Len(oWnd:aControls)
         oCtrl := oWnd:aControls[n]:FindControl(wParam)
         IF oCtrl != NIL
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF oCtrl != NIL .AND. VALTYPE(oCtrl) != "N"

      IF __ObjHasMsg(oCtrl, "NOTIFY")
         RETURN oCtrl:Notify(lParam)
      ELSE
         nCode := hwg_Getnotifycode(lParam)
         IF nCode == EN_PROTECTED
            RETURN 1
         ELSEIF oWnd:aNotify != NIL .AND. !oWnd:lSuspendMsgsHandling .AND. ;
            (iItem := AScan(oWnd:aNotify, {|a|a[1] == nCode .AND. ;
                                              a[2] == wParam})) > 0
            IF (res := Eval(oWnd:aNotify[iItem, 3], oWnd, wParam)) != NIL
               RETURN res
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN - 1

STATIC FUNCTION onDestroy(oWnd)
   LOCAL aControls := oWnd:aControls
   LOCAL i, nLen   := Len(aControls)

   FOR i := 1 TO nLen
      aControls[i]:END()
   NEXT
   nLen := Len(oWnd:aObjects)
   FOR i := 1 TO nLen
      IF hwg_Selffocus(oWnd:Handle, oWnd:aObjects[i]:oParent:Handle)
         oWnd:aObjects[i]:END()
      ENDIF
   NEXT
   oWnd:END()

   RETURN 1


STATIC FUNCTION onCtlColor(oWnd, wParam, lParam)
   LOCAL oCtrl
   oCtrl := oWnd:FindControl(, lParam)

   IF oCtrl != Nil .AND. VALTYPE(oCtrl) != "N"
      IF oCtrl:tcolor != NIL
         hwg_Settextcolor(wParam, oCtrl:tcolor)
      ENDIF
      hwg_Setbkmode(wParam, oCtrl:backstyle)
      IF !oCtrl:IsEnabled() .AND. oCtrl:Disablebrush != Nil
         hwg_Setbkmode(wParam, TRANSPARENT)
         hwg_Setbkcolor(wParam, oCtrl:DisablebColor)
         RETURN oCtrl:disablebrush:handle
      ELSEIF oCtrl:bcolor != NIL .AND. oCtrl:BackStyle = OPAQUE
         hwg_Setbkcolor(wParam, oCtrl:bcolor)
         IF oCtrl:brush != Nil
            RETURN oCtrl:brush:handle
         ELSEIF oCtrl:oParent:brush != Nil
            RETURN oCtrl:oParent:brush:handle
         ENDIF
      ELSEIF oCtrl:BackStyle = TRANSPARENT
         IF __ObjHasMsg(oCtrl, "PAINT") .OR. oCtrl:lnoThemes .OR. (oCtrl:winClass == "BUTTON" .AND. oCtrl:classname != "HCHECKBUTTON")
            RETURN hwg_Getstockobject(NULL_BRUSH)
         ENDIF
         RETURN hwg_GetBackColorParent(oCtrl, , .T.):handle
      ELSEIF oCtrl:winClass == "BUTTON" .AND. (hwg_Isthemeactive() .AND. oCtrl:WindowsManifest)
         RETURN hwg_GetBackColorParent(oCtrl, , .T.):handle
      ENDIF
   ENDIF

   RETURN - 1

STATIC FUNCTION onDrawItem(oWnd, wParam, lParam)
   LOCAL oCtrl
   IF !EMPTY(wParam) .AND. (oCtrl := oWnd:FindControl(wParam)) != NIL .AND. ;
                 VALTYPE(oCtrl) != "N" .AND. oCtrl:bPaint != NIL
      Eval(oCtrl:bPaint, oCtrl, lParam)
      RETURN 1

   ENDIF

   RETURN - 1

STATIC FUNCTION onCommand(oWnd, wParam, lParam)
   LOCAL iItem, iParHigh := hwg_Hiword(wParam), iParLow := hwg_Loword(wParam)
   LOCAL oForm := hwg_GetParentForm(oWnd)

   HB_SYMBOL_UNUSED(lParam)
   IF oWnd:aEvents != NIL .AND. !oForm:lSuspendMsgsHandling .AND. !oWnd:lSuspendMsgsHandling .AND. ;
      (iItem := AScan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. ;
                                        a[2] == iParLow})) > 0
      IF oForm:Type < WND_DLG_RESOURCE .AND. !Empty(oForm:nFocus)
         oForm:nFocus := IIF(hwg_Selffocus(hwg_Getparent(hwg_Getfocus()), oForm:Handle), hwg_Getfocus(), oForm:nFocus)
      ENDIF
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
      IF oForm:Type < WND_DLG_RESOURCE .AND. oForm:FindControl(, hwg_Getfocus()) = Nil .AND. ;
         !Empty(oForm:nFocus) .AND. !hwg_Selffocus(hwg_Getactivewindow())
         hwg_Setfocus(oForm:nFocus)
      ENDIF
   ENDIF

   RETURN 1

STATIC FUNCTION onSize(oWnd, wParam, lParam)
   LOCAL aControls := oWnd:aControls
   LOCAL oItem, nw1, nh1, aCoors, nWindowState
   
   nw1 := oWnd:nWidth
   nh1 := oWnd:nHeight
   aCoors := hwg_Getwindowrect(oWnd:handle)
   IF EMPTY(oWnd:Type)
      oWnd:nWidth  := aCoors[3] - aCoors[1]
      oWnd:nHeight := aCoors[4] - aCoors[2]
   ELSE
      nWindowState := oWnd:WindowState
      IF wParam != 1 .AND. (oWnd:GETMDIMAIN() != Nil .AND. !oWnd:GETMDIMAIN():IsMinimized()) //SIZE_MINIMIZED
         oWnd:nWidth  := aCoors[3] - aCoors[1]
         oWnd:nHeight := aCoors[4] - aCoors[2]
         IF oWnd:Type = WND_MDICHILD .AND. oWnd:GETMDIMAIN() != Nil .AND. wParam != 1 .AND. oWnd:GETMDIMAIN():WindowState = 2
             nWindowState := SW_SHOWMINIMIZED
         ENDIF 
      ENDIF
   ENDIF
   IF oWnd:nScrollBars > - 1 .AND. oWnd:lAutoScroll .AND. !EMPTY(oWnd:Type)
      hwg_onMove(oWnd)
      oWnd:ResetScrollbars()
      oWnd:SetupScrollbars()
   ENDIF
   IF wParam != 1 .AND. nWindowState != 2
      IF !EMPTY(oWnd:Type) .AND. oWnd:Type = WND_MDI .AND. !EMPTY(oWnd:Screen)
         oWnd:Anchor(oWnd:Screen, nw1, nh1, oWnd:nWidth, oWnd:nHeight)
      ENDIF
      IF !EMPTY(oWnd:Type)
         oWnd:Anchor(oWnd, nw1, nh1, oWnd:nWidth, oWnd:nHeight)
      ENDIF
   ENDIF

   FOR EACH oItem IN aControls
      IF oItem:bSize != NIL
         Eval(oItem:bSize, oItem, hwg_Loword(lParam), hwg_Hiword(lParam))
      ENDIF
   NEXT
   RETURN - 1

FUNCTION hwg_onTrackScroll(oWnd, msg, wParam, lParam)

   LOCAL oCtrl := oWnd:FindControl(, lParam)

   IF oCtrl != NIL
      msg := hwg_Loword(wParam)
      IF msg == TB_ENDTRACK
         IF __ObjHasMsg(oCtrl, "BCHANGE") .AND. ISBLOCK(oCtrl:bChange)
            Eval(oCtrl:bChange, oCtrl)
            RETURN 0
         ENDIF
      ELSEIF msg == TB_THUMBTRACK .OR. ;
         msg == TB_PAGEUP .OR. ;
         msg == TB_PAGEDOWN

         IF __ObjHasMsg(oCtrl, "BTHUMBDRAG") .AND. ISBLOCK(oCtrl:bThumbDrag)
            Eval(oCtrl:bThumbDrag, oCtrl)
            RETURN 0
         ENDIF
      ENDIF
   ELSE
      IF ISBLOCK(oWnd:bScroll)
         Eval(oWnd:bScroll, oWnd, msg, wParam, lParam)
         RETURN 0
      ENDIF
   ENDIF

   RETURN - 1
