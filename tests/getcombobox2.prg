#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL cCB1 := "Item1"
   LOCAL cCB2 := "Item2"
   LOCAL cCB3 := "Item3"

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 40, 40 GET COMBOBOX cCB1 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30 TEXT

   @ 40, 80 GET COMBOBOX cCB2 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30 TEXT

   @ 40, 120 GET COMBOBOX cCB3 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30 TEXT

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(cCB1, "Info")
   hwg_MsgInfo(cCB2, "Info")
   hwg_MsgInfo(cCB3, "Info")

RETURN
