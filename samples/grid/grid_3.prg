/*
 * $Id: grid_3.prg 2012 2013-03-07 09:03:56Z alkresin $
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
STATIC nCount := 50
STATIC conn
STATIC leof := .F.

FUNCTION Main()

   SET (_SET_DATEFORMAT, "yyyy-mm-dd")
   CriaBase()

   INIT WINDOW oMain MAIN TITLE "Postgres Sample Using low level functions" ;
      AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28

                MENU OF oMain
                        MENUITEM "&Exit"   ACTION oMain:Close()
                        MENUITEM "&Demo" ACTION Test()
                ENDMENU

        ACTIVATE WINDOW oMain

        res := PQexec(conn, "CLOSE cursor_1")
        PQclear(res)

        res := PQexec(conn, "END")
        PQclear(res)

        PQClose(conn)

RETURN NIL

FUNCTION Test()
        PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11

        INIT DIALOG oForm CLIPPER NOEXIT TITLE "Postgres Demo";
             FONT oFont ;
             AT 0, 0 SIZE 700, 425 ;
             STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

             @ 10, 10 GRID oGrid OF oForm SIZE 680, 375;
                     ITEMCOUNT 10000 ;
                     ON KEYDOWN {|oCtrl, key| OnKey(oCtrl, key) } ;
                     ON POSCHANGE {|oCtrl, nRow| OnPoschange(oCtrl, nRow) } ;
                     ON CLICK {|oCtrl| OnClick(oCtrl) } ;
                     ON DISPINFO {|oCtrl, nRow, nCol| OnDispInfo(oCtrl, nRow, nCol) } ;
                     COLOR hwg_VColor("D3D3D3");
                     BACKCOLOR hwg_VColor("BEBEBE")

                     /*
                     ON LOSTFOCUS {||hwg_Msginfo("lost focus")} ;
                     ON GETFOCUS {||hwg_Msginfo("get focus")}
                     */

             ADD COLUMN TO GRID oGrid HEADER "Code" WIDTH 50
             ADD COLUMN TO GRID oGrid HEADER "Date" WIDTH 80
             ADD COLUMN TO GRID oGrid HEADER "Description" WIDTH 100
                                                              
             @ 620, 395 BUTTON "Close" SIZE 75, 25 ON CLICK {||oForm:Close()}
             
        ACTIVATE DIALOG oForm
                
RETURN NIL

FUNCTION OnKey(o, k)
//    hwg_Msginfo(str(k))
RETURN NIL

FUNCTION OnPosChange(o, row)
//    hwg_Msginfo(str(row))
RETURN NIL    

FUNCTION OnClick(o)
//    hwg_Msginfo("click")
RETURN NIL    

FUNCTION OnDispInfo(o, x, y)

   LOCAL result := ""
   LOCAL i
    
    IF x > Lastrec() .AND. !lEof
        res := PQexec(conn, "FETCH FORWARD 10 FROM cursor_1")
        
        IF !ISCHARACTER(res)

            IF PQLastrec(res) != 10
                lEof := .T.
            end
            
            for i := 1 to PQLastrec(res)
                Append Blank
                Replace Code     WITH myval(PQGetvalue(res, i, 1), "N")
                Replace Creation WITH myval(PQGetvalue(res, i, 2), "D")
                Replace Descr    WITH myval(PQGetvalue(res, i, 3), "C")
            next
        else
            lEof := .T.
            
            hwg_Msginfo(res)
        
        ENDIF
        PQclear(res)              
    ENDIF
    
    IF x <= Lastrec()
        dbgoto(x)
        
        IF y == 1
            result := str(code)
        ELSEIF y == 2
            result := dtoc(creation)
        ELSEIF y == 3
            result := descr
        end            
    ENDIF        
    
Return result

FUNCTION CriaBase()
        IF File("trash.dbf")
            FErase("trash.dbf")
        END
                    
        DBCreate("trash.dbf", {{"code", "N", 10, 0},;
                               {"creation", "D",  8, 0},;
                               {"descr", "C", 40, 0}})
        
        USE trash                         
        
        conn := PQConnect("test", "localhost", "Rodrigo", "moreno", 5432)

        IF ISCHARACTER(conn)
            hwg_Msginfo(conn)
            quit
        ENDIF

        res := PQexec(conn, "drop table test")
        PQclear(res)    

        res := PQexec(conn, "create table test (code numeric(10), creation date, descr char(40))")
        PQclear(res)    

        For i := 1 to 100
            res := PQexec(conn, "insert into test (code,creation,descr) values (" + str(i) + ",'" + DtoC(date() + i) + "','test')")
            PQclear(res)
        Next
        
        res := PQexec(conn, "BEGIN")
        PQclear(res)    

        res := PQexec(conn, "DECLARE cursor_1 NO SCROLL CURSOR WITH HOLD FOR SELECT * FROM test")
        PQclear(res)
RETURN NIL


FUNCTION MyVal(xValue, type)

   LOCAL result

    IF valtype(xValue) == "U"
        IF type == "N"
            result := 0
        ELSEIF type == "D"
            result := CtoD("")
        ELSEIF type == "C"
            result := ""
        ENDIF
    ELSEIF type == "N"
        result := val(xvalue)
    ELSEIF type == "C"
        result := xvalue
    ELSEIF type == "D"
        result := CtoD(xvalue)    
    ENDIF
Return result