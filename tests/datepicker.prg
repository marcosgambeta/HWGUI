#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oDatePicker

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480 FONT HFont():Add("Courier New", 0, -13)

   @ 40, 40 DATEPICKER oDatePicker SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTONEX "&Ok" OF oDialog ID IDOK SIZE 100, 32 ;
      ON CLICK {||hwg_MsgInfo("Date: " + dtoc(oDatePicker:GetValue()), "Info"), oDialog:Close()}

   @ (320 - 100) / 2 + 320, 280 BUTTONEX "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

RETURN
