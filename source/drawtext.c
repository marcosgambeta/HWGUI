/*
 * $Id: drawtext.c 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C level text functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 */

#define OEMRESOURCE
#include "hwingui.h"
#include <commctrl.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>

HB_FUNC_EXTERN(HB_OEMTOANSI);
HB_FUNC_EXTERN(HB_ANSITOOEM);

HB_FUNC(HWG_DEFINEPAINTSTRU)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)hb_xgrab(sizeof(PAINTSTRUCT));
  HB_RETHANDLE(pps);
}

HB_FUNC(HWG_BEGINPAINT)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(2);
  HDC hDC = BeginPaint(hwg_par_HWND(1), pps);
  HB_RETHANDLE(hDC);
}

HB_FUNC(HWG_ENDPAINT)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(2);
  EndPaint(hwg_par_HWND(1), pps);
  hb_xfree(pps);
}

HB_FUNC(HWG_DELETEDC)
{
  DeleteDC(hwg_par_HDC(1));
}

HB_FUNC(HWG_TEXTOUT)
{
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(4, &hText, &nLen);

  TextOut(hwg_par_HDC(1), // handle of device context
          hb_parni(2),    // x-coordinate of starting position
          hb_parni(3),    // y-coordinate of starting position
          lpText,         // address of string
          (int)nLen       // number of characters in string
  );
  hb_strfree(hText);
}

HB_FUNC(HWG_DRAWTEXT)
{
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
  RECT rc;
  UINT uFormat = (hb_pcount() == 4 ? hb_parni(4) : hb_parni(7));
  // int uiPos = (hb_pcount() == 4 ? 3 : hb_parni(8));
  int heigh;

  if (hb_pcount() > 4)
  {

    rc.left = hb_parni(3);
    rc.top = hb_parni(4);
    rc.right = hb_parni(5);
    rc.bottom = hb_parni(6);
  }
  else
  {
    Array2Rect(hb_param(3, HB_IT_ARRAY), &rc);
  }

  heigh = DrawText(hwg_par_HDC(1), // handle of device context
                   lpText,         // address of string
                   (int)nLen,      // number of characters in string
                   &rc, uFormat);
  hb_strfree(hText);

  // if (HB_ISBYREF(uiPos))
  if (HB_ISARRAY(8))
  {
    hb_storvni(rc.left, 8, 1);
    hb_storvni(rc.top, 8, 2);
    hb_storvni(rc.right, 8, 3);
    hb_storvni(rc.bottom, 8, 4);
  }
  hb_retni(heigh);
}

