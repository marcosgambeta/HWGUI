#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   IF oDialog:lResult
      hwg_MsgInfo("OK", "Info")
   ELSE
      hwg_MsgInfo("CANCEL", "Info")
   ENDIF

RETURN
