/*
 * $Id: draw.c 2014 2013-03-12 06:31:24Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C level painting functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 */

// TODO: revision
#if defined(_MSC_VER)
#pragma warning(disable : 4201)
#pragma warning(disable : 4334)
#endif

#define OEMRESOURCE
#ifdef __DMC__
#define __DRAW_C__
#endif
#include "hwingui.h"
#include "incomp_pointer.h"
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>
#include "missing.h"

#if defined(__BORLANDC__) && __BORLANDC__ == 0x0550
#ifdef __cplusplus
extern "C"
{
  STDAPI OleLoadPicture(LPSTREAM, LONG, BOOL, REFIID, PVOID *);
}
#else
STDAPI OleLoadPicture(LPSTREAM, LONG, BOOL, REFIID, PVOID *);
#endif
#endif /* __BORLANDC__ */

#ifdef __cplusplus
#ifdef CINTERFACE
#undef CINTERFACE
#endif
#endif

#if defined(__HARBOURPP__)
typedef int(__stdcall *TRANSPARENTBLT)(HDC, int, int, int, int, HDC, int, int, int, int, int);
#else
typedef int(_stdcall *TRANSPARENTBLT)(HDC, int, int, int, int, HDC, int, int, int, int, int);
#endif

static TRANSPARENTBLT s_pTransparentBlt = NULL;

void TransparentBmp(HDC hDC, int x, int y, int nWidthDest, int nHeightDest, HDC dcImage, int bmWidth, int bmHeight,
                    int trColor)
{
  if (s_pTransparentBlt == NULL)
  {
    s_pTransparentBlt = (TRANSPARENTBLT)(void *)GetProcAddress(LoadLibrary(TEXT("MSIMG32.DLL")), "TransparentBlt");
  }
  s_pTransparentBlt(hDC, x, y, nWidthDest, nHeightDest, dcImage, 0, 0, bmWidth, bmHeight, trColor);
}

BOOL Array2Rect(PHB_ITEM aRect, RECT *rc)
{
  if (HB_IS_ARRAY(aRect) && hb_arrayLen(aRect) == 4)
  {
    rc->left = hb_arrayGetNL(aRect, 1);
    rc->top = hb_arrayGetNL(aRect, 2);
    rc->right = hb_arrayGetNL(aRect, 3);
    rc->bottom = hb_arrayGetNL(aRect, 4);
    return TRUE;
  }
  else
  {
    rc->left = rc->top = rc->right = rc->bottom = 0;
  }
  return FALSE;
}

PHB_ITEM Rect2Array(RECT *rc)
{
  PHB_ITEM aRect = hb_itemArrayNew(4);
  PHB_ITEM element = hb_itemNew(NULL);

  hb_arraySet(aRect, 1, hb_itemPutNL(element, rc->left));
  hb_arraySet(aRect, 2, hb_itemPutNL(element, rc->top));
  hb_arraySet(aRect, 3, hb_itemPutNL(element, rc->right));
  hb_arraySet(aRect, 4, hb_itemPutNL(element, rc->bottom));
  hb_itemRelease(element);
  return aRect;
}

HB_FUNC(HWG_GETPPSRECT)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(1);

  PHB_ITEM aMetr = Rect2Array(&pps->rcPaint);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

#if 0 // TODO: old code for reference (to be deleted)
HB_FUNC(HWG_GETPPSERASE)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(1);
  BOOL fErase = (BOOL)(&pps->fErase);
  hb_retni(fErase);
}
#endif

HB_FUNC(HWG_GETPPSERASE)
{
  PAINTSTRUCT *pps = (PAINTSTRUCT *)HB_PARHANDLE(1);
  BOOL fErase = pps->fErase;
  hb_retni(fErase);
}

HB_FUNC(HWG_GETUPDATERECT)
{
  HWND hWnd = hwg_par_HWND(1);
  BOOL fErase;
  fErase = GetUpdateRect(hWnd, NULL, 0);
  hb_retni(fErase);
}

HB_FUNC(HWG_INVALIDATERECT)
{
  RECT rc;

  if (hb_pcount() > 2)
  {
    rc.left = hb_parni(3);
    rc.top = hb_parni(4);
    rc.right = hb_parni(5);
    rc.bottom = hb_parni(6);
  }

  InvalidateRect(hwg_par_HWND(1),                // handle of window with changed update region
                 (hb_pcount() > 2) ? &rc : NULL, // address of rectangle coordinates
                 hb_parni(2)                     // erase-background flag
  );
}

HB_FUNC(HWG_MOVETO)
{
  HDC hDC = hwg_par_HDC(1);
  int x1 = hb_parni(2), y1 = hb_parni(3);
  MoveToEx(hDC, x1, y1, NULL);
}

HB_FUNC(HWG_LINETO)
{
  HDC hDC = hwg_par_HDC(1);
  int x1 = hb_parni(2), y1 = hb_parni(3);
  LineTo(hDC, x1, y1);
}

HB_FUNC(HWG_RECTANGLE)
{
  HDC hDC = hwg_par_HDC(1);
  int x1 = hb_parni(2), y1 = hb_parni(3), x2 = hb_parni(4), y2 = hb_parni(5);
  MoveToEx(hDC, x1, y1, NULL);
  LineTo(hDC, x2, y1);
  LineTo(hDC, x2, y2);
  LineTo(hDC, x1, y2);
  LineTo(hDC, x1, y1);
}

HB_FUNC(HWG_BOX)
{
  Rectangle(hwg_par_HDC(1), // handle of device context
            hb_parni(2),    // x-coord. of bounding rectangle's upper-left corner
            hb_parni(3),    // y-coord. of bounding rectangle's upper-left corner
            hb_parni(4),    // x-coord. of bounding rectangle's lower-right corner
            hb_parni(5)     // y-coord. of bounding rectangle's lower-right corner
  );
}

HB_FUNC(HWG_DRAWLINE)
{
  MoveToEx(hwg_par_HDC(1), hb_parni(2), hb_parni(3), NULL);
  LineTo(hwg_par_HDC(1), hb_parni(4), hb_parni(5));
}

