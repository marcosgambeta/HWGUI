/*
 * $Id: htool.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 *
 *
 * Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
 * www - http://sites.uol.com.br/culikr/
*/
#include "windows.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define TRANSPARENT 1
#DEFINE IDTOOLBAR 700
#DEFINE IDMAXBUTTONTOOLBAR 64

CLASS HToolButton INHERIT HObject

   DATA Name
   DATA id
   DATA nBitIp INIT -1
   DATA bState INIT TBSTATE_ENABLED
   DATA bStyle INIT  0x0000
   DATA tooltip
   DATA aMenu INIT {}
   DATA hMenu
   DATA Title 
   DATA lEnabled  INIT .T. HIDDEN
   DATA lChecked  INIT .F. HIDDEN
   DATA lPressed  INIT .F. HIDDEN
   DATA bClick
   DATA oParent
   //DATA oFont   // not implemented

   METHOD New(oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu )
   METHOD Enable() INLINE ::oParent:EnableButton(::id, .T.)
   METHOD Disable() INLINE ::oParent:EnableButton(::id, .F.)
   METHOD Show() INLINE hwg_Sendmessage(::oParent:handle, TB_HIDEBUTTON, INT(::id), hwg_Makelong(0, 0))
   METHOD Hide() INLINE hwg_Sendmessage(::oParent:handle, TB_HIDEBUTTON, INT(::id), hwg_Makelong(1, 0))
   METHOD Enabled(lEnabled) SETGET
   METHOD Checked(lCheck) SETGET
   METHOD Pressed(lPressed) SETGET
   METHOD onClick()
   METHOD Caption(cText) SETGET

ENDCLASS

METHOD New(oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu) CLASS  HToolButton

   ::Name := cName
   ::iD := nId
   ::title  := cText
   ::nBitIp := nBitIp
   ::bState := bState
   ::bStyle := bStyle
   ::tooltip := ctip
   ::bClick  := bClick
   ::aMenu := amenu
    ::oParent := oParent
     __objAddData(::oParent, cName)
    ::oParent:&(cName) := Self
    
  //  ::oParent:oParent:AddEvent(BN_CLICKED, Self, {|| ::ONCLICK()},, "click")

RETURN Self

METHOD Caption(cText)  CLASS HToolButton
   IF cText != Nil 
      ::Title := cText
      hwg_Toolbar_setbuttoninfo(::oParent:handle, ::id, cText)
   ENDIF
   RETURN ::Title

METHOD onClick()  CLASS HToolButton
  IF ::bClick != Nil
      Eval(::bClick, self, ::id)
   ENDIF
RETURN Nil

 METHOD Enabled(lEnabled) CLASS HToolButton
  IF lEnabled != Nil
     IF lEnabled
        ::enable()
     ELSE
        ::disable()
     ENDIF
     ::lEnabled := lEnabled
  ENDIF
  RETURN ::lEnabled

METHOD Pressed(lPressed) CLASS HToolButton
LOCAL nState

   IF lPressed != Nil
      nState := hwg_Sendmessage(::oParent:handle, TB_GETSTATE, INT(::id), 0)
      hwg_Sendmessage(::oParent:handle, TB_SETSTATE, INT(::id),;
        hwg_Makelong(IIF(lPressed, HWG_BITOR(nState, TBSTATE_PRESSED), nState - HWG_BITAND(nState, TBSTATE_PRESSED)), 0))
      ::lPressed := lPressed
   ENDIF
   RETURN ::lPressed

METHOD Checked(lcheck) CLASS HToolButton
LOCAL nState

   IF lCheck != Nil
      nState := hwg_Sendmessage(::oParent:handle, TB_GETSTATE, INT(::id), 0)
      hwg_Sendmessage(::oParent:handle, TB_SETSTATE, INT(::id),;
        hwg_Makelong(IIF(lCheck, HWG_BITOR(nState, TBSTATE_CHECKED), nState - HWG_BITAND(nState, TBSTATE_CHECKED)), 0))
      ::lChecked := lCheck
   ENDIF
   RETURN ::lChecked


