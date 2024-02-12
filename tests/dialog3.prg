#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow TITLE "Test" SIZE 800, 600

   MENU OF oMainWindow
      MENU TITLE "&Menu"
         MENUITEM "Dialog&1 (MODAL)" ACTION ShowDialog1()
         MENUITEM "Dialog&2 (NOMODAL)" ACTION ShowDialog2()
         SEPARATOR
         MENUITEM "E&xit" ACTION hwg_EndWindow()
      ENDMENU
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN

STATIC FUNCTION ShowDialog1()

   STATIC n := 0

   LOCAL oDialog
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL oEdit3
   LOCAL oEdit4
   LOCAL oEdit5

   ++n

   INIT DIALOG oDialog TITLE "Dialog (MODAL) " + alltrim(str(n)) ;
      SIZE 640, 480 FONT HFont():Add("Courier New", 0, -13) ;
      STYLE DS_CENTER ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")}

   @ 20, 40 SAY "Field&1 (ALT+1):" SIZE 130, 26
   @ 160, 40 EDITBOX oEdit1 CAPTION "" SIZE 300, 26

   @ 20, 80 SAY "Field&2 (ALT+2):" SIZE 130, 26
   @ 160, 80 EDITBOX oEdit2 CAPTION "" SIZE 300, 26

   @ 20, 120 SAY "Field&3 (ALT+3):" SIZE 130, 26
   @ 160, 120 EDITBOX oEdit3 CAPTION "" SIZE 300, 26

   @ 20, 160 SAY "Field&4 (ALT+4):" SIZE 130, 26
   @ 160, 160 EDITBOX oEdit4 CAPTION "" SIZE 300, 26

   @ 20, 200 SAY "Field&5 (ALT+5):" SIZE 130, 26
   @ 160, 200 EDITBOX oEdit5 CAPTION "" SIZE 300, 26

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

RETURN

STATIC FUNCTION ShowDialog2()

   STATIC n := 0

   LOCAL oDialog
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL oEdit3
   LOCAL oEdit4
   LOCAL oEdit5

   ++n

   INIT DIALOG oDialog TITLE "Dialog (NOMODAL) " + alltrim(str(n)) ;
      SIZE 640, 480 FONT HFont():Add("Verdana", 0, -13) ;
      STYLE DS_CENTER ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")}

   @ 20, 40 SAY "Field&1 (ALT+1):" SIZE 130, 26
   @ 160, 40 EDITBOX oEdit1 CAPTION "" SIZE 300, 26

   @ 20, 80 SAY "Field&2 (ALT+2):" SIZE 130, 26
   @ 160, 80 EDITBOX oEdit2 CAPTION "" SIZE 300, 26

   @ 20, 120 SAY "Field&3 (ALT+3):" SIZE 130, 26
   @ 160, 120 EDITBOX oEdit3 CAPTION "" SIZE 300, 26

   @ 20, 160 SAY "Field&4 (ALT+4):" SIZE 130, 26
   @ 160, 160 EDITBOX oEdit4 CAPTION "" SIZE 300, 26

   @ 20, 200 SAY "Field&5 (ALT+5):" SIZE 130, 26
   @ 160, 200 EDITBOX oEdit5 CAPTION "" SIZE 300, 26

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog NOMODAL

RETURN
