/*
 *$Id: testini.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HwGUI Samples
 * testini.prg - Test to use files ini
 */

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL cIniFile := "HwGui.ini"

   //Create the inifile
   IF !file(cIniFile)

      Hwg_WriteIni("Config", "WallParer", "No Paper", cIniFile)
      Hwg_WriteIni("Config", "DirHwGUima", "C:\HwGUI", cIniFile)
      Hwg_WriteIni("Print",  "Spoll",   "Epson LX 80", cIniFile)

    ENDIF


   INIT WINDOW oMainWindow MAIN TITLE "Example" AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Read Ini" ACTION ReadIni()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION ReadIni()
LOCAL cIniFile := "HwGui.ini"
hwg_Msginfo(Hwg_GetIni("Config", "WallParer", , cIniFile))
hwg_Msginfo(Hwg_GetIni("Config", "DirHwGUima",, cIniFile))
hwg_Msginfo(Hwg_GetIni("Print",  "Spoll", , cIniFile))
RETURN NIL