CLASS HToolBar INHERIT HControl

   DATA winclass INIT "ToolbarWindow32"
   DATA TEXT, id, nTop, nLeft, nwidth, nheight
   CLASSDATA oSelected INIT Nil
   DATA State INIT 0
   DATA ExStyle
   DATA bClick, cTooltip

   DATA lPress INIT .F.
   DATA lFlat
   DATA lTransp    INIT .F. //
   DATA lVertical  INIT .F. //
   DATA lCreate    INIT .F. HIDDEN
   DATA lResource  INIT .F. HIDDEN
   DATA nOrder
   DATA BtnWidth, BtnHeight
   DATA nIDB
   DATA aButtons    INIT {}
   DATA aSeparators INIT {}
   Data aItem       INIT {}
   DATA Line
   DATA nIndent
   DATA nwSize, nHSize
   DATA nDrop

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, btnWidth, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem, nWSize, nHSize, nIndent, nIDB)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                   bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)

   METHOD Activate()
   METHOD INIT()
   METHOD CreateTool()
   METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu, cName, nIndex)
   METHOD Notify(lParam)
   METHOD EnableButton(idButton, lEnable) INLINE hwg_Sendmessage(::handle, TB_ENABLEBUTTON, INT(idButton), hwg_Makelong(IIF(lEnable, 1, 0), 0))
   METHOD ShowButton(idButton) INLINE hwg_Sendmessage(::handle, TB_HIDEBUTTON, INT(idButton), hwg_Makelong(0, 0))
   METHOD HideButton(idButton) INLINE hwg_Sendmessage(::handle, TB_HIDEBUTTON, INT(idButton), hwg_Makelong(1, 0))
   METHOD REFRESH() VIRTUAL
   METHOD RESIZE(xIncrSize, lWidth, lHeight)
   METHOD onAnchor(x, y, w, h)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, btnWidth, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, lVertical, aItem, nWSize, nHSize, nIndent, nIDB) CLASS hToolBar

   //HB_SYMBOL_UNUSED(cCaption)
   //HB_SYMBOL_UNUSED(lTransp)

   DEFAULT  aitem TO { }

   //nStyle := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), TBSTYLE_FLAT)
   nStyle := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), IIF(Hwg_BitAnd(nStyle, WS_DLGFRAME + WS_BORDER) > 0, CCS_NODIVIDER, 0))
   nHeight += IIF(Hwg_BitAnd(nStyle, WS_DLGFRAME + WS_BORDER) > 0, 1, 0)
   nWidth  -= IIF(Hwg_BitAnd(nStyle, WS_DLGFRAME + WS_BORDER) > 0, 2, 0)

   ::lTransp := IIF(lTransp != NIL, lTransp, .F.)
   ::lVertical := IIF(lVertical != NIL .AND. VALTYPE(lVertical) = "L", lVertical, ::lVertical)
   IF ::lTransp  .OR. ::lVertical
      nStyle += IIF(::lTransp, TBSTYLE_TRANSPARENT, IIF(::lVertical, CCS_VERT, 0))
   ENDIF

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)

   ::BtnWidth :=  BtnWidth //!= Nil, BtnWidth, 32 )
   ::nIDB := nIDB
   ::aItem := aItem
   ::nIndent := IIF(nIndent != NIL, nIndent, 1)
   ::nwSize := IIF(nwSize != NIL .AND. nwSize > 11, nwSize, 16)
   ::nhSize := IIF(nhSize != NIL .AND. nhSize > 11, nhSize, ::nwSize - 1)
   ::lnoThemes := !hwg_Isthemeactive() .OR. !::WindowsManifest
   IF Hwg_BitAnd(::Style, WS_DLGFRAME + WS_BORDER + CCS_NODIVIDER) = 0
      IF !::lVertical
         ::Line := HLine():New(oWndParent,,, nLeft, nTop + nHeight + ;
                   IIF(::lnoThemes .AND. Hwg_BitAnd(nStyle, TBSTYLE_FLAT) > 0, 2, 1), nWidth)
      ELSE
         ::Line := HLine():New(oWndParent,,::lVertical, nLeft + nWidth + 1, nTop, nHeight )
      ENDIF
   ENDIF
   IF __ObjHasMsg(::oParent, "AOFFSET") .AND. ::oParent:type == WND_MDI .AND. ;
        ::oParent:aOffset[2] + ::oParent:aOffset[3] = 0
      IF ::nWidth > ::nHeight .OR. ::nWidth == 0
         ::oParent:aOffset[2] += ::nHeight
      ELSEIF ::nHeight > ::nWidth .OR. ::nHeight == 0
         IF ::nLeft == 0
            ::oParent:aOffset[1] += ::nWidth
         ELSE
            ::oParent:aOffset[3] += ::nWidth
         ENDIF
      ENDIF
   ENDIF

   ::extstyle:= TBSTYLE_EX_MIXEDBUTTONS 
   
   HWG_InitCommonControlsEx()
   
   ::Activate()

   RETURN Self


METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, ;
                bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aItem)  CLASS hToolBar

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   DEFAULT  aItem TO { }
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::aItem := aItem

   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::nIndent := 1
   ::lResource := .T.


   RETURN Self


METHOD Activate() CLASS hToolBar

   IF !Empty(::oParent:handle)
      ::lCreate := .T.
      ::handle := hwg_Createtoolbar(::oParent:handle, ::id, ;
                                 ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF
   RETURN Nil

METHOD INIT() CLASS hToolBar

   IF !::lInit
      IF ::Line != Nil
         ::Line:Anchor := ::Anchor
      ENDIF
      ::Super:Init()
      ::CreateTool()
   ENDIF

   RETURN Nil

METHOD CREATETOOL() CLASS hToolBar
   Local n, n1
   Local aTemp
   Local aButton :={}
   Local aBmpSize, hIm, nPos
   Local nMax := 0
   Local hImage, img, nlistimg, ndrop := 0

   IF !::lResource
      IF Empty(::handle)
         RETURN Nil
			   ENDIF
		   	IF !::lCreate
			      hwg_Destroywindow(::Handle)
			      ::Activate()
			      //IF !EMPTY(::oFont)
			      ::SetFont(::oFont)
			      //ENDIF
		    ENDIF
   ELSE
      FOR n = 1 TO Len(::aitem)
         ::AddButton(::aitem[n, 1],::aitem[n, 2],::aitem[n, 3],::aitem[n, 4],::aitem[n, 6], ::aitem[n, 7], ::aitem[n, 8], ::aitem[n, 9], , n )
         //::aItem[n, 11] := oButton
      NEXT
   ENDIF
     /*
     IF ::lVertical
        nStyle := hwg_Sendmessage(::handle, TB_GETSTYLE, 0, 0) + CCS_VERT
        hwg_Sendmessage(::handle, TB_SETSTYLE, 0, nStyle)
     ENDIF
     */
   nlistimg := 0
   IF ::nIDB != Nil .AND. ::nIDB >= 0
      nlistimg := hwg_Toolbar_loadstandartimage(::handle, ::nIDB)
   ENDIF
		 IF Hwg_BitAnd(::Style, TBSTYLE_LIST) > 0 .AND. ::nwSize = Nil
		    ::nwSize := MAX(16, (::nHeight - 16))
  	ENDIF
	  IF ::nwSize != Nil
	     hwg_Sendmessage(::HANDLE, TB_SETBITMAPSIZE, 0, hwg_Makelong(::nwSize, ::nhSize))
	  ENDIF

   FOR n := 1 TO Len(::aItem)
      IF ValType(::aItem[n, 7]) == "B"
          //::oParent:AddEvent(BN_CLICKED, ::aItem[n, 2], ::aItem[n, 7])
      ENDIF
      IF ValType(::aItem[n, 9]) == "A"
         ::aItem[n, 10] := hwg__CreatePopupMenu()
         ::aItem[n, 11]:hMenu := ::aItem[n, 10]
         aTemp := ::aItem[n, 9]

         FOR n1 := 1 TO Len(aTemp)
            aTemp[n1, 1] := IIF(aTemp[n1, 1] = "-", NIL, aTemp[n1, 1])
            hwg__AddMenuItem(::aItem[n, 10], aTemp[n1, 1], -1, .F., aTemp[n1, 2], , .F.)
            ::oParent:AddEvent(BN_CLICKED, aTemp[n1, 2], aTemp[n1, 3])
         NEXT
      ENDIF
			   IF ::aItem[n, 4] = BTNS_SEP
				     LOOP
				  ENDIF
				  nDrop := Max(nDrop, IIF(Hwg_Bitand(::aItem[n, 4], BTNS_WHOLEDROPDOWN) != 0, 0, ;
               IIF(Hwg_Bitand(::aItem[n, 4], BTNS_DROPDOWN ) != 0, 8, 0)))
				 /*
				 IF ::nSize != Nil
				    hwg_Sendmessage(::HANDLE, TB_SETBITMAPSIZE, 0, hwg_Makelong(::nSize, ::nSize))
				 ENDIF
         */
      IF ValType(::aItem[n, 1])  == "C" .OR. ::aItem[n, 1] > 1
         IF ValType(::aItem[n, 1])  == "C" .AND. At(".", ::aitem[n, 1] ) != 0
            IF !File(::aitem[n, 1])
               Loop
            ENDIF
               //AAdd(aButton, hwg_Loadimage(, ::aitem[n, 1], IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION+ LR_LOADFROMFILE))
            hImage := HBITMAP():AddFile(::aitem[n, 1], , .T., ::nwSize, ::nhSize):handle
         ELSE
              // AAdd(aButton, HBitmap():AddResource(::aitem[n, 1]):handle)
            hImage := HBitmap():AddResource(::aitem[n, 1], LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS, ,::nwSize,::nhSize):handle
         ENDIF
         IF (img := Ascan(aButton, hImage)) = 0
            AAdd(aButton, hImage)
            img := Len(aButton)
         ENDIF
         ::aItem[n, 1] := img + nlistimg //n
         IF !::lResource
            hwg_Toolbar_loadimage(::Handle, aButton[img])
         ENDIF
      ELSE
           /*
           IF ::aItem[n, 1] > 1
               hImage := HBitmap():AddResource(::aitem[n, 1], LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS,,::nSize,::nSize):handle
           ENDIF
           */
               // AAdd(aButton, hwg_Loadimage(, ::aitem[n, 1], IMAGE_BITMAP, 0, 0, LR_DEFAULTSIZE + LR_CREATEDIBSECTION))
           //  hImage := HBitmap():AddResource(::aitem[n, 1], LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS + LR_SHARED,,::nSize,::nSize):handle
      ENDIF
   NEXT
   IF Len(aButton) > 0 .AND. ::lResource
      aBmpSize := hwg_Getbitmapsize(aButton[1])
         /*
         nmax := aBmpSize[3]

         FOR n := 2 TO Len(aButton)
            aBmpSize := hwg_Getbitmapsize(aButton[n])
            nmax := Max(nmax, aBmpSize[3])
         NEXT
         aBmpSize := hwg_Getbitmapsize(aButton[1])

         IF nmax == 4
            hIm := hwg_Createimagelist({ }, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR4 + ILC_MASK)
         ELSEIF nmax == 8
            hIm := hwg_Createimagelist({ }, aBmpSize[1], aBmpSize[2], 1, ILC_COLOR8 + ILC_MASK)
         ELSEIF nMax == 16 //
             hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
         ELSEIF nmax == 24
            hIm := hwg_Createimagelist({ }, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
         ENDIF
         */
      hIm := hwg_Createimagelist({}, aBmpSize[1], aBmpSize[2], 1, ILC_COLORDDB + ILC_MASK)
      FOR nPos := 1 TO Len(aButton)

//            aBmpSize := hwg_Getbitmapsize(aButton[nPos])
            /*
            IF aBmpSize[3] == 24
//             hwg_Imagelist_addmasked(hIm, aButton[nPos], hwg_Rgb(236, 223, 216))
               hwg_Imagelist_add(hIm, aButton[nPos])
            ELSE
               hwg_Imagelist_add(hIm, aButton[nPos])
            ENDIF
            */
         hwg_Imagelist_add(hIm, aButton[nPos])
      NEXT
      hwg_Sendmessage(::Handle, TB_SETIMAGELIST, 0, hIm)
   ELSEIF Len(aButton ) = 0
      hwg_Sendmessage(::HANDLE, TB_SETBITMAPSIZE, 0, hwg_Makelong(0, 0))
          //hwg_Sendmessage(::handle, TB_SETDRAWTEXTFLAGS, DT_CENTER+DT_VCENTER, DT_CENTER+DT_VCENTER)
   ENDIF
   hwg_Sendmessage(::Handle, TB_SETINDENT, ::nIndent, 0)
   IF !Empty(::BtnWidth)
      hwg_Sendmessage(::Handle, TB_SETBUTTONWIDTH, 0, hwg_Makelparam(::BtnWidth -1, ::BtnWidth + 1))
         //hwg_Sendmessage(::Handle, TB_SETBUTTONWIDTH, hwg_Makelparam(::BtnWidth, ::BtnWidth))
   ENDIF
   IF Len(::aItem) > 0
      hwg_Toolbaraddbuttons(::handle, ::aItem, Len(::aItem))
      hwg_Sendmessage(::handle, TB_SETEXTENDEDSTYLE, 0, TBSTYLE_EX_DRAWDDARROWS)
   ENDIF
   IF ::BtnWidth != Nil
      IF Hwg_BitAnd(::Style, CCS_NODIVIDER) > 0
         nMax := IIF(Hwg_BitAnd(::Style, WS_DLGFRAME + WS_BORDER) > 0, 4, 2)
      ELSEIF Hwg_BitAnd(::Style, TBSTYLE_FLAT) > 0
         nMax := 2
      ENDIF
      ::ndrop := nMax + IIF(!::WindowsManifest, 0, nDrop)
      ::BtnHeight := MAX(hwg_Hiword(hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0)),;
                     ::nHeight - ::nDrop - IIF(!::lnoThemes .AND. Hwg_BitAnd(::Style, TBSTYLE_FLAT) > 0, 0, 2))
      IF  !::lVertical
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::BtnWidth, ::BtnHeight))
      ELSE
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::nWidth - ::nDrop - 1, ::BtnWidth))
      ENDIF
   ENDIF
   ::BtnWidth := hwg_Loword(hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0))
      /*
      IF ::lTransp
         nStyle := hwg_Sendmessage(::handle, TB_GETSTYLE, 0, 0) + TBSTYLE_TRANSPARENT
         hwg_Sendmessage(::handle, TB_SETSTYLE, 0, nStyle)
      ENDIF
      */

   RETURN Nil


