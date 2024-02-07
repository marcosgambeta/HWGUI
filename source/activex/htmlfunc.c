/*
 * $Id: htmlfunc.c 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * ActiveX container
 *
 * Copyright 2006 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 */

#define HB_OS_WIN_32_USED

#define _WIN32_WINNT 0x0400

#include <windows.h>
#include "htmlcore.h" /* Declarations of the functions in DLL.c */

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"
//#include "guilib.h"
#include "hwingui.h"

static short int bOleInitialized = 0;

HB_FUNC(HWGAX_OLEINITIALIZE)
{
  if (!bOleInitialized)
  {
    if (OleInitialize(NULL) == S_OK)
    {
      bOleInitialized = 1;
    }  
  }
  hb_retl(bOleInitialized);
}

HB_FUNC(HWGAX_OLEUNINITIALIZE)
{
  if (bOleInitialized)
  {
    OleUninitialize();
    bOleInitialized = 0;
  }
}

HB_FUNC(HWGAX_EMBEDBROWSEROBJECT)
{
  hb_retl(!EmbedBrowserObject(hwg_par_HWND(1)));
}

HB_FUNC(HWGAX_UNEMBEDBROWSEROBJECT)
{
  UnEmbedBrowserObject(hwg_par_HWND(1));
}

HB_FUNC(HWGAX_DISPLAYHTMLPAGE)
{
  DisplayHTMLPage(hwg_par_HWND(1), hb_parc(2));
}

HB_FUNC(HWGAX_DISPLAYHTMLSTR)
{
  DisplayHTMLStr(hwg_par_HWND(1), hb_parc(2));
}

HB_FUNC(HWGAX_RESIZEBROWSER)
{
  ResizeBrowser(hwg_par_HWND(1), hwg_par_DWORD(2), hwg_par_DWORD(3));
}

HB_FUNC(HWGAX_DOPAGEACTION)
{
  DoPageAction(hwg_par_HWND(1), hwg_par_DWORD(2));
}
