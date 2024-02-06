/*
 * $Id: menu_c.c 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C level menu functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 */

#define OEMRESOURCE
#include "hwingui.h"
#include "incomp_pointer.h"
#include <commctrl.h>
#ifdef __DMC__
#define MIIM_BITMAP 0x00000080
#endif
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbstack.h"

#define FLAG_DISABLED 1

/*
 *  CreateMenu() --> hMenu
 */
HB_FUNC(HWG__CREATEMENU)
{
  HMENU hMenu = CreateMenu();
  HB_RETHANDLE(hMenu);
}

HB_FUNC(HWG__CREATEPOPUPMENU)
{
  HMENU hMenu = CreatePopupMenu();
  HB_RETHANDLE(hMenu);
}

/*
 *  AddMenuItem(hMenu,cCaption,nPos,fByPosition,nId,fState,lSubMenu) --> lResult
 */

HB_FUNC(HWG__ADDMENUITEM)
{
  UINT uFlags = MF_BYPOSITION;
  void *hNewItem;
  LPCTSTR lpNewItem;
  int nPos;
  MENUITEMINFO mii;

  if (!HB_ISNIL(6) && (hb_parni(6) & FLAG_DISABLED))
  {
    uFlags |= MFS_DISABLED;
  }

  lpNewItem = HB_PARSTR(2, &hNewItem, NULL);
  if (lpNewItem)
  {
    BOOL lString = 0;
    LPCTSTR ptr = lpNewItem;

    while (*ptr)
    {
      if (*ptr != ' ' && *ptr != '-')
      {
        lString = 1;
        break;
      }
      ptr++;
    }
    uFlags |= (lString) ? MF_STRING : MF_SEPARATOR;
  }
  else
    uFlags |= MF_SEPARATOR;

  if (hb_parl(7))
  {
    HMENU hSubMenu = CreateMenu();

    uFlags |= MF_POPUP;
    InsertMenu(hwg_par_HMENU(1), hb_parni(3), uFlags, // menu item flags
               (UINT)hSubMenu, // menu item identifier or handle of drop-down menu or submenu
               lpNewItem       // menu item content
    );
    HB_RETHANDLE(hSubMenu);

    // Code to set the ID of submenus, the API seems to assume that you wouldn't really want to,
    // but if you are used to getting help via IDs for popups in 16bit, then this will help you.
    nPos = GetMenuItemCount(hwg_par_HMENU(1));
    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_ID;
    if (GetMenuItemInfo(hwg_par_HMENU(1), nPos - 1, TRUE, &mii))
    {
      mii.wID = hb_parni(5);
      SetMenuItemInfo(hwg_par_HMENU(1), nPos - 1, TRUE, &mii);
    }
  }
  else
  {
    InsertMenu(hwg_par_HMENU(1), hb_parni(3), uFlags, // menu item flags
               hb_parni(5), // menu item identifier or handle of drop-down menu or submenu
               lpNewItem    // menu item content
    );
    hb_retnl(0);
  }
  hb_strfree(hNewItem);
}

/*
HB_FUNC(HWG__ADDMENUITEM)
{

   MENUITEMINFO mii;
   BOOL fByPosition = (HB_ISNIL(4))? 0:(BOOL) hb_parl(4);
   void * hData;

   mii.cbSize = sizeof(MENUITEMINFO);
   mii.fMask = MIIM_TYPE | MIIM_STATE | MIIM_ID;
   mii.fState = (HB_ISNIL(6) || hb_parl(6))? 0:MFS_DISABLED;
   mii.wID = hb_parni(5);
   if (HB_ISCHAR(2))
   {
      mii.dwTypeData = (LPTSTR) HB_PARSTR(2, &hData, NULL);
      mii.cch = strlen(mii.dwTypeData);
      mii.fType = MFT_STRING;
   }
   else
      mii.fType = MFT_SEPARATOR;

   hb_retl(InsertMenuItem(hwg_par_HMENU(1), hb_parni(3), fByPosition, &mii));
   hb_strfree(hData);
}
*/

/*
 *  CreateSubMenu(hMenu, nMenuId) --> hSubMenu
 */
