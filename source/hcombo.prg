/*
 * $Id: hcombo.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HCombo class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

CLASS HComboBox INHERIT HControl

   CLASS VAR winclass INIT "COMBOBOX"
   DATA aItems
   DATA aItemsBound
   DATA bSetGet
   DATA value INIT 1
   DATA valueBound INIT 1
   DATA cDisplayValue HIDDEN
   DATA columnBound INIT 1 HIDDEN
   DATA xrowsource INIT { , } HIDDEN

   DATA bChangeSel
   DATA bChangeInt
   DATA bValid
   DATA bSelect

   DATA lText INIT .F.
   DATA lEdit INIT .F.
   DATA SelLeght INIT 0
   DATA SelStart INIT 0
   DATA SelText INIT ""
   DATA nDisplay
   DATA nhItem
   DATA ncWidth
   DATA nHeightBox
   DATA lResource INIT .F.
   DATA ldropshow INIT .F.
   DATA nMaxLength     INIT Nil


   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
      aItems, oFont, bInit, bSize, bPaint, bChange, ctooltip, lEdit, lText, bGFocus, tcolor, ;
      bcolor, bLFocus, bIChange, nDisplay, nhItem, ncWidth, nMaxLength)
   METHOD Activate()
   METHOD Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, bChange, ctooltip, bGFocus, bLFocus, bIChange, nDisplay, nMaxLength, ledit, ltext)
   METHOD INIT()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Requery(aItems, xValue)
   METHOD Refresh()
   METHOD Setitem(nPos)
   METHOD SetValue(xItem)
   METHOD GetValue()
   METHOD AddItem(cItem, cItemBound, nPos)
   METHOD DeleteItem(xIndex)
   METHOD Valid()
   METHOD When()
   METHOD onSelect()
   METHOD InteractiveChange()
   METHOD onChange(lForce)
   METHOD Populate() HIDDEN
   METHOD GetValueBound(xItem)
   METHOD RowSource(xSource) SETGET
   METHOD DisplayValue(cValue) SETGET
   METHOD onDropDown() INLINE ::ldropshow := .T.
   METHOD SetCueBanner(cText, lShowFoco)
   METHOD MaxLength(nMaxLength) SETGET

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, ;
      bInit, bSize, bPaint, bChange, ctooltip, lEdit, lText, bGFocus, tcolor, bcolor, bLFocus, ;
      bIChange, nDisplay, nhItem, ncWidth, nMaxLength) CLASS HComboBox

   IF !Empty(nDisplay) .AND. nDisplay > 0
      nStyle := Hwg_BitOr(nStyle, CBS_NOINTEGRALHEIGHT + WS_VSCROLL)
      // CBS_NOINTEGRALHEIGHT. CRIATE VERTICAL SCROOL BAR
   ELSE
      nDisplay := 6
   ENDIF
   nHeight := iif(Empty(nHeight), 24, nHeight)
   ::nHeightBox := Int(nHeight * 0.75)                    //   Meets A 22'S EDITBOX
   nHeight := nHeight + (iif(Empty(nhItem), 16.250, (nhItem += 0.10)) * nDisplay)

   IF lEdit == Nil
      lEdit := .F.
   ENDIF

   nStyle := Hwg_BitOr(iif(nStyle == Nil, 0, nStyle), iif(lEdit, CBS_DROPDOWN, CBS_DROPDOWNLIST) + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)

   IF lText == Nil
      lText := .F.
   ENDIF

   ::nDisplay := nDisplay
   ::nhItem   := nhItem
   ::ncWidth  := ncWidth

   ::lEdit := lEdit
   ::lText := lText

   IF lEdit
      ::lText := .T.
      IF nMaxLength != Nil
         ::MaxLength := nMaxLength
      ENDIF
   ENDIF

   IF ::lText
      ::value := iif(vari == Nil .OR. ValType(vari) != "C", "", vari)
   ELSE
      ::value := iif(vari == Nil .OR. ValType(vari) != "N", 1, vari)
   ENDIF

   aItems        := iif(aItems = Nil, {}, AClone(aItems))
   ::RowSource(aItems)
   ::aItemsBound   := {}
   ::bSetGet       := bSetGet

   ::Activate()

   ::bChangeSel := bChange
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus

   IF bSetGet != Nil
      IF bGFocus != Nil
         ::lnoValid := .T.
         ::oParent:AddEvent(CBN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
      ENDIF
      // By Luiz Henrique dos Santos (luizhsantos@gmail.com) 03/06/2006
      ::oParent:AddEvent(CBN_KILLFOCUS, Self, {|o, id|::Valid(o:FindControl(id))}, .F. , "onLostFocus")
      //---------------------------------------------------------------------------
   ELSE
      IF bGFocus != Nil
         ::lnoValid := .T.
         ::oParent:AddEvent(CBN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
      ENDIF
      ::oParent:AddEvent(CBN_KILLFOCUS, Self, {|o, id|::Valid(o:FindControl(id))}, .F. , "onLostFocus")
   ENDIF
   IF bChange != Nil .OR. bSetGet != Nil
      ::oParent:AddEvent(CBN_SELCHANGE, Self, {|o, id|::onChange(o:FindControl(id))}, , "onChange")
   ENDIF

   IF bIChange != Nil .AND. ::lEdit
      ::bchangeInt := bIChange
      ::oParent:AddEvent(CBN_EDITUPDATE, Self, {|o, id|::InteractiveChange(o:FindControl(id))}, , "interactiveChange")
   ENDIF
   ::oParent:AddEvent(CBN_SELENDOK, Self, {|o, id|::onSelect(o:FindControl(id))}, , "onSelect")
   ::oParent:AddEvent(CBN_DROPDOWN, Self, {|o, id|::onDropDown(o:FindControl(id))}, , "ondropdown")
   ::oParent:AddEvent(CBN_CLOSEUP, Self, {||::ldropshow := .F.}, ,)

   RETURN Self

METHOD Activate() CLASS HComboBox

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createcombo(::oParent:handle, ::id, ;
         ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
      ::nHeight := Int(::nHeightBox / 0.75)
   ENDIF

   RETURN Nil

METHOD Redefine(oWndParent, nId, vari, bSetGet, aItems, oFont, bInit, bSize, bPaint, ;
      bChange, ctooltip, bGFocus, bLFocus, bIChange, nDisplay, nMaxLength, ledit, ltext) CLASS HComboBox

   HB_SYMBOL_UNUSED(bLFocus)
   IF lEdit == Nil
      lEdit := .F.
   ENDIF
   IF lText == Nil
      lText := .F.
   ENDIF

   ::lEdit := lEdit
   ::lText := lText

   IF !Empty(nDisplay) .AND. nDisplay > 0
      ::Style := Hwg_BitOr(::Style, CBS_NOINTEGRALHEIGHT)
   ELSE
      nDisplay := 6
   ENDIF
   ::lResource := .T.
   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip)

   ::nDisplay := nDisplay

   IF ::lText
      ::value := iif(vari == Nil .OR. ValType(vari) != "C", "", vari)
   ELSE
      ::value := iif(vari == Nil .OR. ValType(vari) != "N", 1, vari)
   ENDIF
   IF nMaxLength != Nil
      ::MaxLength := nMaxLength
   ENDIF

   aItems        := iif(aItems = Nil, {}, AClone(aItems))
   ::RowSource(aItems)
   ::aItemsBound   := {}
   ::bSetGet := bSetGet


   IF bSetGet != Nil
      ::bChangeSel := bChange
      ::bGetFocus  := bGFocus
      ::oParent:AddEvent(CBN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
      // By Luiz Henrique dos Santos (luizhsantos@gmail.com) 04/06/2006
      IF ::bSetGet != NIL
         ::oParent:AddEvent(CBN_SELCHANGE, Self, {|o, id|::Valid(o:FindControl(id))}, , "onChange")
      ELSEIF ::bChangeSel != NIL
         ::oParent:AddEvent(CBN_SELCHANGE, Self, {|o, id|::Valid(o:FindControl(id))}, , "onChange")
      ENDIF
   ELSEIF bChange != Nil .AND. ::lEdit
      ::bChangeSel := bChange
      ::oParent:AddEvent(CBN_SELCHANGE, Self, {|o, id|::onChange(o:FindControl(id))}, , "onChange")
   ENDIF

   IF bGFocus != Nil .AND. bSetGet == Nil
      ::oParent:AddEvent(CBN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))}, , "onGotFocus")
   ENDIF
   IF bIChange != Nil .AND. ::lEdit
      ::bchangeInt := bIChange
      ::oParent:AddEvent(CBN_EDITUPDATE, Self, {|o, id|::InteractiveChange(o:FindControl(id))}, , "interactiveChange")
   ENDIF

   ::oParent:AddEvent(CBN_SELENDOK, Self, {|o, id|::onSelect(o:FindControl(id))}, , "onSelect")
   //::Refresh() // By Luiz Henrique dos Santos
   ::oParent:AddEvent(CBN_DROPDOWN, Self, {|o, id|::onDropDown(o:FindControl(id))}, , "ondropdown")
   ::oParent:AddEvent(CBN_CLOSEUP, Self, {||::ldropshow := .F.}, ,)

   RETURN Self

METHOD INIT() CLASS HComboBox

   LOCAL LongComboWidth
   LOCAL NewLongComboWidth, avgWidth, nHeightBox

   IF !::lInit
      ::nHolder := 1
      hwg_Setwindowobject(::handle, Self)
      HWG_INITCOMBOPROC(::handle)
      IF ::aItems != Nil .AND. !Empty(::aItems)
         ::RowSource(::aItems)
         LongComboWidth := ::Populate()
         //
         IF ::lText
            IF ::lEdit
               hwg_Setdlgitemtext(hwg_GetModalHandle(), ::id, ::value)
               hwg_Sendmessage(::handle, CB_SELECTSTRING, -1, ::value)
               hwg_Sendmessage(::handle, CB_SETEDITSEL, -1, 0)
            ELSE
               hwg_Combosetstring(::handle, AScan(::aItems, ::value, , , .T.))
            ENDIF
            hwg_Setwindowtext(::handle, ::value)
         ELSE
            hwg_Combosetstring(::handle, ::value)
         ENDIF
         avgwidth          := hwg_Getfontdialogunits(::oParent:handle) + 0.75
         NewLongComboWidth := (LongComboWidth - 2) * avgwidth
         hwg_Sendmessage(::handle, CB_SETDROPPEDWIDTH, NewLongComboWidth + 50, 0)
      ENDIF
      ::Super:Init()
      IF !::lResource
         // HEIGHT Items
         IF !Empty(::nhItem)
            hwg_Sendmessage(::handle, CB_SETITEMHEIGHT, 0, ::nhItem + 0.10)
         ELSE
            ::nhItem := hwg_Sendmessage(::handle, CB_GETITEMHEIGHT, 0, 0) + 0.10
         ENDIF
         nHeightBox := hwg_Sendmessage(::handle, CB_GETITEMHEIGHT, -1, 0) //+ 0.750
         //  WIDTH  Items
         IF !Empty(::ncWidth)
            hwg_Sendmessage(::handle, CB_SETDROPPEDWIDTH, ::ncWidth, 0)
         ENDIF
         ::nHeight := Int(nHeightBox / 0.75 + (::nhItem * ::nDisplay)) + 3
      ENDIF
   ENDIF
   IF !::lResource
      hwg_Movewindow(::handle, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      // HEIGHT COMBOBOX
      hwg_Sendmessage(::handle, CB_SETITEMHEIGHT, -1, ::nHeightBox)
   ENDIF
   ::Refresh()
   IF ::lEdit
      hwg_Sendmessage(::handle, CB_SETEDITSEL, -1, 0)
      hwg_Sendmessage(::handle, WM_SETREDRAW, 1, 0)
   ENDIF

   RETURN Nil

METHOD onEvent(msg, wParam, lParam) CLASS HComboBox
   LOCAL oCtrl

   IF ::bOther != Nil
      IF Eval(::bOther, Self, msg, wParam, lParam) != - 1
         RETURN 0
      ENDIF
   ENDIF
   IF msg = WM_MOUSEWHEEL .AND. ::oParent:nScrollBars != - 1 .AND. ::oParent:bScroll = Nil
      hwg_ScrollHV(::oParent, msg, wParam, lParam)
      RETURN 0
   ELSEIF msg = CB_SHOWDROPDOWN
      ::ldropshow := iif(wParam = 1, .T., ::ldropshow)
   ENDIF

   IF ::bSetGet != Nil .OR. hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE
      IF msg == WM_CHAR .AND. (hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE .OR. ;
            !hwg_GetParentForm(Self) :lModal)
         IF wParam = VK_TAB
            hwg_GetSkip(::oParent, ::handle, , iif(hwg_IsCtrlShift(.F., .T.), -1, 1))
            RETURN 0
         ELSEIF wParam == VK_RETURN .AND. ;
               !hwg_ProcOkCancel(Self, wParam, hwg_GetParentForm(Self):Type >= WND_DLG_RESOURCE) .AND. ;
               (hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE .OR. ;
               !hwg_GetParentForm(Self):lModal)
            hwg_GetSkip(::oParent, ::handle, , 1)
            RETURN 0
         ENDIF
      ELSEIF msg == WM_GETDLGCODE
         IF wParam = VK_RETURN
            RETURN DLGC_WANTMESSAGE
         ELSEIF wParam = VK_ESCAPE .AND. ;
               (oCtrl := hwg_GetParentForm(Self):FindControl(IDCANCEL)) != Nil .AND. !oCtrl:IsEnabled()
            RETURN DLGC_WANTMESSAGE
         ENDIF
         RETURN  DLGC_WANTCHARS + DLGC_WANTARROWS

      ELSEIF msg = WM_KEYDOWN
         IF wparam = VK_RIGHT .OR. wParam == VK_RETURN //.AND. !::lEdit
            hwg_GetSkip(::oParent, ::handle, , 1)
            RETURN 0
         ELSEIF wparam = VK_LEFT //.AND. !::lEdit
            hwg_GetSkip(::oParent, ::handle, , -1)
            RETURN 0
         ELSEIF wParam = VK_ESCAPE .AND. hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE //.OR.;
            RETURN 0
         ENDIF

      ELSEIF msg = WM_KEYUP
         hwg_ProcKeyList(Self, wParam)        //working in MDICHILD AND DIALOG
      ELSEIF msg = WM_COMMAND .AND. ::lEdit .AND. !::ldropshow
         IF hwg_Getkeystate(VK_DOWN) + hwg_Getkeystate(VK_UP) < 0 .AND. hwg_Getkeystate(VK_SHIFT) > 0 .AND. hwg_Hiword(wParam) = 1
            RETURN 0
         ENDIF
      ELSEIF msg = CB_GETDROPPEDSTATE .AND. !::ldropshow
         IF hwg_Getkeystate(VK_RETURN) < 0
            ::GetValue()
         ENDIF
         IF (hwg_Getkeystate(VK_RETURN) < 0 .OR. hwg_Getkeystate(VK_ESCAPE) < 0) .AND. (hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE .OR. ;
               !hwg_GetParentForm(Self):lModal)
            hwg_ProcOkCancel(Self, iif(hwg_Getkeystate(VK_RETURN) < 0, VK_RETURN, VK_ESCAPE))
         ENDIF
         IF hwg_Getkeystate(VK_TAB) + hwg_Getkeystate(VK_DOWN) < 0 .AND. hwg_Getkeystate(VK_SHIFT) > 0
            IF ::oParent:oParent = Nil
               //  hwg_GetSkip(::oParent, hwg_Getancestor(::handle, GA_PARENT),, 1)
            ENDIF
            hwg_GetSkip(::oParent, ::handle, , 1)
            RETURN 0
         ELSEIF hwg_Getkeystate(VK_UP) < 0 .AND. hwg_Getkeystate(VK_SHIFT) > 0
            IF ::oParent:oParent = Nil
               //  hwg_GetSkip(::oParent, hwg_Getancestor(::handle, GA_PARENT),, 1)
            ENDIF
            hwg_GetSkip(::oParent, ::handle, , -1)
            RETURN 0
         ENDIF
         IF (hwg_GetParentForm(Self):Type < WND_DLG_RESOURCE .OR. !hwg_GetParentForm(Self):lModal)
            RETURN 1
         ENDIF
      ENDIF
   ENDIF

   RETURN - 1

METHOD MaxLength(nMaxLength) CLASS HComboBox

   IF nMaxLength != Nil .AND. ::lEdit
      hwg_Sendmessage(::handle, CB_LIMITTEXT, nMaxLength, 0)
      ::nMaxLength := nMaxLength
   ENDIF

   RETURN ::nMaxLength

METHOD Requery(aItems, xValue) CLASS HComboBox

   hwg_Sendmessage(::handle, CB_RESETCONTENT, 0, 0)
   IF aItems != Nil
      ::aItems := aItems
   ENDIF
   ::Populate()
   IF xValue != Nil
      ::SetValue(xValue)
   ELSEIF Empty(::Value) .AND. Len(::aItems) > 0 .AND. ::bSetGet = Nil .AND. !::lEdit
      ::SetItem(1)
   ENDIF

   RETURN Nil

METHOD Refresh() CLASS HComboBox
   LOCAL vari

   IF ::bSetGet != Nil
      vari := Eval(::bSetGet, , Self)
      IF ::columnBound = 2
         vari := ::GetValueBound(vari)
      ENDIF
      IF ::columnBound = 1
         IF ::lText
            ::value := iif(vari == Nil .OR. ValType(vari) != "C", "", vari)
         ELSE
            ::value := iif(vari == Nil .OR. ValType(vari) != "N", 1, vari)
         ENDIF
      ENDIF
   ENDIF

   IF ::lText
      IF ::lEdit
         hwg_Setdlgitemtext(hwg_GetModalHandle(), ::id, ::value)
         hwg_Sendmessage(::handle, CB_SETEDITSEL, 0, ::SelStart)
      ENDIF
      hwg_Combosetstring(::handle, AScan(::aItems, ::value, , , .T.))
   ELSE
      hwg_Combosetstring(::handle, ::value)
   ENDIF
   ::valueBound := ::GetValueBound()

   RETURN Nil

METHOD SetItem(nPos) CLASS HComboBox

   IF ::lText
      IF nPos > 0
         ::value := ::aItems[nPos]
         ::ValueBound := ::GetValueBound()
      ELSE
         ::value := ""
         ::valueBound := iif(::bSetGet != Nil, Eval(::bSetGet, , Self), ::valueBound)
      ENDIF
   ELSE
      ::value := nPos
      ::ValueBound := ::GetValueBound()
   ENDIF

   hwg_Combosetstring(::handle, nPos)

   IF ::bSetGet != Nil
      IF ::columnBound = 1
         Eval(::bSetGet, ::value, Self)
      ELSE
         Eval(::bSetGet, ::valuebound, Self)
      ENDIF
   ENDIF

   RETURN Nil

METHOD SetValue(xItem) CLASS HComboBox
   LOCAL nPos

   IF ::lText .AND. HB_ISCHAR(xItem)
      IF ::columnBound = 2
         nPos := AScan(::aItemsBound, xItem)
      ELSE
         nPos := AScan(::aItems, xItem)
      ENDIF
      hwg_Combosetstring(::handle, nPos)
   ELSE
      nPos := iif(::columnBound = 2, AScan(::aItemsBound, xItem), xItem)
   ENDIF
   ::setItem(nPos)

   RETURN Nil

METHOD GetValue() CLASS HComboBox
   LOCAL nPos := hwg_Sendmessage(::handle, CB_GETCURSEL, 0, 0) + 1

   IF ::lText
      IF (::lEdit .OR. ValType(::Value) != "C") .AND. nPos <= 1
         ::Value := hwg_Getwindowtext(::handle)
         nPos := hwg_Sendmessage(::handle, CB_FINDSTRINGEXACT, -1, ::value) + 1
      ELSEIF nPos > 0
         ::value := ::aItems[nPos]
      ENDIF
      ::cDisplayValue := ::Value
      ::value := iif(nPos > 0, ::aItems[nPos], iif(::lEdit, "", ::value))
   ELSE
      ::value := nPos
   ENDIF
   ::ValueBound := iif(nPos > 0, ::GetValueBound(), ::ValueBound) // IIF(::lText, "", 0))
   IF ::bSetGet != Nil
      IF ::columnBound = 1
         Eval(::bSetGet, ::value, Self)
      ELSE
         Eval(::bSetGet, ::ValueBound, Self)
      ENDIF
   ENDIF

   RETURN ::value

METHOD GetValueBound(xItem) CLASS HComboBox
   LOCAL nPos := hwg_Sendmessage(::handle, CB_GETCURSEL, 0, 0) + 1

   IF ::columnBound = 1
      RETURN Nil
   ENDIF
   IF xItem = Nil
      IF ::lText
         nPos := iif(::Value = Nil, 0, AScan(::aItems, ::value, , , .T.))
      ENDIF
   ELSE
      nPos := AScan(::aItemsBound, xItem, , , .T.)
      ::setItem(nPos)
      RETURN iif(nPos > 0, ::aItems[nPos], xItem)
   ENDIF
   IF nPos > 0 .AND. nPos <= Len(::aItemsBound)
      ::ValueBound := ::aItemsBound[nPos]
   ENDIF

   RETURN ::ValueBound

METHOD DisplayValue(cValue) CLASS HComboBox

   IF cValue != Nil
      IF ::lEdit .AND. HB_ISCHAR(cValue)
         hwg_Setdlgitemtext(::oParent:handle, ::id, cValue)
         ::cDisplayValue := cValue
      ENDIF
   ENDIF

   RETURN iif(!::lEdit, hwg_Getwindowtext(::handle), ::cDisplayValue)

METHOD DeleteItem(xIndex) CLASS HComboBox
   LOCAL nIndex

   IF ::lText .AND. HB_ISCHAR(xIndex)
      nIndex := hwg_Sendmessage(::handle, CB_FINDSTRINGEXACT, -1, xIndex) + 1
   ELSE
      nIndex := xIndex
   ENDIF
   IF hwg_Sendmessage(::handle, CB_DELETESTRING, nIndex - 1, 0) > 0               //<= LEN(ocombo:aitems)
      ADel(::Aitems, nIndex)
      ASize(::Aitems, Len(::aitems) - 1)
      IF Len(::AitemsBound) > 0
         ADel(::AitemsBound, nIndex)
         ASize(::AitemsBound, Len(::aitemsBound) - 1)
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.

METHOD AddItem(cItem, cItemBound, nPos) CLASS HComboBox

   LOCAL nCount

   nCount := hwg_Sendmessage(::handle, CB_GETCOUNT, 0, 0) + 1
   IF Len(::Aitems) == Len(::AitemsBound) .AND. cItemBound != NIL
      IF nCount = 1
         ::RowSource({ { cItem, cItemBound } })
         ::Aitems := {}
      ENDIF
      IF nPos != Nil .AND. nPos > 0 .AND. nPos < nCount
         ASize(::AitemsBound, nCount + 1)
         AIns(::AitemsBound, nPos, cItemBound)
      ELSE
         AAdd(::AitemsBound, cItemBound)
      ENDIF
      ::columnBound := 2
   ENDIF
   IF nPos != Nil .AND. nPos > 0 .AND. nPos < nCount
      ASize(::Aitems, nCount + 1)
      AIns(::Aitems, nPos, cItem)
   ELSE
      AAdd(::Aitems, cItem)
   ENDIF
   IF nPos != Nil .AND. nPos > 0 .AND. nPos < nCount
      hwg_Comboinsertstring(::handle, nPos - 1, cItem)  //::aItems[i])
   ELSE
      hwg_Comboaddstring(::handle, cItem)  //::aItems[i])
   ENDIF

   RETURN nCount

METHOD SetCueBanner(cText, lShowFoco) CLASS HComboBox
   LOCAL lRet := .F.

   IF ::lEdit
      lRet := hwg_Sendmessage(::Handle, CB_SETCUEBANNER, iif(Empty(lShowFoco), 0, 1), hwg_Ansitounicode(cText))
   ENDIF

   RETURN lRet

METHOD InteractiveChange() CLASS HComboBox

   LOCAL npos := hwg_Sendmessage(::handle, CB_GETEDITSEL, 0, 0)

   ::SelStart                     := nPos
   ::cDisplayValue := hwg_Getwindowtext(::handle)
   ::oparent:lSuspendMsgsHandling := .T.
   Eval(::bChangeInt, ::value, Self)
   ::oparent:lSuspendMsgsHandling := .F.

   hwg_Sendmessage(::handle, CB_SETEDITSEL, 0, ::SelStart)

   RETURN Nil

METHOD onSelect() CLASS HComboBox

   IF ::bSelect != Nil
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bSelect, ::value, Self)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN .T.

METHOD onChange(lForce) CLASS HComboBox

   IF !hwg_Selffocus(::handle) .AND. Empty(lForce)
      RETURN Nil
   ENDIF
   IF !hwg_Iswindowvisible(::handle)
      ::SetItem(::Value)
      RETURN Nil
   ENDIF

   ::SetItem(hwg_Sendmessage(::handle, CB_GETCURSEL, 0, 0) + 1)
   IF ::bChangeSel != Nil
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bChangeSel, ::Value, Self)
      ::oparent:lSuspendMsgsHandling := .F.
   ENDIF

   RETURN Nil

METHOD When() CLASS HComboBox

   LOCAL res := .T., oParent, nSkip

   IF !hwg_CheckFocus(Self, .F.)
      RETURN .T.
   ENDIF

   IF !::lText
      //::Refresh()
   ELSE
      //  hwg_Setwindowtext(::handle, ::value)
      //  hwg_Sendmessage(::handle, CB_SELECTSTRING, 0, ::value)
   ENDIF
   nSkip := iif(hwg_Getkeystate(VK_UP) < 0 .OR. (hwg_Getkeystate(VK_TAB) < 0 .AND. hwg_Getkeystate(VK_SHIFT) < 0), -1, 1)
   IF ::bGetFocus != Nil
      ::oParent:lSuspendMsgsHandling := .T.
      ::lnoValid                     := .T.
      IF ::bSetGet != Nil
         res := Eval(::bGetFocus, Eval(::bSetGet, , Self), Self)
      ELSE
         res := Eval(::bGetFocus, ::value, Self)
      ENDIF
      ::oParent:lSuspendMsgsHandling := .F.
      ::lnoValid                     := !res
      IF ValType(res) = "L" .AND. !res
         oParent := hwg_GetParentForm(Self)
         IF Self == ATail(oParent:GetList)
            nSkip := - 1
         ELSEIF Self == oParent:getList[1]
            nSkip := 1
         ENDIF
         hwg_WhenSetFocus(Self, nSkip)
      ENDIF
   ENDIF

   RETURN res

METHOD Valid() CLASS HComboBox
   LOCAL oDlg, nSkip, res, hCtrl := hwg_Getfocus()
   LOCAL ltab := hwg_Getkeystate(VK_TAB) < 0

   IF ::lNoValid .OR. !hwg_CheckFocus(Self, .T.)
      RETURN .T.
   ENDIF

   nSkip := iif(hwg_Getkeystate(VK_SHIFT) < 0, -1, 1)

   IF (oDlg := hwg_GetParentForm(Self)) == Nil .OR. oDlg:nLastKey != VK_ESCAPE
      // end by sauli
      // IF lESC // "if" by Luiz Henrique dos Santos (luizhsantos@gmail.com) 04/06/2006
      // By Luiz Henrique dos Santos (luizhsantos@gmail.com.br) 03/06/2006
      ::GetValue()
      IF ::bLostFocus != Nil
         ::oparent:lSuspendMsgsHandling := .T.
         res := Eval(::bLostFocus, ::value, Self)
         IF ValType(res) = "L" .AND. !res
            ::Setfocus(.T.)
            IF oDlg != Nil
               oDlg:nLastKey := 0
            ENDIF
            ::oparent:lSuspendMsgsHandling := .F.
            RETURN .F.
         ENDIF

      ENDIF
      IF oDlg != Nil
         oDlg:nLastKey := 0
      ENDIF
      IF lTab .AND. hwg_Selffocus(hCtrl) .AND. !hwg_Selffocus(::oParent:handle, oDlg:Handle)
         ::oParent:Setfocus()
         hwg_GetSkip(::oparent, ::handle, , nSkip)
      ENDIF
      ::oparent:lSuspendMsgsHandling := .F.
      IF Empty(hwg_Getfocus()) // getfocus return pointer = 0
         hwg_GetSkip(::oParent, ::handle, , ::nGetSkip)
      ENDIF
   ENDIF

   RETURN .T.

METHOD RowSource(xSource) CLASS HComboBox

   IF xSource != Nil
      IF HB_ISARRAY(xSource)
         IF Len(xSource) > 0 .AND. !hb_IsArray(xSource[1]) .AND. Len(xSource) <= 2 .AND. "->" $ xSource[1] // COLUMNS MAX = 2
            ::xrowsource := { xSource[1] , iif(Len(xSource) > 1, xSource[2], Nil) }
         ENDIF
      ELSE
         ::xrowsource := { xSource, Nil }
      ENDIF
      ::aItems := xSource
   ENDIF

   RETURN ::xRowSource

METHOD Populate() CLASS HComboBox
   LOCAL cAlias, nRecno, value, cValueBound
   LOCAL i, numofchars, LongComboWidth := 0
   LOCAL xRowSource

   IF Empty(::aItems)
      RETURN Nil
   ENDIF
   xRowSource := iif(hb_IsArray(::xRowSource[1]), ::xRowSource[1, 1], ::xRowSource[1])
   IF xRowSource != Nil .AND. (i := At("->", xRowSource)) > 0
      cAlias := AllTrim(Left(xRowSource, i - 1))
      IF SELECT(cAlias) = 0 .AND. (i := At("(", cAlias)) > 0
         cAlias := LTrim(SubStr(cAlias, i + 1))
      ENDIF
      value  := StrTran(xRowSource, calias + "->", , , 1, 1)
      cAlias := iif(ValType(xRowSource) == "U", Nil, cAlias)
      cValueBound := iif(::xrowsource[2]  != Nil .AND. cAlias != Nil, StrTran(::xrowsource[2], calias + "->"), Nil)
   ELSE
      cValueBound := iif(HB_ISARRAY(::aItems[1]) .AND. Len(::aItems[1]) > 1, ::aItems[1, 2], NIL)
   ENDIF
   ::columnBound := iif(cValueBound = Nil, 1, 2)
   IF ::value == Nil
      IF ::lText
         ::value := iif(cAlias = Nil, ::aItems[1], (cAlias)->(&(value)))
      ELSE
         ::value := 1
      ENDIF
   ELSEIF ::lText .AND. !::lEdit .AND. Empty(::value)
      ::value := iif(cAlias = Nil, ::aItems[1], (cAlias)->(&(value)))
   ENDIF
   hwg_Sendmessage(::handle, CB_RESETCONTENT, 0, 0)
   ::AitemsBound := {}
   IF cAlias != Nil .AND. Select(cAlias) > 0
      ::aItems := {}
      nRecno := (cAlias)->(RecNo())
      (cAlias)->(DBGOTOP())
      i := 1
      DO WHILE !(cAlias)->(Eof())
         AAdd(::Aitems, (cAlias)->(&(value)))
         IF !Empty(cvaluebound)
            AAdd(::AitemsBound, (cAlias)->(&(cValueBound)))
         ENDIF
         hwg_Comboaddstring(::handle, ::aItems[i])
         numofchars := hwg_Sendmessage(::handle, CB_GETLBTEXTLEN, i - 1, 0)
         IF numofchars > LongComboWidth
            LongComboWidth := numofchars
         ENDIF
         (cAlias)->(dbSkip())
         i++
      ENDDO
      IF nRecno > 0
         (cAlias)->(dbGoto(nRecno))
      ENDIF
   ELSE
      FOR i := 1 TO Len(::aItems)
         IF ::columnBound > 1
            IF HB_ISARRAY(::aItems[i]) .AND. Len(::aItems[i]) > 1
               AAdd(::AitemsBound, ::aItems[i, 2 ])
            ELSE
               AAdd(::AitemsBound, Nil)
            ENDIF
            ::aItems[i] := ::aItems[i, 1]
            hwg_Comboaddstring(::handle, ::aItems[i])
         ELSE
            hwg_Comboaddstring(::handle, ::aItems[i])
         ENDIF
         numofchars := hwg_Sendmessage(::handle, CB_GETLBTEXTLEN, i - 1, 0)
         IF numofchars > LongComboWidth
            LongComboWidth := numofchars
         ENDIF
      NEXT
   ENDIF
   ::ValueBound := ::GetValueBound()

   RETURN LongComboWidth