HB_FUNC(HWG_PIE)
{
  int res = Pie(hwg_par_HDC(1), // handle to device context
                hb_parni(2),    // x-coord. of bounding rectangle's upper-left corner
                hb_parni(3),    // y-coord. of bounding rectangle's upper-left corner
                hb_parni(4),    // x-coord. of bounding rectangle's lower-right corner
                hb_parni(5),    // y-coord. bounding rectangle's f lower-right corner
                hb_parni(6),    // x-coord. of first radial's endpoint
                hb_parni(7),    // y-coord. of first radial's endpoint
                hb_parni(8),    // x-coord. of second radial's endpoint
                hb_parni(9)     // y-coord. of second radial's endpoint
  );

  hb_retnl(res ? 0 : (LONG)GetLastError());
}

HB_FUNC(HWG_ELLIPSE)
{
  int res = Ellipse(hwg_par_HDC(1), // handle to device context
                    hb_parni(2),    // x-coord. of bounding rectangle's upper-left corner
                    hb_parni(3),    // y-coord. of bounding rectangle's upper-left corner
                    hb_parni(4),    // x-coord. of bounding rectangle's lower-right corner
                    hb_parni(5)     // y-coord. bounding rectangle's f lower-right corner
  );

  hb_retnl(res ? 0 : (LONG)GetLastError());
}

HB_FUNC(HWG_FILLRECT)
{
  RECT rc;

  rc.left = hb_parni(2);
  rc.top = hb_parni(3);
  rc.right = hb_parni(4);
  rc.bottom = hb_parni(5);

  FillRect(HB_ISPOINTER(1) ? hwg_par_HDC(1)
                           : (HDC)(LONG_PTR)hb_parnl(1) /* TODO: pointer */, // handle to device context
           &rc,                                                              // pointer to structure with rectangle
           hwg_par_HBRUSH(6)                                                 // handle to brush
  );
}

HB_FUNC(HWG_ROUNDRECT)
{
  hb_parl(RoundRect(hwg_par_HDC(1), // handle of device context
                    hb_parni(2),    // x-coord. of bounding rectangle's upper-left corner
                    hb_parni(3),    // y-coord. of bounding rectangle's upper-left corner
                    hb_parni(4),    // x-coord. of bounding rectangle's lower-right corner
                    hb_parni(5),    // y-coord. of bounding rectangle's lower-right corner
                    hb_parni(6),    // width of ellipse used to draw rounded corners
                    hb_parni(7)     // height of ellipse used to draw rounded corners
                    ));
}
/*
HB_FUNC(HWG_REDRAWWINDOW)
{
   RedrawWindow(hwg_par_HWND(1),    // handle of window
         NULL,                  // address of structure with update rectangle
         NULL,                  // handle of update region
         (UINT) hb_parni(2) // array of redraw flags
          );
}
*/
HB_FUNC(HWG_REDRAWWINDOW)
{
  RECT rc;

  if (hb_pcount() > 3)
  {
    int x = (hb_pcount() > 3 && !HB_ISNIL(3)) ? hb_parni(3) : 0;
    int y = (hb_pcount() >= 4 && !HB_ISNIL(4)) ? hb_parni(4) : 0;
    int w = (hb_pcount() >= 5 && !HB_ISNIL(5)) ? hb_parni(5) : 0;
    int h = (hb_pcount() >= 6 && !HB_ISNIL(6)) ? hb_parni(6) : 0;
    rc.left = x - 1;
    rc.top = y - 1;
    rc.right = x + w + 1;
    rc.bottom = y + h + 1;
  }
  RedrawWindow(hwg_par_HWND(1),                // handle of window
               (hb_pcount() > 3) ? &rc : NULL, // address of structure with update rectangle
               NULL,                           // handle of update region
               hwg_par_UINT(2)                 // array of redraw flags
  );
}

HB_FUNC(HWG_DRAWBUTTON)
{
  RECT rc;
  HDC hDC = hwg_par_HDC(1);
  UINT iType = hb_parni(6);

  rc.left = hb_parni(2);
  rc.top = hb_parni(3);
  rc.right = hb_parni(4);
  rc.bottom = hb_parni(5);

  if (iType == 0)
  {
    FillRect(hDC, &rc, (HBRUSH)(COLOR_3DFACE + 1));
  }
  else
  {
    FillRect(hDC, &rc, (HBRUSH)(INT_PTR)(((iType & 2) ? COLOR_3DSHADOW : COLOR_3DHILIGHT) + 1));
    rc.left++;
    rc.top++;
    FillRect(hDC, &rc,
             (HBRUSH)(INT_PTR)(((iType & 2)   ? COLOR_3DHILIGHT
                                : (iType & 4) ? COLOR_3DDKSHADOW
                                              : COLOR_3DSHADOW) +
                               1));
    rc.right--;
    rc.bottom--;
    if (iType & 4)
    {
      FillRect(hDC, &rc, (HBRUSH)(INT_PTR)(((iType & 2) ? COLOR_3DSHADOW : COLOR_3DLIGHT) + 1));
      rc.left++;
      rc.top++;
      FillRect(hDC, &rc, (HBRUSH)(INT_PTR)(((iType & 2) ? COLOR_3DLIGHT : COLOR_3DSHADOW) + 1));
      rc.right--;
      rc.bottom--;
    }
    FillRect(hDC, &rc, (HBRUSH)(COLOR_3DFACE + 1));
  }
}

/*
 * DrawEdge(hDC,x1,y1,x2,y2,nFlag,nBorder)
 */
HB_FUNC(HWG_DRAWEDGE)
{
  RECT rc;
  HDC hDC = hwg_par_HDC(1);
  UINT edge = (HB_ISNIL(6)) ? EDGE_RAISED : hwg_par_UINT(6);
  UINT grfFlags = (HB_ISNIL(7)) ? BF_RECT : hwg_par_UINT(7);

  rc.left = hb_parni(2);
  rc.top = hb_parni(3);
  rc.right = hb_parni(4);
  rc.bottom = hb_parni(5);

  hb_retl(DrawEdge(hDC, &rc, edge, grfFlags));
}

HB_FUNC(HWG_LOADICON)
{
  if (HB_ISNUM(1))
  {
    HB_RETHANDLE(LoadIcon(NULL, MAKEINTRESOURCE(hb_parni(1))));
  }
  else
  {
    void *hString;
    HB_RETHANDLE(LoadIcon(GetModuleHandle(NULL), HB_PARSTR(1, &hString, NULL)));
    hb_strfree(hString);
  }
}

