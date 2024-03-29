/*
 * $Id: listbox.c 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HList class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 * Listbox class and accompanying code added Feb 22nd, 2004 by
 * Vic McClung
 */

#include "hwingui.h"
#include "incomp_pointer.h"
#if defined(__MINGW32__) || defined(__WATCOMC__)
#include <prsht.h>
#endif
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>

HB_FUNC(HWG_LISTBOXADDSTRING)
{
  void *hString;

  SendMessage(hwg_par_HWND(1), LB_ADDSTRING, 0, (LPARAM)HB_PARSTR(2, &hString, NULL));
  hb_strfree(hString);
}

HB_FUNC(HWG_LISTBOXSETSTRING)
{
  SendMessage(hwg_par_HWND(1), LB_SETCURSEL, hwg_par_WPARAM(2) - 1, 0);
}

/*
   CreateListbox(hParentWIndow, nListboxID, nStyle, x, y, nWidth, nHeight)
*/
HB_FUNC(HWG_CREATELISTBOX)
{
  HWND hListbox = CreateWindowEx(0, TEXT("LISTBOX"),                  /* predefined class  */
                                 TEXT(""),                            /*   */
                                 WS_CHILD | WS_VISIBLE | hb_parnl(3), /* style  */
                                 hb_parni(4), hb_parni(5),            /* x, y       */
                                 hb_parni(6), hb_parni(7),            /* nWidth, nHeight */
                                 hwg_par_HWND(1),                     /* parent window    */
                                 hwg_par_HMENU(2),                    /* listbox ID      */
                                 GetModuleHandle(NULL), NULL);

  HB_RETHANDLE(hListbox);
}

HB_FUNC(HWG_LISTBOXDELETESTRING)
{
  SendMessage(hwg_par_HWND(1), LB_DELETESTRING, 0, 0);
}

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(LISTBOXADDSTRING, HWG_LISTBOXADDSTRING)
HB_FUNC_TRANSLATE(LISTBOXSETSTRING, HWG_LISTBOXSETSTRING)
HB_FUNC_TRANSLATE(CREATELISTBOX, HWG_CREATELISTBOX)
HB_FUNC_TRANSLATE(LISTBOXDELETESTRING, HWG_LISTBOXDELETESTRING)
#endif
