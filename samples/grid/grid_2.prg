/*
 * $Id: grid_2.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HGrid class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 * Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
 *
 * This Sample use Postgres Library, you need to link libpq.lib and libhbpg.lib
 *
*/

#include "hwgui.ch"
#include "common.ch"

#translate hwg_Rgb(<nRed>, <nGreen>, <nBlue>) => (<nRed> + (<nGreen> * 256) + (<nBlue> * 65536))

STATIC oMain
STATIC oForm
STATIC oFont
STATIC oGrid
STATIC oServer
STATIC oQuery

FUNCTION Main()

        ConnectGrid()

   INIT WINDOW oMain MAIN TITLE "Grid Postgres Sample Using TPostgres" ;
      AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28

                MENU OF oMain
                        MENUITEM "&Exit"   ACTION oMain:Close()
                        MENUITEM "&Demo" ACTION Test()
                ENDMENU

        ACTIVATE WINDOW oMain

        oServer:Close()

RETURN NIL

FUNCTION Test()

        PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11

        INIT DIALOG oForm CLIPPER NOEXIT TITLE "Postgres Sample";
             FONT oFont ;
             AT 0, 0 SIZE 700, 425 ;
             STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

             @ 10, 10 GRID oGrid OF oForm SIZE 680, 375;
                     ITEMCOUNT oQuery:Lastrec() ;
                     COLOR hwg_VColor("D3D3D3");
                     BACKCOLOR hwg_Rgb(220, 220, 220) ;
                     ON DISPINFO {|oCtrl, nRow, nCol| valtoprg(oQuery:FieldGet(nRow, nCol)) }

             ADD COLUMN TO GRID oGrid HEADER "Column 1" WIDTH  50
             ADD COLUMN TO GRID oGrid HEADER "Column 2" WIDTH 200
             ADD COLUMN TO GRID oGrid HEADER "Column 3" WIDTH 100

             @ 620, 395 BUTTON "Close" SIZE 75, 25 ON CLICK {||oForm:Close()}

        ACTIVATE DIALOG oForm
RETURN NIL

FUNCTION ConnectGrid()

    LOCAL cHost := "Localhost"
    LOCAL cDatabase := "test"
    LOCAL cUser := "Rodrigo"
    LOCAL cPass := "moreno"
    LOCAL oRow, i

    oServer := TPQServer():New(cHost, cDatabase, cUser, cPass)

    IF oServer:NetErr()
        ? oServer:Error()
        quit
    end

    IF oServer:TableExists("test")
        oServer:DeleteTable("Test")
    ENDIF

    oServer:CreateTable("Test", {{"col1", "N", 6, 0},;
                                 {"col2", "C", 40, 0},;
                                 {"col3", "D", 8, 0}})

    oQuery := oServer:Query("SELECT * FROM test")

    For i := 1 to 100
        oRow := oQuery:blank()

        oRow:Fieldput(1, i)
        oRow:Fieldput(2, "teste line " + str(i))
        oRow:Fieldput(3, date() + i)

        oQuery:Append(oRow)
    Next

    oQuery:refresh()

RETURN NIL
