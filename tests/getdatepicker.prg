#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL dDate1 := date()
   LOCAL dDate2 := date() - 15
   LOCAL dDate3 := date() + 15

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480 FONT HFont():Add("Courier New", 0, -13)

   @ 40, 40 GET DATEPICKER dDate1 SIZE 130, 30
   
   @ 40, 80 GET DATEPICKER dDate2 SIZE 130, 30

   @ 40, 120 GET DATEPICKER dDate3 SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog
   
   hwg_MsgInfo(dtoc(dDate1), "Info")
   hwg_MsgInfo(dtoc(dDate2), "Info")
   hwg_MsgInfo(dtoc(dDate3), "Info")

RETURN