HB_FUNC(HWG_GETTEXTMETRIC)
{
  TEXTMETRIC tm;
  PHB_ITEM aMetr = hb_itemArrayNew(8);
  PHB_ITEM temp;

  GetTextMetrics(hwg_par_HDC(1), // handle of device context
                 &tm             // address of text metrics structure
  );

  temp = hb_itemPutNL(NULL, tm.tmHeight);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmAveCharWidth);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmMaxCharWidth);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmExternalLeading);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmInternalLeading);
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmAscent);
  hb_itemArrayPut(aMetr, 6, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmDescent);
  hb_itemArrayPut(aMetr, 7, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, tm.tmWeight);
  hb_itemArrayPut(aMetr, 8, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GETTEXTSIZE)
{

  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
  SIZE sz;
  PHB_ITEM aMetr = hb_itemArrayNew(2);
  PHB_ITEM temp;

  GetTextExtentPoint32(hwg_par_HDC(1), lpText, (int)nLen, &sz);
  hb_strfree(hText);

  temp = hb_itemPutNL(NULL, sz.cx);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, sz.cy);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GETCLIENTRECT)
{
  RECT rc;
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  GetClientRect(hwg_par_HWND(1), &rc);

  temp = hb_itemPutNL(NULL, rc.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GETWINDOWRECT)
{
  RECT rc;
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  GetWindowRect(hwg_par_HWND(1), &rc);

  temp = hb_itemPutNL(NULL, rc.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, rc.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GETCLIENTAREA)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(1);
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  temp = hb_itemPutNL(NULL, pps->rcPaint.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, pps->rcPaint.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, pps->rcPaint.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, pps->rcPaint.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_SETTEXTCOLOR)
{
  COLORREF crColor = SetTextColor(hwg_par_HDC(1),     // handle of device context
                                  hwg_par_COLORREF(2) // text color
  );
  hb_retnl((LONG)crColor);
}

HB_FUNC(HWG_SETBKCOLOR)
{
  COLORREF crColor = SetBkColor(hwg_par_HDC(1),     // handle of device context
                                hwg_par_COLORREF(2) // text color
  );
  hb_retnl((LONG)crColor);
}

HB_FUNC(HWG_SETTRANSPARENTMODE)
{
  int iMode = SetBkMode(hwg_par_HDC(1), // handle of device context
                        (hb_parl(2)) ? TRANSPARENT : OPAQUE);
  hb_retl(iMode == TRANSPARENT);
}

HB_FUNC(HWG_GETTEXTCOLOR)
{
  hb_retnl((LONG)GetTextColor(hwg_par_HDC(1)));
}

HB_FUNC(HWG_GETBKCOLOR)
{
  hb_retnl((LONG)GetBkColor(hwg_par_HDC(1)));
}

/*
HB_FUNC(HWG_GETTEXTSIZE)
{

   HDC hdc = GetDC(hwg_par_HWND(1));
   SIZE size;
   PHB_ITEM aMetr = hb_itemArrayNew(2);
   PHB_ITEM temp;
   void * hString;

   GetTextExtentPoint32(hdc, HB_PARSTR(2, &hString, NULL),
      lpString,         // address of text string
      strlen(cbString), // number of characters in string
      &size            // address of structure for string size
   );
   hb_strfree(hString);

   temp = hb_itemPutNI(NULL, size.cx);
   hb_itemArrayPut(aMetr, 1, temp);
   hb_itemRelease(temp);

   temp = hb_itemPutNI(NULL, size.cy);
   hb_itemArrayPut(aMetr, 2, temp);
   hb_itemRelease(temp);

   hb_itemReturn(aMetr);
   hb_itemRelease(aMetr);

}
*/

HB_FUNC(HWG_EXTTEXTOUT)
{

  RECT rc;
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(8, &hText, &nLen);

  rc.left = hb_parni(4);
  rc.top = hb_parni(5);
  rc.right = hb_parni(6);
  rc.bottom = hb_parni(7);

  ExtTextOut(hwg_par_HDC(1), // handle to device context
             hb_parni(2),    // x-coordinate of reference point
             hb_parni(3),    // y-coordinate of reference point
             ETO_OPAQUE,     // text-output options
             &rc,            // optional clipping and/or opaquing rectangle
             lpText,         // points to string
             (int)nLen,      // number of characters in string
             NULL            // pointer to array of intercharacter spacing values
  );
  hb_strfree(hText);
}

HB_FUNC(HWG_WRITESTATUSWINDOW)
{
  void *hString;
  SendMessage(hwg_par_HWND(1), SB_SETTEXT, hb_parni(2), (LPARAM)HB_PARSTR(3, &hString, NULL));
  hb_strfree(hString);
}

HB_FUNC(HWG_WINDOWFROMDC)
{
  HB_RETHANDLE(WindowFromDC(hwg_par_HDC(1)));
}

/* CreateFont(fontName, nWidth, hHeight [,fnWeight] [,fdwCharSet],
              [,fdwItalic] [,fdwUnderline] [,fdwStrikeOut])
*/
HB_FUNC(HWG_CREATEFONT)
{
  HFONT hFont;
  int fnWeight = (HB_ISNIL(4)) ? 0 : hb_parni(4);
  DWORD fdwCharSet = (HB_ISNIL(5)) ? 0 : hb_parni(5);
  DWORD fdwItalic = (HB_ISNIL(6)) ? 0 : hb_parni(6);
  DWORD fdwUnderline = (HB_ISNIL(7)) ? 0 : hb_parni(7);
  DWORD fdwStrikeOut = (HB_ISNIL(8)) ? 0 : hb_parni(8);
  void *hString;

  hFont = CreateFont(hb_parni(3),                 // logical height of font
                     hb_parni(2),                 // logical average character width
                     0,                           // angle of escapement
                     0,                           // base-line orientation angle
                     fnWeight,                    // font weight
                     fdwItalic,                   // italic attribute flag
                     fdwUnderline,                // underline attribute flag
                     fdwStrikeOut,                // strikeout attribute flag
                     fdwCharSet,                  // character set identifier
                     0,                           // output precision
                     0,                           // clipping precision
                     0,                           // output quality
                     0,                           // pitch and family
                     HB_PARSTR(1, &hString, NULL) // pointer to typeface name string
  );
  hb_strfree(hString);
  HB_RETHANDLE(hFont);
}

/*
 * SetCtrlFont(hWnd, ctrlId, hFont)
 */
HB_FUNC(HWG_SETCTRLFONT)
{
  SendDlgItemMessage(hwg_par_HWND(1), hb_parni(2), WM_SETFONT, (WPARAM)HB_PARHANDLE(3), 0L);
}

HB_FUNC(HWG_OEMTOANSI)
{
  HB_FUNC_EXEC(HB_OEMTOANSI);
}

HB_FUNC(HWG_ANSITOOEM)
{
  HB_FUNC_EXEC(HB_ANSITOOEM);
}

HB_FUNC(HWG_CREATERECTRGN)
{
  HRGN reg;

  reg = CreateRectRgn(hb_parni(1), hb_parni(2), hb_parni(3), hb_parni(4));

  HB_RETHANDLE(reg);
}

HB_FUNC(HWG_CREATERECTRGNINDIRECT)
{
  HRGN reg;
  RECT rc;

  rc.left = hb_parni(2);
  rc.top = hb_parni(3);
  rc.right = hb_parni(4);
  rc.bottom = hb_parni(5);

  reg = CreateRectRgnIndirect(&rc);
  HB_RETHANDLE(reg);
}

HB_FUNC(HWG_EXTSELECTCLIPRGN)
{
  hb_retni(ExtSelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2), hb_parni(3)));
}

