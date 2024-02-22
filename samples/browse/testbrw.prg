#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Dialog" ACTION DlgGet()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION DlgGet()

   LOCAL oModDlg, oBrw1, oBrw2
   LOCAL aSample1 := {{"Alex", 17}, {"Victor", 42}, {"John", 31}}
   LOCAL aSample2 := {{.T., "Line 1", 10}, {.T., "Line 2", 22}, {.F., "Line 3", 40}}

   INIT DIALOG oModDlg TITLE "About" AT 190, 10 SIZE 400, 240

   @ 20, 30 BROWSE oBrw1 ARRAY SIZE 180, 110 ;
        STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   @ 210, 30 BROWSE oBrw2 ARRAY SIZE 180, 110 ;
        STYLE WS_BORDER + WS_VSCROLL + WS_HSCROLL

   @ 80, 180 OWNERBUTTON ON CLICK {||hwg_EndDialog()} ;
       SIZE 180, 35 FLAT                                  ;
       TEXT "Close" COLOR hwg_VColor("0000FF")

   hwg_CREATEARLIST(oBrw1, aSample1)

   hwg_CREATEARLIST(oBrw2, aSample2)
   oBmp := HBitmap():AddResource(OBM_CHECK)
   oBrw2:aColumns[1]:aBitmaps := {{{|l|l}, oBmp}}
   oBrw2:aColumns[2]:length := 6
   oBrw2:aColumns[3]:length := 4
   oBrw2:bKeyDown := {|o,key|BrwKey(o,key)}

   ACTIVATE DIALOG oModDlg

RETURN NIL

STATIC FUNCTION BrwKey(oBrw, key)

   IF key == 32
      oBrw:aArray[oBrw:nCurrent, 1] := !oBrw:aArray[oBrw:nCurrent, 1]
      oBrw:RefreshLine()
   ENDIF

RETURN .T.
