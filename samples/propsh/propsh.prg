/*
 * HWGUI using sample
 * Property sheet
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Property Sheet" ACTION OpenConfig()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION OpenConfig
LOCAL aDlg1, aDlg2, aCombo := {"Aaaa", "Bbbb"}
LOCAL oBrw1, oBrw2
LOCAL aSample1 := {{"Alex", 17}, {"Victor", 42}, {"John", 31}}
LOCAL aSample2 := {{"Line 1", 10}, {"Line 2", 22}, {"Line 3", 40}}
LOCAL e1 := "Xxxx"

   INIT DIALOG aDlg1 FROM RESOURCE  "PAGE_1" ON EXIT {||hwg_Msginfo("Exit"), .T.}
   REDEFINE GET e1 ID 103

   INIT DIALOG aDlg2 FROM RESOURCE  "PAGE_2" ON EXIT {||.T.}
   REDEFINE COMBOBOX aCombo ID 101
   REDEFINE BROWSE oBrw1 ARRAY ID 104
   REDEFINE BROWSE oBrw2 ARRAY ID 105

   hwg_CREATEARLIST(oBrw1,aSample1)
   hwg_CREATEARLIST(oBrw2,aSample2)

   hwg_PropertySheet(hwg_Getactivewindow(),{aDlg1, aDlg2}, "Sheet Example")

RETURN NIL
