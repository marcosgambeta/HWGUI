/*
 * $Id: hmonthc.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HMonthCalendar class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
*/

//--------------------------------------------------------------------------//

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define MCS_DAYSTATE             1
#define MCS_MULTISELECT          2
#define MCS_WEEKNUMBERS          4
#define MCS_NOTODAYCIRCLE        8
#define MCS_NOTODAY             16

//--------------------------------------------------------------------------//

CLASS HMonthCalendar INHERIT HControl

CLASS VAR winclass   INIT "SysMonthCal32"

   DATA value
   DATA bChange
   DATA bSelect

   METHOD New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
              oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
              lWeekNumbers, bSelect)
   METHOD Activate()
   METHOD Init()
   METHOD SetValue(dValue)
   METHOD GetValue()
   METHOD onChange()
   METHOD onSelect()


ENDCLASS

//--------------------------------------------------------------------------//

METHOD New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, ;
           oFont, bInit, bChange, cTooltip, lNoToday, lNoTodayCircle, ;
           lWeekNumbers, bSelect) CLASS HMonthCalendar

   nStyle := Hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), 0) //WS_TABSTOP)
   nStyle   += IIf(lNoToday == NIL .OR. !lNoToday, 0, MCS_NOTODAY)
   nStyle   += IIf(lNoTodayCircle == NIL .OR. !lNoTodayCircle, 0, MCS_NOTODAYCIRCLE)
   nStyle   += IIf(lWeekNumbers == NIL .OR. !lWeekNumbers, 0, MCS_WEEKNUMBERS)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              ,, cTooltip)

   ::value := IIf(ValType(vari) == "D" .And. !Empty(vari), vari, Date())

   ::bChange := bChange
   ::bSelect := bSelect

   HWG_InitCommonControlsEx()

   /*
   IF bChange != NIL
      ::oParent:AddEvent(MCN_SELECT, Self, bChange, .T., "onChange")
      ::oParent:AddEvent(MCN_SELCHANGE, Self, bChange, .T., "onChange")
   ENDIF
   */

   ::Activate()
   RETURN Self

//--------------------------------------------------------------------------//

METHOD Activate() CLASS HMonthCalendar

   IF !Empty(::oParent:handle)
      ::handle := hwg_InitMonthCalendar(::oParent:handle, ::id, ::style, ;
                                      ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

//--------------------------------------------------------------------------//

METHOD Init() CLASS HMonthCalendar

   IF !::lInit
      ::Super:Init()
      IF !Empty(::value)
         hwg_SetMonthCalendardate(::handle, ::value)
      ENDIF
      ::oParent:AddEvent(MCN_SELECT, Self, {||::onSelect()}, .T., "onSelect")
      ::oParent:AddEvent(MCN_SELCHANGE, Self, {||::onChange()}, .T., "onChange")

   ENDIF

   RETURN NIL

//--------------------------------------------------------------------------//

METHOD SetValue(dValue) CLASS HMonthCalendar

   IF ValType(dValue) == "D" .And. !Empty(dValue)
      hwg_SetMonthCalendardate(::handle, dValue)
      ::value := dValue
   ENDIF

   RETURN NIL

//--------------------------------------------------------------------------//

METHOD GetValue() CLASS HMonthCalendar

   ::value := hwg_GetMonthCalendardate(::handle)

   RETURN (::value)

METHOD onChange() CLASS HMonthCalendar

   IF hb_IsBlock(::bChange) .AND. !::oparent:lSuspendMsgsHandling
      hwg_Sendmessage(::handle, WM_LBUTTONDOWN, 0, hwg_Makelparam(1, 1))
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bChange, ::value, Self)
      ::oparent:lSuspendMsgsHandling := .F.
    ENDIF

   RETURN 0

METHOD onSelect() CLASS HMonthCalendar

   IF hb_IsBlock(::bSelect) .AND. !::oparent:lSuspendMsgsHandling
      ::oparent:lSuspendMsgsHandling := .T.
      Eval(::bSelect, ::value, Self)
      ::oparent:lSuspendMsgsHandling := .F.
    ENDIF

   RETURN NIL

//--------------------------------------------------------------------------//

#pragma BEGINDUMP

// TODO: revision
#if defined(_MSC_VER)
#pragma warning( disable : 4312 )
#endif

#include "hwingui.h"
#include "incomp_pointer.h"
#include <commctrl.h>
#include <hbapiitm.h>
#include <hbdate.h>
#if defined(__DMC__)
#include "missing.h"
#endif

HB_FUNC(HWG_INITMONTHCALENDAR)
{
   HWND hMC;
   RECT rc;

   hMC = CreateWindowEx(0,
                        MONTHCAL_CLASS,
                        TEXT(""),
                        (LONG) hb_parnl(3), /* 0, 0, 0, 0, */
                        hb_parni(4), hb_parni(5),      /* x, y       */
                        hb_parni(6), hb_parni(7),      /* nWidth, nHeight */
                        hwg_par_HWND(1),
                        hwg_par_HMENU(2),
                        GetModuleHandle(NULL),
                        NULL);

   MonthCal_GetMinReqRect(hMC, &rc);

   SetWindowPos(hMC, NULL, hb_parni(4), hb_parni(5), hb_parni(6), hb_parni(7), SWP_NOZORDER);

    HB_RETHANDLE(hMC);
}

HB_FUNC(HWG_SETMONTHCALENDARDATE) // adaptation of function SetDatePicker of file Control.c
{
   PHB_ITEM pDate = hb_param(2, HB_IT_DATE);

   if (pDate)
   {
      SYSTEMTIME sysTime;
      #ifndef HARBOUR_OLD_VERSION
      int lYear, lMonth, lDay;
      #else
      long lYear, lMonth, lDay;
      #endif

      hb_dateDecode(hb_itemGetDL(pDate), &lYear, &lMonth, &lDay);

      sysTime.wYear = (unsigned short) lYear;
      sysTime.wMonth = (unsigned short) lMonth;
      sysTime.wDay = (unsigned short) lDay;
      sysTime.wDayOfWeek = 0;
      sysTime.wHour = 0;
      sysTime.wMinute = 0;
      sysTime.wSecond = 0;
      sysTime.wMilliseconds = 0;

      MonthCal_SetCurSel(hwg_par_HWND(1), &sysTime);

   }
}

HB_FUNC(HWG_GETMONTHCALENDARDATE) // adaptation of function GetDatePicker of file Control.c
{
   SYSTEMTIME st;
   char szDate[9];

   SendMessage(hwg_par_HWND(1), MCM_GETCURSEL, 0, (LPARAM) &st);

   hb_dateStrPut(szDate, st.wYear, st.wMonth, st.wDay);
   szDate[8] = 0;
   hb_retds(szDate);
}

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(INITMONTHCALENDAR, HWG_INITMONTHCALENDAR)
HB_FUNC_TRANSLATE(SETMONTHCALENDARDATE, HWG_SETMONTHCALENDARDATE)
HB_FUNC_TRANSLATE(GETMONTHCALENDARDATE, HWG_GETMONTHCALENDARDATE)
#endif

#pragma ENDDUMP