HB_FUNC(HWG__CREATESUBMENU)
{

  MENUITEMINFO mii;
  HMENU hSubMenu = CreateMenu();

  mii.cbSize = sizeof(MENUITEMINFO);
  mii.fMask = MIIM_SUBMENU;
  mii.hSubMenu = hSubMenu;

  if (SetMenuItemInfo(hwg_par_HMENU(1), hb_parni(2), 0, &mii))
  {
    HB_RETHANDLE(hSubMenu);
  }
  else
  {
    HB_RETHANDLE(NULL);
  }
}

/*
 *  SetMenu(hWnd, hMenu) --> lResult
 */
HB_FUNC(HWG__SETMENU)
{
  hb_retl(SetMenu(hwg_par_HWND(1), hwg_par_HMENU(2)));
}

HB_FUNC(HWG_GETMENUHANDLE)
{
  HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? hwg_par_HWND(1) : aWindows[0];
  HB_RETHANDLE(GetMenu(handle));
}

HB_FUNC(HWG_CHECKMENUITEM)
{
  HMENU hMenu;
  UINT uCheck = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_CHECKED : MF_UNCHECKED;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
  }
  else
  {
    CheckMenuItem(hMenu,                // handle to menu
                  hb_parni(2),          // menu item to check or uncheck
                  MF_BYCOMMAND | uCheck // menu item flags
    );
  }
}

HB_FUNC(HWG_ISCHECKEDMENUITEM)
{
  HMENU hMenu;
  UINT uCheck;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    hb_retl(0);
  }
  else
  {
    uCheck = GetMenuState(hMenu,       // handle to menu
                          hb_parni(2), // menu item to check or uncheck
                          MF_BYCOMMAND // menu item flags
    );
    hb_retl(uCheck & MF_CHECKED);
  }
}

HB_FUNC(HWG_ENABLEMENUITEM)
{
  HMENU hMenu; // = (hb_pcount()>0 && !HB_ISNIL(1))? (hwg_par_HMENU(1)) : GetMenu(aWindows[0]);
  UINT uEnable = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_ENABLED : MF_GRAYED;
  UINT uFlag = (hb_pcount() < 4 || !HB_ISLOG(4) || hb_parl(4)) ? MF_BYCOMMAND : MF_BYPOSITION;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    HB_RETHANDLE(NULL);
  }
  else
  {
    HB_RETHANDLE(EnableMenuItem(hMenu,          // handle to menu
                                hb_parni(2),    // menu item to check or uncheck
                                uFlag | uEnable // menu item flags
                                ));
  }
}

HB_FUNC(HWG_ISENABLEDMENUITEM)
{
  HMENU hMenu; // = (hb_pcount()>0 && !HB_ISNIL(1))? (hwg_par_HMENU(1)):GetMenu(aWindows[0]);
  UINT uCheck;
  UINT uFlag = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_BYCOMMAND : MF_BYPOSITION;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    hb_retl(0);
  }
  else
  {
    uCheck = GetMenuState(hMenu,       // handle to menu
                          hb_parni(2), // menu item to check or uncheck
                          uFlag        // menu item flags
    );
    hb_retl(!(uCheck & MF_GRAYED));
  }
}

HB_FUNC(HWG_DELETEMENU)
{
  HMENU hMenu = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HMENU(1)) : GetMenu(aWindows[0]);

  if (hMenu)
  {
    DeleteMenu(hMenu,       // handle to menu
               hb_parni(2), // menu item id to delete
               MF_BYCOMMAND // menu item flags
    );
  }
}

HB_FUNC(HWG_TRACKMENU)
{
  HWND hWnd = hwg_par_HWND(4);
  SetForegroundWindow(hWnd);
  hb_retl(TrackPopupMenu(hwg_par_HMENU(1), // handle of shortcut menu
                         HB_ISNIL(5) ? TPM_RIGHTALIGN
                                     : hb_parni(5), // screen-position and mouse-button flags
                         hb_parni(2),               // horizontal position, in screen coordinates
                         hb_parni(3),               // vertical position, in screen coordinates
                         0,                         // reserved, must be zero
                         hWnd,                      // handle of owner window
                         NULL));
  PostMessage(hWnd, 0, 0, 0);
}

