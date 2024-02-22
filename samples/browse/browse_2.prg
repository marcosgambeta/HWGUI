/*
 * $Id: browse_2.prg 2012 2013-03-07 09:03:56Z alkresin $
 */

#include "hwgui.ch"
#include "common.ch"

STATIC oBrowse

FUNCTION Main()

   LOCAL oMain

   CreateDB()

   INIT WINDOW oMain MAIN TITLE "Browse Example - Database - Delphi Style" ;
      AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28

   MENU OF oMain
      MENUITEM "&Exit"   ACTION oMain:Close()
      MENUITEM "&Browse" ACTION BrowseTest_2()
   ENDMENU

   ACTIVATE WINDOW oMain

RETURN NIL

FUNCTION BrowseTest_2()

   LOCAL oForm, oFont

   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -10

   INIT DIALOG oForm CLIPPER NOEXIT TITLE "DBNavigator" AT 0, 0 SIZE 700, 435 FONT oFont ;
      STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

   @  5, 5 BROWSE oBrowse DATABASE OF oForm SIZE 690, 380 STYLE WS_VSCROLL + WS_HSCROLL APPEND;
   ON CLICK {||ReplaceIndex(oBrowse:colpos)}

   ADD COLUMN FieldBlock("field_1") TO oBrowse HEADER "Field 1" EDITABLE
   ADD COLUMN FieldBlock("field_2") TO oBrowse HEADER "Field 2" EDITABLE LENGTH 30

   DBNavigator(oBrowse, 5, 400)

   @ 530, 400 OWNERBUTTON OF oForm SIZE 80, 25 ;
               TEXT "Ok" FONT oFont COORDINATES 0, 0, 0, 0 ;
               BITMAP "b_ok" FROM RESOURCE  COORDINATES 5, 2, 21, 20 TRANSPARENT;
               ON CLICK {||oForm:close()}


   @ 615, 400 OWNERBUTTON OF oForm SIZE 80, 25 ;
               TEXT "Cancel" FONT oFont COORDINATES 31, 0, 60, 0 ;
               BITMAP "b_cancel" FROM RESOURCE  COORDINATES 5, 2, 21, 20 TRANSPARENT;
               ON CLICK {||oForm:close()}


   ACTIVATE DIALOG oForm

RETURN NIL

STATIC FUNCTION CreateDB()

    LOCAL i, letra := 100

    IF file("test.dbf")
            FErase("test.dbf")
    end
    IF file("index01.ntx")
       fErase("index01.ntx")
    ENDIF
    IF file("index02.ntx")
       fErase("index02.ntx")
    ENDIF

    DBCreate("test", {{"field_1", "N", 6, 0},;
                      {"field_2", "C", 40, 0}})

    USE test EXCLUSIVE
    IF !file("index01.ntx")
       index on field_1 to index01
    ENDIF
    IF !file("index02.ntx")
       index on field_2 to index02
    ENDIF
    set index to index01, index02

    For i := 1 to 100
        APPEND BLANK
        REPLACE Field_1 WITH i
        REPLACE Field_2 WITH Str(letra)+" Test" + Str(i)
        --letra
    Next

    DBGotop()

RETURN NIL

FUNCTION DBNavigator(oCtrl, nLeft, nTop, aAction, aHide)

    Default aAction To {},;
            aHide   To {}

    ASize(aAction, 10)
    ASize(aHide, 10)

    IF Empty(aHide[1])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_first" FROM RESOURCE  TRANSPARENT;
                  TOOLTIP "First Record" ;
                  ON CLICK iif(Empty(aAction[1]), {||oCtrl:Top()}, aAction[1])

        nLeft += 24

    ENDIF

    IF Empty(aHide[2])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_prior" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "Prior" ;
                  ON CLICK iif(Empty(aAction[2]), {||oCtrl:LineUp()}, aAction[2])

        nLeft += 24

    ENDIF

    IF Empty(aHide[3])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_next" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "Next" ;
                  ON CLICK iif(Empty(aAction[3]), {||oCtrl:LineDown()}, aAction[3])

        nLeft += 24

    ENDIF

    IF Empty(aHide[4])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_last" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "Last Record" ;
                  ON CLICK iif(Empty(aAction[4]), {||oCtrl:Bottom()}, aAction[4])

        nLeft += 24

    ENDIF

    IF Empty(aHide[5])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_append" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "New" ;
                  ON CLICK iif(Empty(aAction[5]), {||oCtrl:Append()}, aAction[5])

        nLeft += 24

    ENDIF

    IF Empty(aHide[6])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_delete" FROM RESOURCE TRANSPARENT ;
                  TOOLTIP "Delete" ;
                  ON CLICK iif(Empty(aAction[6]), {||IIF(hwg_Msgyesno("Confirma exclusão ?", "Exclusão"), DBDelete(), NIL), oCtrl:top(), oCtrl:refresh()}, aAction[6])

        nLeft += 24

    ENDIF

    IF Empty(aHide[7])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_edit" FROM RESOURCE TRANSPARENT ;
                  TOOLTIP "Edit" ;
                  ON CLICK iif(Empty(aAction[7]), {||oCtrl:edit()}, aAction[7])

        nLeft += 24

    ENDIF

    IF Empty(aHide[8])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_commit" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "Commit" ;
                  ON CLICK aAction[8]

        nLeft += 24

    ENDIF

    IF Empty(aHide[9])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_cancel" FROM RESOURCE TRANSPARENT;
                  TOOLTIP "Cancel" ;
                  ON CLICK aAction[9]

        nLeft += 24

    ENDIF

    IF Empty(aHide[10])

        @ nLeft, nTop OWNERBUTTON SIZE 24, 25 ;
                  BITMAP "t_refresh" FROM RESOURCE TRANSPARENT ;
                  TOOLTIP "Refresh" ;
                  ON CLICK iif(Empty(aAction[10]), {||oCtrl:refresh()}, aAction[10])

        nLeft += 24

    ENDIF

RETURN NIL

FUNCTION ReplaceIndex(oPos)

   IF !oBrowse:lAppMode
     hwg_Msginfo("Key press in col "+str(oPos))
     IF oPos==1
       Set Order to 1
     Else
       Set Order to 2
     EndIf
   ENDIF
   oBrowse:Refresh()

RETURN NIL