HB_FUNC(HWG_LOADIMAGE)
{
  void *hString = NULL;

  HB_RETHANDLE(LoadImage(
      HB_ISNIL(1) ? GetModuleHandle(NULL)
                  : (HINSTANCE)(LONG_PTR)hb_parnl(1), // handle of the instance that contains the image
      HB_ISNUM(2) ? MAKEINTRESOURCE(hb_parni(2)) : HB_PARSTR(2, &hString, NULL), // name or identifier of image
      hwg_par_UINT(3),                                                           // type of image
      hb_parni(4),                                                               // desired width
      hb_parni(5),                                                               // desired height
      hwg_par_UINT(6)                                                            // load flags
      ));
  hb_strfree(hString);
}

HB_FUNC(HWG_LOADBITMAP)
{
  if (HB_ISNUM(1))
  {
    if (!HB_ISNIL(2) && hb_parl(2))
    {
      HB_RETHANDLE(LoadBitmap(NULL, MAKEINTRESOURCE(hb_parni(1))));
    }
    else
      HB_RETHANDLE(LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(hb_parni(1))));
  }
  else
  {
    void *hString;
    HB_RETHANDLE(LoadBitmap(GetModuleHandle(NULL), HB_PARSTR(1, &hString, NULL)));
    hb_strfree(hString);
  }
}

/*
 * Window2Bitmap(hWnd)
 */
HB_FUNC(HWG_WINDOW2BITMAP)
{
  HWND hWnd = hwg_par_HWND(1);
  BOOL lFull = (HB_ISNIL(2)) ? 0 : (BOOL)hb_parl(2);
  HDC hDC = (lFull) ? GetWindowDC(hWnd) : GetDC(hWnd);
  HDC hDCmem = CreateCompatibleDC(hDC);
  HBITMAP hBitmap;
  RECT rc;

  if (lFull)
  {
    GetWindowRect(hWnd, &rc);
  }
  else
    GetClientRect(hWnd, &rc);

  hBitmap = CreateCompatibleBitmap(hDC, rc.right - rc.left, rc.bottom - rc.top);
  SelectObject(hDCmem, hBitmap);

  BitBlt(hDCmem, 0, 0, rc.right - rc.left, rc.bottom - rc.top, hDC, 0, 0, SRCCOPY);

  DeleteDC(hDCmem);
  DeleteDC(hDC);
  // hb_retnl((LONG) hBitmap);
  HB_RETHANDLE(hBitmap);
}

/*
 * DrawBitmap(hDC, hBitmap, style, x, y, width, height)
 */
HB_FUNC(HWG_DRAWBITMAP)
{
  HDC hDC = hwg_par_HDC(1);
  HDC hDCmem = CreateCompatibleDC(hDC);
  DWORD dwraster = (HB_ISNIL(3)) ? SRCCOPY : hwg_par_DWORD(3);
  HBITMAP hBitmap = hwg_par_HBITMAP(2);
  BITMAP bitmap;
  int nWidthDest = (hb_pcount() >= 5 && !HB_ISNIL(6)) ? hb_parni(6) : 0;
  int nHeightDest = (hb_pcount() >= 6 && !HB_ISNIL(7)) ? hb_parni(7) : 0;

  SelectObject(hDCmem, hBitmap);
  GetObject(hBitmap, sizeof(BITMAP), (LPVOID)&bitmap);
  if (nWidthDest && (nWidthDest != bitmap.bmWidth || nHeightDest != bitmap.bmHeight))
  {
    SetStretchBltMode(hDC, COLORONCOLOR);
    StretchBlt(hDC, hb_parni(4), hb_parni(5), nWidthDest, nHeightDest, hDCmem, 0, 0, bitmap.bmWidth, bitmap.bmHeight,
               dwraster);
  }
  else
  {
    BitBlt(hDC, hb_parni(4), hb_parni(5), bitmap.bmWidth, bitmap.bmHeight, hDCmem, 0, 0, dwraster);
  }

  DeleteDC(hDCmem);
}

/*
 * DrawTransparentBitmap(hDC, hBitmap, x, y [,trColor])
 */
HB_FUNC(HWG_DRAWTRANSPARENTBITMAP)
{
  HDC hDC = hwg_par_HDC(1);
  HBITMAP hBitmap = hwg_par_HBITMAP(2);
  COLORREF trColor = (HB_ISNIL(5)) ? 0x00FFFFFF : hwg_par_COLORREF(5);
  COLORREF crOldBack = SetBkColor(hDC, 0x00FFFFFF);
  COLORREF crOldText = SetTextColor(hDC, 0);
  HBITMAP bitmapTrans;
  HBITMAP pOldBitmapImage, pOldBitmapTrans;
  BITMAP bitmap;
  HDC dcImage, dcTrans;
  int x = hb_parni(3);
  int y = hb_parni(4);
  int nWidthDest = (hb_pcount() >= 5 && !HB_ISNIL(6)) ? hb_parni(6) : 0;
  int nHeightDest = (hb_pcount() >= 6 && !HB_ISNIL(7)) ? hb_parni(7) : 0;

  // Create two memory dcs for the image and the mask
  dcImage = CreateCompatibleDC(hDC);
  dcTrans = CreateCompatibleDC(hDC);
  // Select the image into the appropriate dc
  pOldBitmapImage = (HBITMAP)SelectObject(dcImage, hBitmap);
  GetObject(hBitmap, sizeof(BITMAP), (LPVOID)&bitmap);
  // Create the mask bitmap
  bitmapTrans = CreateBitmap(bitmap.bmWidth, bitmap.bmHeight, 1, 1, NULL);
  // Select the mask bitmap into the appropriate dc
  pOldBitmapTrans = (HBITMAP)SelectObject(dcTrans, bitmapTrans);
  // Build mask based on transparent colour
  SetBkColor(dcImage, trColor);
  if (nWidthDest && (nWidthDest != bitmap.bmWidth || nHeightDest != bitmap.bmHeight))
  {
    /*
    BitBlt(dcTrans, 0, 0, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0,
          SRCCOPY);
    SetStretchBltMode(hDC, COLORONCOLOR);
    StretchBlt(hDC, 0, 0, nWidthDest, nHeightDest, dcImage, 0, 0,
          bitmap.bmWidth, bitmap.bmHeight, SRCINVERT);
    StretchBlt(hDC, 0, 0, nWidthDest, nHeightDest, dcTrans, 0, 0,
          bitmap.bmWidth, bitmap.bmHeight, SRCAND);
    StretchBlt(hDC, 0, 0, nWidthDest, nHeightDest, dcImage, 0, 0,
          bitmap.bmWidth, bitmap.bmHeight, SRCINVERT);
    */
    SetStretchBltMode(hDC, COLORONCOLOR);
    TransparentBmp(hDC, x, y, nWidthDest, nHeightDest, dcImage, bitmap.bmWidth, bitmap.bmHeight, trColor);
  }
  else
  {
    /*
    BitBlt(dcTrans, 0, 0, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0,
          SRCCOPY);
    // Do the work - True Mask method - cool if not actual display
    BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0,
          SRCINVERT);
    BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcTrans, 0, 0,
          SRCAND);
    BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0,
          SRCINVERT);
   */
    TransparentBmp(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcImage, bitmap.bmWidth, bitmap.bmHeight, trColor);
  }
  // Restore settings
  SelectObject(dcImage, pOldBitmapImage);
  SelectObject(dcTrans, pOldBitmapTrans);
  SetBkColor(hDC, crOldBack);
  SetTextColor(hDC, crOldText);

  DeleteObject(bitmapTrans);
  DeleteDC(dcImage);
  DeleteDC(dcTrans);
}

