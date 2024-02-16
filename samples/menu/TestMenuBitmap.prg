/*
 * $Id: TestMenuBitmap.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C level menu functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 * Copyright 2004 Sandro R. R. Freire <sandrorrfreire@yahoo.com.br>
 * Demo for use Bitmap in menu
*/

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMain

   PRIVATE oMenu

   INIT WINDOW oMain MAIN TITLE "Teste" AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28 // BACKGROUND BITMAP OBMP

   MENU OF oMain
      MENU TITLE "Samples"
         MENUITEM "&Exit" ID 1001 ACTION oMain:Close() BITMAP "..\image\exit_m.bmp"
         SEPARATOR
         MENUITEM "&New " ID 1002 ACTION hwg_Msginfo("New") BITMAP "..\image\new_m.bmp"
         MENUITEM "&Open" ID 1003 ACTION hwg_Msginfo("Open") BITMAP "..\image\open_m.bmp"
         MENUITEM "&Demo" ID 1004 ACTION Test()
         SEPARATOR
         MENUITEM "&Bitmap and a Text" ID 1005 ACTION Test()
      ENDMENU
   ENDMENU

   // The number ID is very important to use bitmap in menu
   MENUITEMBITMAP oMain ID 1005 BITMAP "..\image\logo.bmp"
   // Hwg_InsertBitmapMenu(oMain:Menu, 1005, "\hwgui\sourceoBmp:handle) // do not use bitmap empty

   ACTIVATE WINDOW oMain

RETURN NIL

FUNCTION Test()

   hwg_Msginfo("Test")

RETURN NIL
