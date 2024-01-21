/*
 * HWGUI/GDI+ test
 *
 * Copyright (c) 2024 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
 *
 */

// Require Harbour++ and MS-Windows

#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oButton

   waGdiplusStartup()

   // resizable dialog (WS_THICKFRAME)

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;
      STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_THICKFRAME ;
      ON SIZE {|| ;
         oButton:move(oDialog:nWidth - 100 - 20, oDialog:nHeight - 32 - 20, 100, 32, .F.), ;
         waInvalidateRgn(hwg_GetModalHandle(), NIL, .T.)} ;
      ON PAINT {||
         LOCAL pPS
         LOCAL pDC
         LOCAL pGraphics
         LOCAL pBrush
         pPS := hwg_DefinePaintStru()
         pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
         waGdipCreateFromHDC(pDC, @pGraphics)
         waGdipCreateLineBrushI(waGpPoint():new(0, 0), waGpPoint():new(0, oDialog:nHeight), 0xFFADD8E6, 0xFF000000, NIL, @pBrush)
         waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oDialog:nWidth, oDialog:nHeight)
         waGdipDeleteBrush(pBrush)
         waGdipDeleteGraphics(pGraphics)
         hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON oButton CAPTION "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