/*  SpreadBitmap(hDC, hWnd, hBitmap, style)
 */
HB_FUNC(HWG_SPREADBITMAP)
{
  HDC hDC = HB_ISPOINTER(1) ? hwg_par_HDC(1) : (HDC)(LONG_PTR)hb_parnl(1); // TODO: pointer
  HDC hDCmem = CreateCompatibleDC(hDC);
  DWORD dwraster = (HB_ISNIL(4)) ? SRCCOPY : hwg_par_DWORD(4);
  HBITMAP hBitmap = hwg_par_HBITMAP(3);
  BITMAP bitmap;
  RECT rc;

  SelectObject(hDCmem, hBitmap);
  GetObject(hBitmap, sizeof(BITMAP), (LPVOID)&bitmap);
  GetClientRect(hwg_par_HWND(2), &rc);

  while (rc.top < rc.bottom)
  {
    while (rc.left < rc.right)
    {
      BitBlt(hDC, rc.left, rc.top, bitmap.bmWidth, bitmap.bmHeight, hDCmem, 0, 0, dwraster);
      rc.left += bitmap.bmWidth;
    }
    rc.left = 0;
    rc.top += bitmap.bmHeight;
  }

  DeleteDC(hDCmem);
}

/*  CenterBitmap(hDC, hWnd, hBitmap, style, brush)
 */

HB_FUNC(HWG_CENTERBITMAP)
{
  HDC hDC = hwg_par_HDC(1);
  HDC hDCmem = CreateCompatibleDC(hDC);
  DWORD dwraster = (HB_ISNIL(4)) ? SRCCOPY : hwg_par_DWORD(4);
  HBITMAP hBitmap = hwg_par_HBITMAP(3);
  BITMAP bitmap;
  RECT rc;
  HBRUSH hBrush = (HB_ISNIL(5)) ? (HBRUSH)(COLOR_WINDOW + 1) : hwg_par_HBRUSH(5);

  SelectObject(hDCmem, hBitmap);
  GetObject(hBitmap, sizeof(BITMAP), (LPVOID)&bitmap);
  GetClientRect(hwg_par_HWND(2), &rc);

  FillRect(hDC, &rc, hBrush);
  BitBlt(hDC, (rc.right - bitmap.bmWidth) / 2, (rc.bottom - bitmap.bmHeight) / 2, bitmap.bmWidth, bitmap.bmHeight,
         hDCmem, 0, 0, dwraster);

  DeleteDC(hDCmem);
}