METHOD Notify(lParam) CLASS hToolBar

   LOCAL nCode :=  hwg_Getnotifycode(lParam)
   LOCAL nId

   LOCAL nButton
   LOCAL nPos

   IF nCode == TTN_GETDISPINFO

      nButton := hwg_Toolbar_getdispinfoid(lParam)
      nPos := AScan(::aItem, { | x | x[2] == nButton })
      hwg_Toolbar_setdispinfo(lParam, ::aItem[nPos, 8])

   ELSEIF nCode == TBN_GETINFOTIP

      nId := hwg_Toolbar_getinfotipid(lParam)
      nPos := AScan(::aItem, { | x | x[2] == nId })
      hwg_Toolbar_getinfotip(lParam, ::aItem[nPos, 8])

   ELSEIF nCode == TBN_DROPDOWN
      nId := hwg_Toolbar_submenuexgetid(lParam)
      IF nId > 0 //valtype(::aItem[1, 9]) ="A"
//       nid := hwg_Toolbar_submenuexgetid(lParam)
         nPos := AScan(::aItem, { | x | x[2] == nId })
         hwg_Toolbar_submenuex(lParam, ::aItem[nPos, 10], ::oParent:handle)
      ELSE
         hwg_Toolbar_submenu(lParam, 1, ::oParent:handle)
      ENDIF
   elseif nCode == NM_CLICK
      nId := hwg_Toolbar_idclick(lParam)
      nPos := AScan(::aItem, { | x | x[2] == nId })
      if nPos > 0 .AND. ::aItem[nPos, 7] != NIL
         Eval(::aItem[nPos, 7], ::aItem[nPos, 11], nId)
      endif
   ENDIF

   RETURN 0

