/*
 * $Id: animat.c 2007 2013-02-20 07:21:29Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C functions for HAnimation class
 *
 * Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
 * www - http://geocities.yahoo.com.br/marcosgambeta/
 */

#include "hwingui.h"
#include "incomp_pointer.h"
#include <commctrl.h>

HB_FUNC(HWG_ANIMATE_CREATE)
{
  HWND hwnd;
  hwnd = Animate_Create(hwg_par_HWND(1), (UINT_PTR)hb_parni(2), (DWORD)hb_parnl(3), GetModuleHandle(NULL));
  MoveWindow(hwnd, hb_parnl(4), hb_parnl(5), hb_parnl(6), hb_parnl(7), TRUE);
  HB_RETHANDLE(hwnd);
}

HB_FUNC(HWG_ANIMATE_OPEN)
{
  void *hStr;
  Animate_Open(hwg_par_HWND(1), HB_PARSTR(2, &hStr, NULL));
  hb_strfree(hStr);
}

HB_FUNC(HWG_ANIMATE_PLAY)
{
  Animate_Play(hwg_par_HWND(1), hb_parni(2), hb_parni(3), hb_parni(4));
}

HB_FUNC(HWG_ANIMATE_SEEK)
{
  Animate_Seek(hwg_par_HWND(1), hb_parni(2));
}

HB_FUNC(HWG_ANIMATE_STOP)
{
  Animate_Stop(hwg_par_HWND(1));
}

HB_FUNC(HWG_ANIMATE_CLOSE)
{
  Animate_Close(hwg_par_HWND(1));
}

HB_FUNC(HWG_ANIMATE_DESTROY)
{
  DestroyWindow(hwg_par_HWND(1));
}

HB_FUNC(HWG_ANIMATE_OPENEX)
{
#if defined(__DMC__)
#define Animate_OpenEx(hwnd, hInst, szName) (BOOL) SNDMSG(hwnd, ACM_OPEN, (WPARAM)hInst, (LPARAM)(LPTSTR)(szName))
#endif
  void *hResource;
  LPCTSTR lpResource = HB_PARSTR(3, &hResource, NULL);

  if (!lpResource && HB_ISNUM(3))
  {
    lpResource = MAKEINTRESOURCE(hb_parni(3));
  }

  Animate_OpenEx(hwg_par_HWND(1), (HINSTANCE)(LONG_PTR)hb_parnl(2), lpResource);

  hb_strfree(hResource);
}

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(ANIMATE_CREATE, HWG_ANIMATE_CREATE)
HB_FUNC_TRANSLATE(ANIMATE_OPEN, HWG_ANIMATE_OPEN)
HB_FUNC_TRANSLATE(ANIMATE_OPENEX, HWG_ANIMATE_OPENEX)
HB_FUNC_TRANSLATE(ANIMATE_PLAY, HWG_ANIMATE_PLAY)
HB_FUNC_TRANSLATE(ANIMATE_SEEK, HWG_ANIMATE_SEEK)
HB_FUNC_TRANSLATE(ANIMATE_STOP, HWG_ANIMATE_STOP)
HB_FUNC_TRANSLATE(ANIMATE_CLOSE, HWG_ANIMATE_CLOSE)
HB_FUNC_TRANSLATE(ANIMATE_DESTROY, HWG_ANIMATE_DESTROY)
#endif