HB_FUNC(HWG_GETBITMAPSIZE)
{
  BITMAP bitmap;
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;
  int nret;

  nret = GetObject(hwg_par_HBITMAP(1), sizeof(BITMAP), (LPVOID)&bitmap);

  temp = hb_itemPutNL(NULL, bitmap.bmWidth);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, bitmap.bmHeight);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, bitmap.bmBitsPixel);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, nret);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GETICONSIZE)
{
  ICONINFO iinfo;
  PHB_ITEM aMetr = hb_itemArrayNew(3);
  PHB_ITEM temp;
  int nret;

  nret = GetIconInfo(hwg_par_HICON(1), &iinfo);

  temp = hb_itemPutNL(NULL, iinfo.xHotspot * 2);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, iinfo.yHotspot * 2);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, nret);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_OPENBITMAP)
{
  BITMAPFILEHEADER bmfh;
  BITMAPINFOHEADER bmih;
  LPBITMAPINFO lpbmi;
  DWORD dwRead;
  LPVOID lpvBits;
  HGLOBAL hmem1, hmem2;
  HBITMAP hbm;
  HDC hDC = (hb_pcount() > 1 && !HB_ISNIL(2)) ? hwg_par_HDC(2) : NULL;
  void *hString;
  HANDLE hfbm;

  hfbm = CreateFile(HB_PARSTR(1, &hString, NULL), GENERIC_READ, FILE_SHARE_READ, (LPSECURITY_ATTRIBUTES)NULL,
                    OPEN_EXISTING, FILE_ATTRIBUTE_READONLY, (HANDLE)NULL);
  hb_strfree(hString);
  if (((long int)(LONG_PTR)hfbm) <= 0)
  {
    HB_RETHANDLE(NULL);
    return;
  }
  /* Retrieve the BITMAPFILEHEADER structure. */
  ReadFile(hfbm, &bmfh, sizeof(BITMAPFILEHEADER), &dwRead, NULL);

  /* Retrieve the BITMAPFILEHEADER structure. */
  ReadFile(hfbm, &bmih, sizeof(BITMAPINFOHEADER), &dwRead, NULL);

  /* Allocate memory for the BITMAPINFO structure. */

  hmem1 = GlobalAlloc(GHND, sizeof(BITMAPINFOHEADER) + ((1 << bmih.biBitCount) * sizeof(RGBQUAD)));
  lpbmi = (LPBITMAPINFO)GlobalLock(hmem1);

  /*  Load BITMAPINFOHEADER into the BITMAPINFO  structure. */
  lpbmi->bmiHeader.biSize = bmih.biSize;
  lpbmi->bmiHeader.biWidth = bmih.biWidth;
  lpbmi->bmiHeader.biHeight = bmih.biHeight;
  lpbmi->bmiHeader.biPlanes = bmih.biPlanes;

  lpbmi->bmiHeader.biBitCount = bmih.biBitCount;
  lpbmi->bmiHeader.biCompression = bmih.biCompression;
  lpbmi->bmiHeader.biSizeImage = bmih.biSizeImage;
  lpbmi->bmiHeader.biXPelsPerMeter = bmih.biXPelsPerMeter;
  lpbmi->bmiHeader.biYPelsPerMeter = bmih.biYPelsPerMeter;
  lpbmi->bmiHeader.biClrUsed = bmih.biClrUsed;
  lpbmi->bmiHeader.biClrImportant = bmih.biClrImportant;

  /*  Retrieve the color table.
   * 1 << bmih.biBitCount == 2 ^ bmih.biBitCount
   */
  switch (bmih.biBitCount)
  {
  case 1:
  case 4:
  case 8:
    ReadFile(hfbm, lpbmi->bmiColors, ((1 << bmih.biBitCount) * sizeof(RGBQUAD)), &dwRead, (LPOVERLAPPED)NULL);
    break;

  case 16:
  case 32:
    if (bmih.biCompression == BI_BITFIELDS)
    {
      ReadFile(hfbm, lpbmi->bmiColors, (3 * sizeof(RGBQUAD)), &dwRead, (LPOVERLAPPED)NULL);
    }
    break;

  case 24:
    break;
  }

  /* Allocate memory for the required number of  bytes. */
  hmem2 = GlobalAlloc(GHND, (bmfh.bfSize - bmfh.bfOffBits));
  lpvBits = GlobalLock(hmem2);

  /* Retrieve the bitmap data. */

  ReadFile(hfbm, lpvBits, (bmfh.bfSize - bmfh.bfOffBits), &dwRead, NULL);

  if (!hDC)
  {
    hDC = GetDC(0);
  }

  /* Create a bitmap from the data stored in the .BMP file.  */
  hbm = CreateDIBitmap(hDC, &bmih, CBM_INIT, lpvBits, lpbmi, DIB_RGB_COLORS);

  if (hb_pcount() < 2 || HB_ISNIL(2))
  {
    ReleaseDC(0, hDC);
  }

  /* Unlock the global memory objects and close the .BMP file. */
  GlobalUnlock(hmem1);
  GlobalUnlock(hmem2);
  GlobalFree(hmem1);
  GlobalFree(hmem2);
  CloseHandle(hfbm);

  HB_RETHANDLE(hbm);
}

HB_FUNC(HWG_DRAWICON)
{
  DrawIcon(hwg_par_HDC(1), hb_parni(3), hb_parni(4), hwg_par_HICON(2));
}

HB_FUNC(HWG_GETSYSCOLOR)
{
  hb_retnl((LONG)GetSysColor(hb_parni(1)));
}

HB_FUNC(HWG_GETSYSCOLORBRUSH)
{
  HB_RETHANDLE(GetSysColorBrush(hb_parni(1)));
}

HB_FUNC(HWG_CREATEPEN)
{
  HB_RETHANDLE(CreatePen(hb_parni(1),        // pen style
                         hb_parni(2),        // pen width
                         hwg_par_COLORREF(3) // pen color
                         ));
}

HB_FUNC(HWG_CREATESOLIDBRUSH)
{
  HB_RETHANDLE(CreateSolidBrush(hwg_par_COLORREF(1) /* brush color */));
}

HB_FUNC(HWG_CREATEHATCHBRUSH)
{
  HB_RETHANDLE(CreateHatchBrush(hb_parni(1), hwg_par_COLORREF(2)));
}

HB_FUNC(HWG_SELECTOBJECT)
{
  HB_RETHANDLE(SelectObject(hwg_par_HDC(1),    // handle of device context
                            hwg_par_HGDIOBJ(2) // handle of object
                            ));
}

HB_FUNC(HWG_DELETEOBJECT)
{
  DeleteObject(hwg_par_HGDIOBJ(1) // handle of object
  );
}

HB_FUNC(HWG_GETDC)
{
  HB_RETHANDLE(GetDC(hwg_par_HWND(1)));
}

// TODO: change return to integer or bool
HB_FUNC(HWG_RELEASEDC)
{
  HB_RETHANDLE((INT_PTR)ReleaseDC(hwg_par_HWND(1), hwg_par_HDC(2)));
}

HB_FUNC(HWG_GETDRAWITEMINFO)
{

  DRAWITEMSTRUCT *lpdis = (DRAWITEMSTRUCT *)HB_PARHANDLE(1); // hb_parnl(1);
  PHB_ITEM aMetr = hb_itemArrayNew(9);
  PHB_ITEM temp;

  temp = hb_itemPutNL(NULL, lpdis->itemID);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->itemAction);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = HB_PUTHANDLE(NULL, lpdis->hDC);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->rcItem.left);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->rcItem.top);
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->rcItem.right);
  hb_itemArrayPut(aMetr, 6, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->rcItem.bottom);
  hb_itemArrayPut(aMetr, 7, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, (LONG)(LONG_PTR)lpdis->hwndItem);
  hb_itemArrayPut(aMetr, 8, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, (LONG)lpdis->itemState);
  hb_itemArrayPut(aMetr, 9, temp);
  hb_itemRelease(temp);

  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

/*
 * DrawGrayBitmap(hDC, hBitmap, x, y)
 */