METHOD AddButton(nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu, cName, nIndex) CLASS hToolBar
   Local hMenu := Nil, oButton

   DEFAULT nBitIp to -1
   DEFAULT bstate to TBSTATE_ENABLED
   DEFAULT bstyle to 0x0000
   DEFAULT c to ""
   DEFAULT ctext to ""
   IF nId = Nil .OR. EMPTY(nId)
      //IDTOOLBAR
      nId := VAL(RIGHT(STR(::id, 6), 1)) * IDMAXBUTTONTOOLBAR
      nId := nId + ::id + IDTOOLBAR + LEN(::aButtons) + LEN(::aSeparators) + 1
   ENDIF

   IF bStyle != BTNS_SEP  //1
      DEFAULT cName to "oToolButton" + LTRIM(STR(LEN(::aButtons) + 1))
      AAdd(::aButtons,{ Alltrim(cName), nid })
   ELSE
      bstate :=  IIF(!(::lVertical .AND. LEN(::aButtons) = 0), bState, 8) //TBSTATE_HIDE
      DEFAULT nBitIp to 0
      DEFAULT cName to "oSeparator"+LTRIM(STR(LEN(::aSeparators) + 1))
      AAdd(::aSeparators,{ cName, nid })
      //bStyle := TBSTYLE_SEP //TBSTYLE_FLAT
   ENDIF

   oButton := HToolButton():New(Self, cName, nBitIp, nId, bState, bStyle, cText, bClick, c, aMenu)
   IF !::lResource
      AAdd(::aItem, { nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, oButton })
   ELSE
      ::aItem[nIndex] := { nBitIp, nId, bState, bStyle, 0, cText, bClick, c, aMenu, hMenu, oButton }
   Endif
   RETURN oButton