HB_FUNC(HWG_SELECTCLIPRGN)
{
  hb_retni(SelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2)));
}

HB_FUNC(HWG_CREATEFONTINDIRECT)
{
  LOGFONT lf;
  HFONT f;
  memset(&lf, 0, sizeof(LOGFONT));
  lf.lfQuality = (BYTE)hb_parni(4);
  lf.lfHeight = hb_parni(3);
  lf.lfWeight = hb_parni(2);
  HB_ITEMCOPYSTR(hb_param(1, HB_IT_ANY), lf.lfFaceName, HB_SIZEOFARRAY(lf.lfFaceName));
  lf.lfFaceName[HB_SIZEOFARRAY(lf.lfFaceName) - 1] = '\0';

  f = CreateFontIndirect(&lf);
  HB_RETHANDLE(f);
}

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(DEFINEPAINTSTRU, HWG_DEFINEPAINTSTRU)
HB_FUNC_TRANSLATE(BEGINPAINT, HWG_BEGINPAINT)
HB_FUNC_TRANSLATE(ENDPAINT, HWG_ENDPAINT)
HB_FUNC_TRANSLATE(DELETEDC, HWG_DELETEDC)
HB_FUNC_TRANSLATE(TEXTOUT, HWG_TEXTOUT)
HB_FUNC_TRANSLATE(DRAWTEXT, HWG_DRAWTEXT)
HB_FUNC_TRANSLATE(GETTEXTMETRIC, HWG_GETTEXTMETRIC)
HB_FUNC_TRANSLATE(GETTEXTSIZE, HWG_GETTEXTSIZE)
HB_FUNC_TRANSLATE(GETCLIENTRECT, HWG_GETCLIENTRECT)
HB_FUNC_TRANSLATE(GETWINDOWRECT, HWG_GETWINDOWRECT)
HB_FUNC_TRANSLATE(GETCLIENTAREA, HWG_GETCLIENTAREA)
HB_FUNC_TRANSLATE(SETTEXTCOLOR, HWG_SETTEXTCOLOR)
HB_FUNC_TRANSLATE(SETBKCOLOR, HWG_SETBKCOLOR)
HB_FUNC_TRANSLATE(SETTRANSPARENTMODE, HWG_SETTRANSPARENTMODE)
HB_FUNC_TRANSLATE(GETTEXTCOLOR, HWG_GETTEXTCOLOR)
HB_FUNC_TRANSLATE(GETBKCOLOR, HWG_GETBKCOLOR)
HB_FUNC_TRANSLATE(EXTTEXTOUT, HWG_EXTTEXTOUT)
HB_FUNC_TRANSLATE(WRITESTATUSWINDOW, HWG_WRITESTATUSWINDOW)
HB_FUNC_TRANSLATE(WINDOWFROMDC, HWG_WINDOWFROMDC)
HB_FUNC_TRANSLATE(CREATEFONT, HWG_CREATEFONT)
HB_FUNC_TRANSLATE(SETCTRLFONT, HWG_SETCTRLFONT)
HB_FUNC_TRANSLATE(OEMTOANSI, HWG_OEMTOANSI)
HB_FUNC_TRANSLATE(ANSITOOEM, HWG_ANSITOOEM)
HB_FUNC_TRANSLATE(CREATERECTRGN, HWG_CREATERECTRGN)
HB_FUNC_TRANSLATE(CREATERECTRGNINDIRECT, HWG_CREATERECTRGNINDIRECT)
HB_FUNC_TRANSLATE(EXTSELECTCLIPRGN, HWG_EXTSELECTCLIPRGN)
HB_FUNC_TRANSLATE(SELECTCLIPRGN, HWG_SELECTCLIPRGN)
HB_FUNC_TRANSLATE(CREATEFONTINDIRECT, HWG_CREATEFONTINDIRECT)
#endif
