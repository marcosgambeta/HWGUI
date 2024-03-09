#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL cCB1
   LOCAL cCB2 := ""
   LOCAL cCB3 := "Item"
   LOCAL cCB4 := "Item4"

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   // cCB1 = NIL - do not select any item
   @ 40, 40 GET COMBOBOX cCB1 ITEMS {"Item1", "Item2", "Item3", "Item4"} SIZE 130, 30 TEXT

   // cCB2 = "" - do not select any item
   @ 40, 80 GET COMBOBOX cCB2 ITEMS {"Item1", "Item2", "Item3", "Item4"} SIZE 130, 30 TEXT

   // cCB3 = "Item" - do not select any item
   @ 40, 120 GET COMBOBOX cCB3 ITEMS {"Item1", "Item2", "Item3", "item4"} SIZE 130, 30 TEXT

   // cCB4 = "Item4" - select item 4
   @ 40, 160 GET COMBOBOX cCB4 ITEMS {"Item1", "Item2", "Item3", "Item4"} SIZE 130, 30 TEXT

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(cCB1, "Info")
   hwg_MsgInfo(cCB2, "Info")
   hwg_MsgInfo(cCB3, "Info")
   hwg_MsgInfo(cCB4, "Info")

RETURN