METHOD RESIZE(xIncrSize, lWidth, lHeight) CLASS hToolBar
   LOCAL nSize

   IF ::Anchor = 0 .OR. (!lWidth .AND. !lHeight)
      RETURN Nil
   ENDIF
   nSize := hwg_Sendmessage(::handle, TB_GETBUTTONSIZE, 0, 0)
   IF xIncrSize != 1
      ::Move(::nLeft, ::nTop, ::nWidth, ::nHeight, 0)
   ENDIF
   IF xIncrSize < 1 .OR. hwg_Loword(nSize) <= ::BtnWidth
      ::BtnWidth :=  ::BtnWidth  * xIncrSize
   ELSE
      ::BtnWidth :=  hwg_Loword(nSize) * xIncrSize
   ENDIF
   hwg_Sendmessage(::Handle, TB_SETBUTTONWIDTH, hwg_Makelparam(::BtnWidth - 1, ::BtnWidth + 1))
   IF ::BtnWidth != Nil
      IF  !::lVertical
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::BtnWidth, ::BtnHeight))
      ELSE
         hwg_Sendmessage(::handle, TB_SETBUTTONSIZE, 0, hwg_Makelparam(::nWidth - ::nDrop - 1, ::BtnWidth))
		    ENDIF
		    hwg_Sendmessage(::handle, WM_SIZE, 0, 0)
   ENDIF
   RETURN NIL

METHOD onAnchor(x, y, w, h) CLASS hToolBar

   IF ::Super:onAnchor(x, y, w, h)
      ::Resize(Iif(x > 0, w / x, 1), .T., .T.)
   ENDIF

   RETURN .T.


CLASS HToolBarEX INHERIT HToolBar

//method onevent()
   METHOD init()
   METHOD ExecuteTool(nid)
   DESTRUCTOR MyDestructor
END CLASS


METHOD init() CLASS htoolbarex
   ::Super:init()
   hwg_Setwindowobject(::handle, Self)
   hwg_Settoolhandle(::handle)
   hwg_Sethook()
   RETURN Self

METHOD ExecuteTool(nid) CLASS htoolbarex

   IF nid > 0
      hwg_Sendmessage(::oParent:handle, WM_COMMAND, hwg_Makewparam(nid, BN_CLICKED), ::handle)
      RETURN 0
   ENDIF
   RETURN - 200


PROCEDURE MyDestructor CLASS htoolbarex
   hwg_Unsethook()
   RETURN
