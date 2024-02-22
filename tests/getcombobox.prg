#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL nCB1 := 1
   LOCAL nCB2 := 2
   LOCAL nCB3 := 3

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 40, 40 GET COMBOBOX nCB1 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30

   @ 40, 80 GET COMBOBOX nCB2 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30

   @ 40, 120 GET COMBOBOX nCB3 ITEMS {"Item1", "Item2", "Item3"} SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(str(nCB1), "Info")
   hwg_MsgInfo(str(nCB2), "Info")
   hwg_MsgInfo(str(nCB3), "Info")

RETURN