HB_FUNC(HWG_DRAWGRAYBITMAP)
{
  HDC hDC = hwg_par_HDC(1);
  HBITMAP hBitmap = hwg_par_HBITMAP(2);
  HBITMAP bitmapgray;
  HBITMAP pOldBitmapImage, pOldbitmapgray;
  BITMAP bitmap;
  HDC dcImage, dcTrans;
  int x = hb_parni(3);
  int y = hb_parni(4);

  SetBkColor(hDC, GetSysColor(COLOR_BTNHIGHLIGHT));
  // SetTextColor(hDC, GetSysColor(COLOR_BTNFACE));
  SetTextColor(hDC, GetSysColor(COLOR_BTNSHADOW));
  // Create two memory dcs for the image and the mask
  dcImage = CreateCompatibleDC(hDC);
  dcTrans = CreateCompatibleDC(hDC);
  // Select the image into the appropriate dc
  pOldBitmapImage = (HBITMAP)SelectObject(dcImage, hBitmap);
  GetObject(hBitmap, sizeof(BITMAP), (LPVOID)&bitmap);
  // Create the mask bitmap
  bitmapgray = CreateBitmap(bitmap.bmWidth, bitmap.bmHeight, 1, 1, NULL);
  // Select the mask bitmap into the appropriate dc
  pOldbitmapgray = (HBITMAP)SelectObject(dcTrans, bitmapgray);
  // Build mask based on transparent colour
  SetBkColor(dcImage, RGB(255, 255, 255));
  BitBlt(dcTrans, 0, 0, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0, SRCCOPY);
  // Do the work - True Mask method - cool if not actual display
  BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0, SRCINVERT);
  BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcTrans, 0, 0, SRCAND);
  BitBlt(hDC, x, y, bitmap.bmWidth, bitmap.bmHeight, dcImage, 0, 0, SRCINVERT);
  // Restore settings
  SelectObject(dcImage, pOldBitmapImage);
  SelectObject(dcTrans, pOldbitmapgray);
  SetBkColor(hDC, GetPixel(hDC, 0, 0));
  SetTextColor(hDC, 0);

  DeleteObject(bitmapgray);
  DeleteDC(dcImage);
  DeleteDC(dcTrans);
}

#include <olectl.h>
#include <ole2.h>
#include <ocidl.h>

HB_FUNC(HWG_OPENIMAGE)
{
  const char *cFileName = hb_parc(1);
  BOOL lString = (HB_ISNIL(2)) ? 0 : hb_parl(2);
  int iFileSize;
  FILE *fp;
  // IPicture * pPic;
  LPPICTURE pPic;
  IStream *pStream;
  HGLOBAL hG;
  HBITMAP hBitmap = 0;

  if (lString)
  {
    iFileSize = (int)hb_parclen(1);
    hG = GlobalAlloc(GPTR, iFileSize);
    if (!hG)
    {
      HB_RETHANDLE(0);
      return;
    }
    memcpy((void *)hG, (void *)cFileName, iFileSize);
  }
  else
  {
    fp = fopen(cFileName, "rb");
    if (!fp)
    {
      HB_RETHANDLE(0);
      return;
    }

    fseek(fp, 0, SEEK_END);
    iFileSize = ftell(fp);
    hG = GlobalAlloc(GPTR, iFileSize);
    if (!hG)
    {
      fclose(fp);
      HB_RETHANDLE(0);
      return;
    }
    fseek(fp, 0, SEEK_SET);
    fread((void *)hG, 1, iFileSize, fp);
    fclose(fp);
  }

  CreateStreamOnHGlobal(hG, 0, &pStream);

  if (!pStream)
  {
    GlobalFree(hG);
    HB_RETHANDLE(0);
    return;
  }

#if defined(__cplusplus)
  OleLoadPicture(pStream, 0, 0, IID_IPicture, (void **)&pPic);
  pStream->Release();
#else
  OleLoadPicture(pStream, 0, 0, &IID_IPicture, (void **)(void *)&pPic);
  pStream->lpVtbl->Release(pStream);
#endif

  GlobalFree(hG);

  if (!pPic)
  {
    HB_RETHANDLE(0);
    return;
  }

#if defined(__cplusplus)
  pPic->get_Handle((OLE_HANDLE *)&hBitmap);
#else
  pPic->lpVtbl->get_Handle(pPic, (OLE_HANDLE *)(void *)&hBitmap);
#endif

  HB_RETHANDLE(CopyImage(hBitmap, IMAGE_BITMAP, 0, 0, LR_COPYRETURNORG));

#if defined(__cplusplus)
  pPic->Release();
#else
  pPic->lpVtbl->Release(pPic);
#endif
}

HB_FUNC(HWG_PATBLT)
{
  hb_retl(PatBlt(hwg_par_HDC(1), hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5), hb_parnl(6)));
}

HB_FUNC(HWG_SAVEDC)
{
  hb_retl(SaveDC(hwg_par_HDC(1)));
}

HB_FUNC(HWG_RESTOREDC)
{
  hb_retl(RestoreDC(hwg_par_HDC(1), hb_parni(2)));
}

HB_FUNC(HWG_CREATECOMPATIBLEDC)
{
  HDC hDC = hwg_par_HDC(1);
  HDC hDCmem = CreateCompatibleDC(hDC);

  HB_RETHANDLE(hDCmem);
}

HB_FUNC(HWG_SETMAPMODE)
{
  HDC hDC = hwg_par_HDC(1);

  hb_retni(SetMapMode(hDC, hb_parni(2)));
}

HB_FUNC(HWG_SETWINDOWORGEX)
{
  HDC hDC = hwg_par_HDC(1);

  SetWindowOrgEx(hDC, hb_parni(2), hb_parni(3), NULL);
  hb_stornl(0, 4);
}

HB_FUNC(HWG_SETWINDOWEXTEX)
{
  HDC hDC = hwg_par_HDC(1);

  SetWindowExtEx(hDC, hb_parni(2), hb_parni(3), NULL);
  hb_stornl(0, 4);
}

HB_FUNC(HWG_SETVIEWPORTORGEX)
{
  HDC hDC = hwg_par_HDC(1);

  SetViewportOrgEx(hDC, hb_parni(2), hb_parni(3), NULL);
  hb_stornl(0, 4);
}

HB_FUNC(HWG_SETVIEWPORTEXTEX)
{
  HDC hDC = hwg_par_HDC(1);

  SetViewportExtEx(hDC, hb_parni(2), hb_parni(3), NULL);
  hb_stornl(0, 4);
}

