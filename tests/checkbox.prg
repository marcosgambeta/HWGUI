#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oCheckBox1
   LOCAL oCheckBox2
   LOCAL oCheckBox3
   LOCAL oCheckBox4
   LOCAL oCheckBox5

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480 ;
      FONT HFont():Add("Courier New", 0, -13) ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")}

   @ 160, 40 CHECKBOX oCheckBox1 CAPTION "CheckBox1" SIZE 300, 26

   @ 160, 80 CHECKBOX oCheckBox2 CAPTION "CheckBox2" SIZE 300, 26

   @ 160, 120 CHECKBOX oCheckBox3 CAPTION "CheckBox3" SIZE 300, 26

   @ 160, 160 CHECKBOX oCheckBox4 CAPTION "CheckBox4" SIZE 300, 26

   @ 160, 200 CHECKBOX oCheckBox5 CAPTION "CheckBox5" SIZE 300, 26

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

RETURN
