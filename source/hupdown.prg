/*
 * $Id: hupdown.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HUpDown class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define UDN_FIRST               (-721)        // updown
#define UDN_DELTAPOS            (UDN_FIRST - 1)
#define UDM_SETBUDDY            (WM_USER + 105)
#define UDM_GETBUDDY            (WM_USER + 106)
#define EC_RIGHTMARGIN           2

CLASS HUpDown INHERIT HControl

   CLASS VAR winclass   INIT "EDIT"

   DATA bSetGet
   DATA nValue
   DATA bValid
   DATA hwndUpDown, idUpDown, styleUpDown
   DATA bkeydown, bkeyup, bchange
   DATA bClickDown, bClickUp
   DATA nLower       INIT -9999  //0
   DATA nUpper       INIT 9999  //999
   DATA nUpDownWidth INIT 10
   DATA lChanged     INIT .F.
   DATA Increment    INIT 1
   DATA nMaxLength   INIT NIL
   DATA lNoBorder
   DATA cPicture
   DATA oEditUpDown
   DATA bColorOld   HIDDEN

   DATA lCreate    INIT .F. HIDDEN //

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
              oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor,;
                     nUpDWidth, nLower, nUpper, nIncr, cPicture, lNoBorder, nMaxLength,;
              bKeyDown, bChange, bOther, bClickUp, bClickDown)

   METHOD Activate()
   METHOD Init()
   METHOD CreateUpDown()
   METHOD SetValue(nValue)
   METHOD Value(Value) SETGET
   METHOD Refresh()
   METHOD SetColor(tColor, bColor, lRedraw) INLINE ::super:SetColor(tColor, bColor, lRedraw), IIF(::oEditUpDown != NIL, ;
                                             ::oEditUpDown:SetColor(tColor, bColor, lRedraw),)
   METHOD DisableBackColor(DisableBColor) SETGET
   METHOD Hide() INLINE (::lHide := .T., hwg_Hidewindow(::handle), hwg_Hidewindow(::hwndUpDown))
   METHOD Show() INLINE (::lHide := .F., hwg_Showwindow(::handle), hwg_Showwindow(::hwndUpDown))
   METHOD Enable() INLINE (::Super:Enable(), hwg_Enablewindow(::hwndUpDown, .T.), hwg_Invalidaterect(::hwndUpDown, 0))
                          //  hwg_Invalidaterect(::oParent:Handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight))
   METHOD Disable() INLINE (::Super:Disable(), hwg_Enablewindow(::hwndUpDown, .F.))
   METHOD Valid()
   METHOD SetRange(nLower, nUpper)
   METHOD Move(x1, y1, width, height, nRepaint) INLINE ;                             // + hwg_Getclientrect(::hwndUpDown)[3] - 1
                              ::Super:Move(x1, y1, IIF(width != NIL, width, ::nWidth), height, nRepaint), ;
                              hwg_Sendmessage(::hwndUpDown, UDM_SETBUDDY, ::oEditUpDown:handle, 0),;
                              IIF(::lHide, ::Hide(), ::Show())

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
            oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor,;
                 nUpDWidth, nLower, nUpper, nIncr, cPicture, lNoBorder, nMaxLength,;
            bKeyDown, bChange, bOther, bClickUp, bClickDown) CLASS HUpDown

   HB_SYMBOL_UNUSED(bOther)

   nStyle := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP + IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0))

   IF Valtype(vari) != "N"
      vari := 0
      Eval(bSetGet, vari)
   ENDIF
   IF bSetGet = NIL
      bSetGet := {|v|IIF(v == NIL, ::nValue, ::nValue := v)}
   ENDIF

   ::nValue := Vari
   ::title := Str(vari)
   ::bSetGet := bSetGet
   ::bColorOld := bColor
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctooltip, tcolor, bcolor)

   ::idUpDown := ::id //::NewId()

   ::Increment := IIF(nIncr = NIL, 1, nIncr)
   ::styleUpDown := UDS_ALIGNRIGHT  + UDS_ARROWKEYS + UDS_NOTHOUSANDS //+ UDS_SETBUDDYINT //+ UDS_HORZ
   IF nLower != NIL
      ::nLower := nLower
   ENDIF
   IF nUpper != NIL
      ::nUpper := nUpper
   ENDIF
   // width of spinner
   IF nUpDWidth != NIL
      ::nUpDownWidth := nUpDWidth
   ENDIF
   ::nMaxLength := nMaxLength //= NIL, 4, nMaxLength)
   ::cPicture := IIF(cPicture = NIL, Replicate("9", 4), cPicture)
   ::lNoBorder := lNoBorder
   ::bkeydown := bkeydown
   ::bchange  := bchange
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus

   ::Activate()

   ::bClickDown := bClickDown
   ::bClickUp := bClickUp

   IF bSetGet != NIL
      ::bValid := bLFocus
   ELSE
      IF bGfocus != NIL
         ::lnoValid := .T.
      ENDIF
   ENDIF

  Return Self

METHOD Activate() CLASS HUpDown

   IF !empty(::oParent:handle)
      ::lCreate := .T.
      ::oEditUpDown := HEditUpDown():New(::oParent, ::id, val(::title), ::bSetGet, ::Style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
           ::oFont, ::bInit, ::bSize, ::bPaint, ::bGetfocus, ::bLostfocus, ::tooltip, ::tcolor, ::bcolor, ::cPicture,;
           ::lNoBorder, ::nMaxLength, , ::bKeyDown, ::bChange, ::bOther, ::controlsource)
      ::oEditUpDown:Name := "oEditUpDown"
      ::SetColor(::tColor, ::oEditUpDown:bColor)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Init() CLASS HUpDown

   IF !::lInit
      ::Super:Init()
      ::Createupdown()
      hwg_Sendmessage(::oEditUpDown:Handle, EM_SETMARGINS, EC_RIGHTMARGIN, hwg_Makelparam(0, 1))
      ::DisableBackColor := ::DisablebColor
      ::Refresh()
   ENDIF
   Return NIL


METHOD CREATEUPDOWN() CLASS Hupdown

   ///IF Empty(::handle)
   //   RETURN NIL
    //ENDIF
   ::nHolder := 0
   IF !::lCreate
      ::Activate()
      hwg_Addtooltip(hwg_GetParentForm(Self):handle, ::oEditUpDown:handle, ::tooltip)
      ::oEditUpDown:SetFont(::oFont)
      ::oEditUpDown:DisableBrush := ::DisableBrush
      hwg_Setwindowpos(::oEditUpDown:handle, ::Handle, 0, 0, 0, 0, SWP_NOSIZE +  SWP_NOMOVE)
      hwg_Destroywindow(::Handle)
   ELSEIF hwg_getParentForm(Self):Type < WND_DLG_RESOURCE .AND. ::oParent:ClassName = "HTAB" //!EMPTY(::oParent:oParent)
      ::nHolder := 1
      hwg_Setwindowobject(::oEditUpDown:handle, ::oEditUpDown)
      Hwg_InitEditProc(::oEditUpDown:handle)
   ELSE
      hwg_Addtooltip(hwg_GetParentForm(Self):handle, ::oEditUpDown:handle, ::tooltip)
   ENDIF
   ::handle := ::oEditUpDown:handle
   ::hwndUpDown := hwg_Createupdowncontrol(::oParent:handle, ::idUpDown, ;
                                     ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, -2147483647, 2147483647, Val(::title))
                                    // ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, ::nLower, ::nUpper, Val(::title))
   ::oEditUpDown:oUpDown := Self
   ::oEditUpDown:lInit := .T.
   IF ::nHolder = 0
      ::nHolder := 1
      hwg_Setwindowobject(::handle, ::oEditUpDown)
      Hwg_InitEditProc(::handle)
   ENDIF
   RETURN NIL

METHOD DisableBackColor(DisableBColor) CLASS HUpDown

    IF DisableBColor != NIL
       ::Super:DisableBackColor(DisableBColor)
       IF ::oEditUpDown != NIL
          ::oEditUpDown:DisableBrush := ::DisableBrush
       ENDIF
    ENDIF
    RETURN ::DisableBColor

METHOD SetRange(nLower, nUpper) CLASS HUpDown
   
   ::nLower := IIF(nLower != NIL, nLower, ::nLower)
   ::nUpper := IIF(nUpper != NIL, nUpper, ::nUpper)
   hwg_Setrangeupdown(::nLower, ::nUpper)

   RETURN NIL

METHOD Value(Value) CLASS HUpDown

   IF Value != NIL .AND. ::oEditUpDown != NIL
       ::SetValue(Value)
       ::oEditUpDown:Title := ::Title
       ::oEditUpDown:Refresh()
   ENDIF
   RETURN ::nValue

METHOD SetValue(nValue) CLASS HUpDown

   IF nValue < ::nLower .OR. nValue > ::nUpper
       nValue := ::nValue
   ENDIF
   ::nValue := nValue
   ::title := Str(::nValue)
   hwg_Setupdown(::hwndUpDown, ::nValue)
   IF ::bSetGet != NIL
      Eval(::bSetGet, ::nValue, Self)
   ENDIF

   RETURN ::nValue

METHOD Refresh() CLASS HUpDown

   IF ::bSetGet != NIL //.AND. ::nValue != NIL
      ::nValue := Eval(::bSetGet, , Self)
      IF Str(::nValue) != ::title
         //::title := Str(::nValue)
         //hwg_Setupdown(::hwndUpDown, ::nValue)
         ::SetValue(::nValue)
      ENDIF
   ELSE
      hwg_Setupdown(::hwndUpDown, Val(::title))
   ENDIF
   ::oEditUpDown:Title := ::Title
   ::oEditUpDown:Refresh()
   IF hwg_Selffocus(::handle)
      hwg_Invalidaterect(::hwndUpDown, 0)
   ENDIF

   RETURN NIL

METHOD Valid() CLASS HUpDown
   LOCAL res

   IF ::oEditUpDown:lNoValid
      RETURN .T.
   ENDIF

   /*
   ::title := hwg_Getedittext(::oParent:handle, ::oEditUpDown:id)
   ::nValue := Val(Ltrim(::title))
   IF ::bSetGet != NIL
      Eval(::bSetGet, ::nValue)
   ENDIF
   */
   res := ::nValue <= ::nUpper .AND. ::nValue >= ::nLower
   IF !res
      ::nValue := IIF(::nValue > ::nUpper, Min(::nValue, ::nUpper), Max(::nValue, ::nLower))
      ::SetValue(::nValue)
      ::oEditUpDown:Refresh()
      hwg_Sendmessage(::oEditUpDown:Handle, EM_SETSEL, 0, -1)
      ::Setfocus()
   ENDIF
   Return res