HB_FUNC(HWG_SETARCDIRECTION)
{
  HDC hDC = hwg_par_HDC(1);

  hb_retni(SetArcDirection(hDC, hb_parni(2)));
}

HB_FUNC(HWG_SETROP2)
{
  HDC hDC = hwg_par_HDC(1);

  hb_retni(SetROP2(hDC, hb_parni(2)));
}

HB_FUNC(HWG_BITBLT)
{
  HDC hDC = hwg_par_HDC(1);
  HDC hDC1 = hwg_par_HDC(6);

  hb_retl(BitBlt(hDC, hb_parni(2), hb_parni(3), hb_parni(4), hb_parni(5), hDC1, hb_parni(7), hb_parni(8), hb_parnl(9)));
}

HB_FUNC(HWG_CREATECOMPATIBLEBITMAP)
{
  HDC hDC = hwg_par_HDC(1);
  HBITMAP hBitmap;
  hBitmap = CreateCompatibleBitmap(hDC, hb_parni(2), hb_parni(3));

  HB_RETHANDLE(hBitmap);
}

HB_FUNC(HWG_INFLATERECT)
{
  RECT pRect;
  int x = hb_parni(2);
  int y = hb_parni(3);

  if (HB_ISARRAY(1))
  {
    Array2Rect(hb_param(1, HB_IT_ARRAY), &pRect);
  }
  hb_retl(InflateRect(&pRect, x, y));

  hb_storvni(pRect.left, 1, 1);
  hb_storvni(pRect.top, 1, 2);
  hb_storvni(pRect.right, 1, 3);
  hb_storvni(pRect.bottom, 1, 4);
}

HB_FUNC(HWG_FRAMERECT)
{
  HDC hdc = hwg_par_HDC(1);
  HBRUSH hbr = hwg_par_HBRUSH(3);
  RECT pRect;

  if (HB_ISARRAY(2))
  {
    Array2Rect(hb_param(2, HB_IT_ARRAY), &pRect);
  }

  hb_retni(FrameRect(hdc, &pRect, hbr));
}

HB_FUNC(HWG_DRAWFRAMECONTROL)
{
  HDC hdc = hwg_par_HDC(1);
  RECT pRect;
  UINT uType = hb_parni(3);  // frame-control type
  UINT uState = hb_parni(4); // frame-control state

  if (HB_ISARRAY(2))
  {
    Array2Rect(hb_param(2, HB_IT_ARRAY), &pRect);
  }

  hb_retl(DrawFrameControl(hdc, &pRect, uType, uState));
}

HB_FUNC(HWG_OFFSETRECT)
{
  RECT pRect;
  int x = hb_parni(2);
  int y = hb_parni(3);

  if (HB_ISARRAY(1))
  {
    Array2Rect(hb_param(1, HB_IT_ARRAY), &pRect);
  }

  hb_retl(OffsetRect(&pRect, x, y));
  hb_storvni(pRect.left, 1, 1);
  hb_storvni(pRect.top, 1, 2);
  hb_storvni(pRect.right, 1, 3);
  hb_storvni(pRect.bottom, 1, 4);
}

HB_FUNC(HWG_DRAWFOCUSRECT)
{
  RECT pRect;
  HDC hc = hwg_par_HDC(1);
  if (HB_ISARRAY(2))
  {
    Array2Rect(hb_param(2, HB_IT_ARRAY), &pRect);
  }
  hb_retl(DrawFocusRect(hc, &pRect));
}

BOOL Array2Point(PHB_ITEM aPoint, POINT *pt)
{
  if (HB_IS_ARRAY(aPoint) && hb_arrayLen(aPoint) == 2)
  {
    pt->x = hb_arrayGetNL(aPoint, 1);
    pt->y = hb_arrayGetNL(aPoint, 2);
    return TRUE;
  }
  return FALSE;
}

HB_FUNC(HWG_PTINRECT)
{
  POINT pt;
  RECT rect;

  Array2Rect(hb_param(1, HB_IT_ARRAY), &rect);
  Array2Point(hb_param(2, HB_IT_ARRAY), &pt);
  hb_retl(PtInRect(&rect, pt));
}

HB_FUNC(HWG_GETMEASUREITEMINFO)
{
  MEASUREITEMSTRUCT *lpdis = (MEASUREITEMSTRUCT *)HB_PARHANDLE(1); // hb_parnl(1);
  PHB_ITEM aMetr = hb_itemArrayNew(5);
  PHB_ITEM temp;

  temp = hb_itemPutNL(NULL, lpdis->CtlType);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->CtlID);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->itemID);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->itemWidth);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(NULL, lpdis->itemHeight);
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);
  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_COPYRECT)
{
  RECT p;

  Array2Rect(hb_param(1, HB_IT_ARRAY), &p);
  hb_itemRelease(hb_itemReturn(Rect2Array(&p)));
}

HB_FUNC(HWG_GETWINDOWDC)
{
  HWND hWnd = hwg_par_HWND(1);
  HDC hDC = GetWindowDC(hWnd);
  HB_RETHANDLE(hDC);
}

HB_FUNC(HWG_MODIFYSTYLE)
{
  HWND hWnd = hwg_par_HWND(1);
  DWORD dwStyle = (DWORD)GetWindowLongPtr((HWND)hWnd, GWL_STYLE);
  DWORD a = hb_parnl(2);
  DWORD b = hb_parnl(3);
  DWORD dwNewStyle = (dwStyle & ~a) | b;
  SetWindowLongPtr(hWnd, GWL_STYLE, dwNewStyle);
}

/*
HB_FUNC(HWG_PTRRECT2ARRAY)
{
   RECT *rect = (RECT *) HB_PARHANDLE(1);
   hb_itemRelease(hb_itemReturn(Rect2Array(&rect)));
}
*/

