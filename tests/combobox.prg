#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oCB1
   LOCAL oCB2
   LOCAL oCB3

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 40, 40 COMBOBOX oCB1 ITEMS {"Item1", "Item2", "Item3"} INIT 1 SIZE 130, 30

   @ 40, 80 COMBOBOX oCB2 ITEMS {"Item1", "Item2", "Item3"} INIT 2 SIZE 130, 30

   @ 40, 120 COMBOBOX oCB3 ITEMS {"Item1", "Item2", "Item3"} INIT 3 SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(str(oCB1:value), "Info")
   hwg_MsgInfo(str(oCB2:value), "Info")
   hwg_MsgInfo(str(oCB3:value), "Info")

RETURN