HB_FUNC(HWG_DESTROYMENU)
{
  hb_retl(DestroyMenu(hwg_par_HMENU(1)));
}

/*
 * CreateAcceleratorTable(_aAccel)
 */
HB_FUNC(HWG_CREATEACCELERATORTABLE)
{
  PHB_ITEM pArray = hb_param(1, HB_IT_ARRAY), pSubArr;
  LPACCEL lpaccl;
  ULONG ul, ulEntries = hb_arrayLen(pArray);
  HACCEL h;

  lpaccl = (LPACCEL)hb_xgrab(sizeof(ACCEL) * ulEntries);

  for (ul = 1; ul <= ulEntries; ul++)
  {
    pSubArr = hb_arrayGetItemPtr(pArray, ul);
    lpaccl[ul - 1].fVirt = (BYTE)hb_arrayGetNL(pSubArr, 1) | FNOINVERT | FVIRTKEY;
    lpaccl[ul - 1].key = (WORD)hb_arrayGetNL(pSubArr, 2);
    lpaccl[ul - 1].cmd = (WORD)hb_arrayGetNL(pSubArr, 3);
  }
  h = CreateAcceleratorTable(lpaccl, (int)ulEntries);

  hb_xfree(lpaccl);
  HB_RETHANDLE(h);
}

/*
 * DestroyAcceleratorTable(hAccel)
 */
HB_FUNC(HWG_DESTROYACCELERATORTABLE)
{
  hb_retl(DestroyAcceleratorTable((HACCEL)hb_parnl(1)));
}

HB_FUNC(HWG_DRAWMENUBAR)
{
  hb_retl((BOOL)DrawMenuBar(hwg_par_HWND(1)));
}

/*
 *  GetMenuCaption(hWnd | oWnd, nMenuId)
 */

HB_FUNC(HWG_GETMENUCAPTION)
{
  HMENU hMenu;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    hb_retl(0);
  }
  else
  {
    MENUITEMINFO mii;
    LPTSTR lpBuffer;

    memset(&mii.cbSize, 0, sizeof(MENUITEMINFO));
    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_TYPE;
    mii.fType = MFT_STRING;
    GetMenuItemInfo(hMenu, hb_parni(2), 0, &mii);
    mii.cch++;
    lpBuffer = (LPTSTR)hb_xgrab(mii.cch * sizeof(TCHAR));
    lpBuffer[0] = '\0';
    mii.dwTypeData = lpBuffer;
    if (GetMenuItemInfo(hMenu, hb_parni(2), 0, &mii))
    {
      HB_RETSTR(mii.dwTypeData);
    }
    else
    {
      hb_retc("Error");
    }
    hb_xfree(lpBuffer);
  }
}

/*
 *  SetMenuCaption(hWnd | oWnd, nMenuId, cCaption)
 */
HB_FUNC(HWG_SETMENUCAPTION)
{
  HMENU hMenu;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }

  if (!hMenu)
  {
    MessageBox(GetActiveWindow(), TEXT(""), TEXT("No Menu!"), MB_OK | MB_ICONINFORMATION);
    hb_retl(0);
  }
  else
  {
    MENUITEMINFO mii;
    void *hData;
    mii.cbSize = sizeof(MENUITEMINFO);
    mii.fMask = MIIM_TYPE;
    mii.fType = MFT_STRING;
    mii.dwTypeData = (LPTSTR)HB_PARSTR(3, &hData, NULL);

    if (SetMenuItemInfo(hMenu, hb_parni(2), 0, &mii))
    {
      hb_retl(1);
    }
    else
    {
      hb_retl(0);
    }
    hb_strfree(hData);
  }
}

HB_FUNC(HWG__SETMENUITEMBITMAPS)
{
  hb_retl(SetMenuItemBitmaps(hwg_par_HMENU(1), hb_parni(2), MF_BYCOMMAND, hwg_par_HBITMAP(3),
                             hwg_par_HBITMAP(4)));
}

HB_FUNC(HWG_GETMENUCHECKMARKDIMENSIONS)
{
  hb_retnl((LONG)GetMenuCheckMarkDimensions());
}