#ifdef HWG_DEPRECATED_FUNCTIONS_ON
HB_FUNC_TRANSLATE(GETPPSRECT, HWG_GETPPSRECT)
HB_FUNC_TRANSLATE(GETPPSERASE, HWG_GETPPSERASE)
HB_FUNC_TRANSLATE(GETUPDATERECT, HWG_GETUPDATERECT)
HB_FUNC_TRANSLATE(INVALIDATERECT, HWG_INVALIDATERECT)
HB_FUNC_TRANSLATE(MOVETO, HWG_MOVETO)
HB_FUNC_TRANSLATE(LINETO, HWG_LINETO)
HB_FUNC_TRANSLATE(RECTANGLE, HWG_RECTANGLE)
HB_FUNC_TRANSLATE(BOX, HWG_BOX)
HB_FUNC_TRANSLATE(DRAWLINE, HWG_DRAWLINE)
HB_FUNC_TRANSLATE(PIE, HWG_PIE)
HB_FUNC_TRANSLATE(ELLIPSE, HWG_ELLIPSE)
HB_FUNC_TRANSLATE(FILLRECT, HWG_FILLRECT)
HB_FUNC_TRANSLATE(ROUNDRECT, HWG_ROUNDRECT)
HB_FUNC_TRANSLATE(REDRAWWINDOW, HWG_REDRAWWINDOW)
HB_FUNC_TRANSLATE(DRAWBUTTON, HWG_DRAWBUTTON)
HB_FUNC_TRANSLATE(DRAWEDGE, HWG_DRAWEDGE)
HB_FUNC_TRANSLATE(LOADICON, HWG_LOADICON)
HB_FUNC_TRANSLATE(LOADIMAGE, HWG_LOADIMAGE)
HB_FUNC_TRANSLATE(LOADBITMAP, HWG_LOADBITMAP)
HB_FUNC_TRANSLATE(WINDOW2BITMAP, HWG_WINDOW2BITMAP)
HB_FUNC_TRANSLATE(DRAWBITMAP, HWG_DRAWBITMAP)
HB_FUNC_TRANSLATE(DRAWTRANSPARENTBITMAP, HWG_DRAWTRANSPARENTBITMAP)
HB_FUNC_TRANSLATE(SPREADBITMAP, HWG_SPREADBITMAP)
HB_FUNC_TRANSLATE(CENTERBITMAP, HWG_CENTERBITMAP)
HB_FUNC_TRANSLATE(GETBITMAPSIZE, HWG_GETBITMAPSIZE)
HB_FUNC_TRANSLATE(GETICONSIZE, HWG_GETICONSIZE)
HB_FUNC_TRANSLATE(OPENBITMAP, HWG_OPENBITMAP)
HB_FUNC_TRANSLATE(DRAWICON, HWG_DRAWICON)
HB_FUNC_TRANSLATE(GETSYSCOLOR, HWG_GETSYSCOLOR)
HB_FUNC_TRANSLATE(GETSYSCOLORBRUSH, HWG_GETSYSCOLORBRUSH)
HB_FUNC_TRANSLATE(CREATEPEN, HWG_CREATEPEN)
HB_FUNC_TRANSLATE(CREATESOLIDBRUSH, HWG_CREATESOLIDBRUSH)
HB_FUNC_TRANSLATE(CREATEHATCHBRUSH, HWG_CREATEHATCHBRUSH)
HB_FUNC_TRANSLATE(SELECTOBJECT, HWG_SELECTOBJECT)
HB_FUNC_TRANSLATE(DELETEOBJECT, HWG_DELETEOBJECT)
HB_FUNC_TRANSLATE(GETDC, HWG_GETDC)
HB_FUNC_TRANSLATE(RELEASEDC, HWG_RELEASEDC)
HB_FUNC_TRANSLATE(GETDRAWITEMINFO, HWG_GETDRAWITEMINFO)
HB_FUNC_TRANSLATE(DRAWGRAYBITMAP, HWG_DRAWGRAYBITMAP)
HB_FUNC_TRANSLATE(OPENIMAGE, HWG_OPENIMAGE)
HB_FUNC_TRANSLATE(PATBLT, HWG_PATBLT)
HB_FUNC_TRANSLATE(SAVEDC, HWG_SAVEDC)
HB_FUNC_TRANSLATE(RESTOREDC, HWG_RESTOREDC)
HB_FUNC_TRANSLATE(CREATECOMPATIBLEDC, HWG_CREATECOMPATIBLEDC)
HB_FUNC_TRANSLATE(SETMAPMODE, HWG_SETMAPMODE)
HB_FUNC_TRANSLATE(SETWINDOWORGEX, HWG_SETWINDOWORGEX)
HB_FUNC_TRANSLATE(SETWINDOWEXTEX, HWG_SETWINDOWEXTEX)
HB_FUNC_TRANSLATE(SETVIEWPORTORGEX, HWG_SETVIEWPORTORGEX)
HB_FUNC_TRANSLATE(SETVIEWPORTEXTEX, HWG_SETVIEWPORTEXTEX)
HB_FUNC_TRANSLATE(SETARCDIRECTION, HWG_SETARCDIRECTION)
HB_FUNC_TRANSLATE(SETROP2, HWG_SETROP2)
HB_FUNC_TRANSLATE(BITBLT, HWG_BITBLT)
HB_FUNC_TRANSLATE(CREATECOMPATIBLEBITMAP, HWG_CREATECOMPATIBLEBITMAP)
HB_FUNC_TRANSLATE(INFLATERECT, HWG_INFLATERECT)
HB_FUNC_TRANSLATE(FRAMERECT, HWG_FRAMERECT)
HB_FUNC_TRANSLATE(DRAWFRAMECONTROL, HWG_DRAWFRAMECONTROL)
HB_FUNC_TRANSLATE(OFFSETRECT, HWG_OFFSETRECT)
HB_FUNC_TRANSLATE(DRAWFOCUSRECT, HWG_DRAWFOCUSRECT)
HB_FUNC_TRANSLATE(PTINRECT, HWG_PTINRECT)
HB_FUNC_TRANSLATE(GETMEASUREITEMINFO, HWG_GETMEASUREITEMINFO)
HB_FUNC_TRANSLATE(COPYRECT, HWG_COPYRECT)
HB_FUNC_TRANSLATE(GETWINDOWDC, HWG_GETWINDOWDC)
HB_FUNC_TRANSLATE(MODIFYSTYLE, HWG_MODIFYSTYLE)
//HB_FUNC_TRANSLATE(PTRRECT2ARRAY, HWG_PTRRECT2ARRAY)
#endif