*-----------------------------------------------------------------
CLASS HEditUpDown INHERIT HEdit

    //DATA Value

    METHOD INIT()
    METHOD Notify(lParam)
    METHOD Refresh()
    METHOD Move()  VIRTUAL

ENDCLASS

METHOD Init() CLASS HEditUpDown

   IF !::lInit
      IF ::bChange != NIL
         ::oParent:AddEvent(EN_CHANGE, self,{||::onChange()},, "onChange")
      ENDIF
   ENDIF
   RETURN NIL

METHOD Notify(lParam) CLASS HeditUpDown
   Local nCode := hwg_Getnotifycode(lParam)
   Local iPos := hwg_Getnotifydeltapos(lParam, 1)
   Local iDelta := hwg_Getnotifydeltapos(lParam, 2)
   Local vari, res

   //iDelta := IIF(iDelta < 0, 1, -1) // IIF(::oParent:oParent = NIL, -1, 1)

 	 IF ::oUpDown = NIL .OR. Hwg_BitAnd(hwg_Getwindowlong(::handle, GWL_STYLE), ES_READONLY) != 0 .OR. ;
 	     hwg_Getfocus() != ::Handle .OR. ;
       (::oUpDown:bGetFocus != NIL .AND. !Eval(::oUpDown:bGetFocus, ::oUpDown:nValue, ::oUpDown))
	     Return 0
   ENDIF

   vari := Val(LTrim(::UnTransform(::title)))

   IF (vari <= ::oUpDown:nLower .AND. iDelta < 0) .OR. ;
       (vari >= ::oUpDown:nUpper .AND. iDelta > 0) .OR. ::oUpDown:Increment = 0
       ::Setfocus()
       RETURN 0
   ENDIF
   vari := vari + (::oUpDown:Increment * idelta)
   ::oUpDown:SetValue(vari)
   /*
   ::Title := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
   hwg_Setdlgitemtext(::oParent:handle, ::id, ::title)
   ::oUpDown:Title := ::Title
   ::oUpDown:SetValue(vari)
   ::Setfocus()
   */
   
   ::Refresh()
   ::oUpDown:Title := ::Title
      IF nCode = UDN_DELTAPOS .AND. (::oUpDown:bClickUp != NIL .OR. ::oUpDown:bClickDown != NIL)
      ::oparent:lSuspendMsgsHandling := .T.
      IF iDelta < 0 .AND. ::oUpDown:bClickDown  != NIL
         res := Eval(::oUpDown:bClickDown, ::oUpDown, ::oUpDown:nValue, iDelta, ipos)
      ELSEIF iDelta > 0 .AND. ::oUpDown:bClickUp  != NIL
         res := Eval(::oUpDown:bClickUp, ::oUpDown, ::oUpDown:nValue, iDelta, ipos)
      ENDIF
      ::oparent:lSuspendMsgsHandling := .F.
      IF VALTYPE(res) = "L" .AND. !res
         RETURN 0
      ENDIF
   ENDIF
   IF nCode = UDN_FIRST

   ENDIF
   RETURN 0

 METHOD Refresh() CLASS HeditUpDown
   LOCAL vari

   vari := IIF(::oUpDown != NIL, ::oUpDown:nValue, ::Value)
   IF ::bSetGet != NIL .AND. ::title != NIL
      ::Title := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
   ENDIF
   hwg_Setwindowtext(::Handle, ::Title)

   RETURN NIL

**------------------ END NEW CLASS UPDOWN
