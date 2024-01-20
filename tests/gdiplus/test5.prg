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

   waGdiplusStartup()

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 ;
      ON PAINT {||
         LOCAL pPS
         LOCAL pDC
         LOCAL pGraphics
         LOCAL pBrush
         pPS := hwg_DefinePaintStru()
         pDC := hwg_BeginPaint(hwg_GetModalHandle(), pPS)
         waGdipCreateFromHDC(pDC, @pGraphics)
         waGdipCreateLineBrushI(waGpPoint():new(0, 0), waGpPoint():new(0, oDialog:nHeight), 0xFFFF0000, 0xFF0000FF, NIL, @pBrush)
         waGdipFillRectangleI(pGraphics, pBrush, 0, 0, oDialog:nWidth, oDialog:nHeight)
         waGdipDeleteBrush(pBrush)
         waGdipDeleteGraphics(pGraphics)
         hwg_EndPaint(hwg_GetModalHandle(), pPS)
      }

   @ 800 - 100 - 20, 600 - 32 - 20 BUTTON "Ok" SIZE 100, 32 ON CLICK {||oDialog:Close()}

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
