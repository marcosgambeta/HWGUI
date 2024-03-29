/*
 * $Id: htrackbr.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HTrackBar class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define TBS_AUTOTICKS                1
#define TBS_VERT                     2
#define TBS_TOP                      4
#define TBS_LEFT                     4
#define TBS_BOTH                     8
#define TBS_NOTICKS                 16


CLASS HTrackBar INHERIT HControl

   CLASS VAR winclass INIT "msctls_trackbar32"
   DATA value
   DATA bChange
   DATA bThumbDrag
   DATA nLow
   DATA nHigh
   DATA hCursor

   METHOD New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
         bInit, bSize, bPaint, cTooltip, bChange, bDrag, nLow, nHigh, ;
         lVertical, TickStyle, TickMarks)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD SetValue(nValue)
   METHOD GetValue()
   METHOD GetNumTics() INLINE hwg_Sendmessage(::handle, TBM_GETNUMTICS, 0, 0)

ENDCLASS

METHOD New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
      bInit, bSize, bPaint, cTooltip, bChange, bDrag, nLow, nHigh, ;
      lVertical, TickStyle, TickMarks) CLASS HTrackBar

   IF TickStyle == NIL
      TickStyle := TBS_AUTOTICKS
   ENDIF
   IF TickMarks == NIL
      TickMarks := 0
   ENDIF
   IF bPaint != NIL
      TickStyle := Hwg_BitOr(TickStyle, TBS_AUTOTICKS)
   ENDIF
   nStyle := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), ;
         WS_CHILD + WS_VISIBLE + WS_TABSTOP)
   nStyle += IIf(lVertical != NIL .AND. lVertical, TBS_VERT, 0)
   nStyle += TickStyle + TickMarks

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight,, ;
         bInit, bSize, bPaint, cTooltip)

   ::value := IIf(HB_ISNUMERIC(vari), vari, 0)
   ::bChange := bChange
   ::bThumbDrag := bDrag
   ::nLow := IIf(nLow == NIL, 0, nLow)
   ::nHigh := IIf(nHigh == NIL, 100, nHigh)

   HWG_InitCommonControlsEx()
   ::Activate()

   RETURN Self

METHOD Activate() CLASS HTrackBar
   IF !Empty(::oParent:handle)
      ::handle := hwg_InitTrackbar(::oParent:handle, ::id, ::style, ;
            ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
            ::nLow, ::nHigh)
      ::Init()
   ENDIF

   RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD onEvent(msg, wParam, lParam) CLASS HTrackBar
   LOCAL aCoors

   IF msg == WM_PAINT
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
         RETURN 0
      ENDIF
   ELSEIF msg == WM_MOUSEMOVE
      IF ::hCursor != NIL
         Hwg_SetCursor(::hCursor)
      ENDIF
   ELSEIF msg == WM_ERASEBKGND
      IF ::brush != NIL
         aCoors := hwg_Getclientrect(::handle)
         hwg_Fillrect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, ;
               aCoors[4] + 1, ::brush:handle)
         RETURN 1
      ENDIF
   ELSEIF msg == WM_DESTROY
      ::END()
   ELSEIF msg == WM_CHAR
      IF wParam = VK_TAB
         hwg_GetSkip(::oParent, ::handle, , ;
               IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ENDIF
    ELSEIF msg = WM_KEYDOWN
       IF hwg_ProcKeyList(Self, wParam)
          RETURN 0
      ENDIF
   ELSEIF hb_IsBlock(::bOther)
      RETURN Eval(::bOther, Self, msg, wParam, lParam)
   ENDIF

   RETURN - 1
#endif

METHOD onEvent(msg, wParam, lParam) CLASS HTrackBar

   LOCAL aCoors

   SWITCH msg

   CASE WM_PAINT
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
         RETURN 0
      ENDIF
      EXIT

   CASE WM_MOUSEMOVE
      IF ::hCursor != NIL
         Hwg_SetCursor(::hCursor)
      ENDIF
      EXIT

   CASE WM_ERASEBKGND
      IF ::brush != NIL
         aCoors := hwg_Getclientrect(::handle)
         hwg_Fillrect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
         RETURN 1
      ENDIF
      EXIT

   CASE WM_DESTROY
      ::END()
      EXIT

   CASE WM_CHAR
      IF wParam == VK_TAB
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ENDIF
      EXIT

   CASE WM_KEYDOWN
      IF hwg_ProcKeyList(Self, wParam)
         RETURN 0
      ENDIF
      EXIT

   #ifdef __XHARBOUR__
   DEFAULT
   #else
   OTHERWISE
   #endif

      IF hb_IsBlock(::bOther)
         RETURN Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

   ENDSWITCH

   RETURN -1

METHOD Init() CLASS HTrackBar
   IF !::lInit
      ::Super:Init()
      hwg_TrackbarSetrange(::handle, ::nLow, ::nHigh)
      hwg_Sendmessage(::handle, TBM_SETPOS, 1, ::value)
      IF ::bPaint != NIL
         ::nHolder := 1
         hwg_Setwindowobject(::handle, Self)
         Hwg_InitTrackProc(::handle)
      ENDIF
   ENDIF

   RETURN NIL

METHOD SetValue(nValue) CLASS HTrackBar
   IF HB_ISNUMERIC(nValue)
      hwg_Sendmessage(::handle, TBM_SETPOS, 1, nValue)
      ::value := nValue
   ENDIF

   RETURN NIL

METHOD GetValue() CLASS HTrackBar
   ::value := hwg_Sendmessage(::handle, TBM_GETPOS, 0, 0)

   RETURN (::value)

#pragma BEGINDUMP

// TODO: revision
#if defined(_MSC_VER)
#pragma warning( disable : 4312 )
#endif

#include "hwingui.h"
#include "incomp_pointer.h"
#include <commctrl.h>

HB_FUNC(HWG_INITTRACKBAR)
{
    HWND hTrackBar;

    hTrackBar = CreateWindowEx(0, TRACKBAR_CLASS,
                             0,
                             (LONG) hb_parnl(3),
                                    hb_parni(4),
                                    hb_parni(5),
                                    hb_parni(6),
                                    hb_parni(7),
                             hwg_par_HWND(1),
                             hwg_par_HMENU(2),
                             GetModuleHandle(NULL),
                             NULL);

    HB_RETHANDLE(hTrackBar);
}

HB_FUNC(HWG_TRACKBARSETRANGE)
{
    SendMessage(hwg_par_HWND(1), TBM_SETRANGE, TRUE, MAKELONG(hb_parni(2), hb_parni(3)));
}

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(INITTRACKBAR, HWG_INITTRACKBAR)
HB_FUNC_TRANSLATE(TRACKBARSETRANGE, HWG_TRACKBARSETRANGE)
#endif

#pragma ENDDUMP
