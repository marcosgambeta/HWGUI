#include "hwgui.ch"

FUNCTION Main()

   Local oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" AT 200, 0 SIZE 400, 100 COLOR COLOR_3DLIGHT

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Graph1" ACTION Graph1()
      MENUITEM "&Graph2" ACTION Graph2()
      MENUITEM "&Graph3" ACTION Graph3()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

Static Function Graph1
Local oModDlg
Local oFont := HFont():Add("MS Sans Serif", 0, -13)
Local oGraph
Local i, aGraph[1]

   aGraph[1] := {}
   FOR i := -40 TO 40
      Aadd(aGraph[1], {i, hwg_cos(i / 10)})
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10  SIZE 300, 300                  ;
           FONT oFont

   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 100 COLOR 65280
   // oGraph:oPen := HPen():Add(PS_SOLID, 2,oGraph:tcolor)

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||hwg_EndDialog()}

   ACTIVATE DIALOG oModDlg

Return Nil

Static Function Graph2
Local oModDlg
Local oFont := HFont():Add("MS Sans Serif", 0, -13)
Local oGraph
Local i, aGraph[1]

   aGraph[1] := {}
   FOR i := 1 TO 6
      Aadd(aGraph[1], {"", i * i})
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10  SIZE 300, 300                  ;
           FONT oFont

   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 200 COLOR 65280
   oGraph:nType := 2

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||hwg_EndDialog()}

   ACTIVATE DIALOG oModDlg

Return Nil

Static Function Graph3
Local oModDlg
Local oFont := HFont():Add("MS Sans Serif", 0, -13)
Local oGraph
Local i, aGraph[1]

   aGraph[1] := {}
   FOR i := 1 TO 6
      Aadd(aGraph[1], i * i)
   NEXT

   INIT DIALOG oModDlg CLIPPER TITLE "Graph"        ;
           AT 210, 10  SIZE 300, 300                  ;
           FONT oFont
/*
   @ 50, 30 GRAPH oGraph DATA aGraph SIZE 200, 200 COLOR 65280
   oGraph:nType := 3

   @ 90, 250 BUTTON "Close"  ;
       SIZE 120, 30          ;
       ON CLICK {||hwg_EndDialog()}
*/
   ACTIVATE DIALOG oModDlg

Return Nil