#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN MDI TITLE "Test" STYLE WS_CLIPCHILDREN

   MENU OF oMainWindow
      MENUITEM "&New child" ACTION NewChild()
      MENUITEM "&Exit" ACTION hwg_EndWindow()
   ENDMENU

   ACTIVATE WINDOW oMainWindow MAXIMIZED

RETURN

STATIC FUNCTION NewChild()

   STATIC nChildNum := 0

   LOCAL oChildWindow

   ++nChildNum

   INIT WINDOW oChildWindow MDICHILD TITLE "Child Window #" + alltrim(str(nChildNum)) ;
      AT 0, 0 SIZE 640, 480 ;
      STYLE WS_CHILD + WS_CAPTION + WS_SYSMENU + WS_MAXIMIZEBOX + WS_MINIMIZEBOX + WS_SIZEBOX

   ACTIVATE WINDOW oChildWindow CENTER

RETURN NIL