HB_FUNC(HWG_GETMENUBITMAPWIDTH)
{
  hb_retni(GetSystemMetrics(SM_CXMENUSIZE));
}

HB_FUNC(HWG_GETMENUBITMAPHEIGHT)
{
  hb_retni(GetSystemMetrics(SM_CYMENUSIZE));
}

HB_FUNC(HWG_GETMENUCHECKMARKWIDTH)
{
  hb_retni(GetSystemMetrics(SM_CXMENUCHECK));
}

HB_FUNC(HWG_GETMENUCHECKMARKHEIGHT)
{
  hb_retni(GetSystemMetrics(SM_CYMENUCHECK));
}

HB_FUNC(HWG_STRETCHBLT)
{
  hb_retl(StretchBlt(hwg_par_HDC(1), hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5),
                     hwg_par_HDC(6), hb_parni(7), hb_parni(8), hb_parni(9), hb_parni(10),
                     hwg_par_DWORD(11)));
}

HB_FUNC(HWG__INSERTBITMAPMENU)
{
  MENUITEMINFO mii;

  mii.cbSize = sizeof(MENUITEMINFO);
  mii.fMask = MIIM_ID | MIIM_BITMAP | MIIM_DATA;
  mii.hbmpItem = hwg_par_HBITMAP(3);

  hb_retl((LONG)SetMenuItemInfo(hwg_par_HMENU(1), hb_parni(2), 0, &mii));
}

HB_FUNC(HWG_CHANGEMENU)
{
  void *hStr;
  hb_retl(ChangeMenu(hwg_par_HMENU(1), (UINT)hb_parni(2), HB_PARSTR(3, &hStr, NULL),
                     (UINT)hb_parni(4), (UINT)hb_parni(5)));
  hb_strfree(hStr);
}

HB_FUNC(HWG_MODIFYMENU)
{
  void *hStr;
  hb_retl(ModifyMenu(hwg_par_HMENU(1), (UINT)hb_parni(2), (UINT)hb_parni(3), (UINT)hb_parni(4),
                     HB_PARSTR(5, &hStr, NULL)));
  hb_strfree(hStr);
}

HB_FUNC(HWG_ENABLEMENUSYSTEMITEM)
{
  HMENU hMenu;
  UINT uEnable = (hb_pcount() < 3 || !HB_ISLOG(3) || hb_parl(3)) ? MF_ENABLED : MF_GRAYED;
  UINT uFlag = (hb_pcount() < 4 || !HB_ISLOG(4) || hb_parl(4)) ? MF_BYCOMMAND : MF_BYPOSITION;

  hMenu = (HMENU)GetSystemMenu(hwg_par_HWND(1), 0);
  if (!hMenu)
  {
    HB_RETHANDLE(NULL);
  }
  else
  {
    HB_RETHANDLE(EnableMenuItem(hMenu,          // handle to menu
                                hb_parni(2),    // menu item to check or uncheck
                                uFlag | uEnable // menu item flags
                                ));
  }
}

HB_FUNC(HWG_SETMENUINFO)
{
  HMENU hMenu;
  MENUINFO mi;
  HBRUSH hbrush;

  if (HB_ISOBJECT(1))
  {
    PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
    hMenu = (HMENU)HB_GETHANDLE(GetObjectVar(pObject, "HANDLE"));
  }
  else
  {
    HWND handle = (hb_pcount() > 0 && !HB_ISNIL(1)) ? (hwg_par_HWND(1)) : aWindows[0];
    hMenu = GetMenu(handle);
  }
  if (!hMenu)
  {
    hMenu = hwg_par_HMENU(1);
  }
  if (hMenu)
  {
    hbrush = hb_pcount() > 1 && !HB_ISNIL(2) ? CreateSolidBrush(hwg_par_COLORREF(2)) : NULL;
    mi.cbSize = sizeof(mi);
    mi.fMask = MIM_APPLYTOSUBMENUS | MIM_BACKGROUND;
    mi.hbrBack = hbrush;
    SetMenuInfo(hMenu, &mi);
  }
}
