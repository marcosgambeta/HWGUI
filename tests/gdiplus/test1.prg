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
         LOCAL pGraphics
         LOCAL pImage
         waGdipCreateFromHWND(oDialog:handle, @pGraphics)
         waGdipLoadImageFromFile("harbour.gif", @pImage)
         waGdipDrawImage(pGraphics, pImage, 0, 0)
         waGdipDisposeImage(pImage)
         waGdipDeleteGraphics(pGraphics)
      }

   ACTIVATE DIALOG oDialog

   waGdiplusShutdown()

RETURN
