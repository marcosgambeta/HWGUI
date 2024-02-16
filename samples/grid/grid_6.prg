/*
 * $Id: grid_6.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HGrid class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
 * Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
 *
*/

#include "hwgui.ch"

#define LVS_REPORT              1
#define LVS_ICON                0x0000
#define LVS_SMALLICON           0x0002
#define LVS_LIST                0x0003

Static oMain, oForm, oFont, oGrid

Function Main()

   INIT WINDOW oMain MAIN TITLE "Grid Sample" AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28

                MENU OF oMain
                        MENUITEM "&Exit"      ACTION oMain:Close()
                        MENUITEM "&Grid Demo" ACTION Test()
                ENDMENU

        ACTIVATE WINDOW oMain
Return Nil

Function Test()
Local aHead :={}
Local n
Local aItems :={}
Local aStru

use test new
aStru := dbstruct()
for n :=1 to len(astru)
   aadd(aHead,aStru[n, 1])
next
go Top
while !eof()
 aadd(aItems,{first,last,city,str(salary, 10, 2)})
 skip
enddo

        PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11
        
        INIT DIALOG oForm CLIPPER NOEXIT TITLE "Grid Demo";
             FONT oFont ;
             AT 0, 0 SIZE 700, 425 ;
             STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU
//             on init {||SetGrid(oForm,oGrid,aItems)}
                
             @ 10, 10 GRIDEX oGrid OF oForm ID 800 SIZE 680, 375 ;
                     ITEMCOUNT 10000 ;                     
                     ON KEYDOWN {|oCtrl, key| OnKey(oCtrl, key) } ;
                     ON POSCHANGE {|oCtrl, nRow| OnPoschange(oCtrl, nRow) } ;
                     ON CLICK {|oCtrl| OnClick(oCtrl) } ;
                     COLOR hwg_VColor("D3D3D3");
                     ON DISPINFO {|oCtrl, nRow, nCol| OnDispInfo(oCtrl, nRow, nCol) } ;
                     BACKCOLOR hwg_VColor("BEBEBE")  ;
                     BITMAP {2, 3, 4, 5}   ITEMS aItems

             ADD COLUMN TO GRID oGrid HEADER aHead[1] WIDTH 150  bitmap 1
             ADD COLUMN TO GRID oGrid HEADER aHead[2] WIDTH 150  bitmap 2
             ADD COLUMN TO GRID oGrid HEADER aHead[3] WIDTH 150  bitmap 3
             ADD COLUMN TO GRID oGrid HEADER aHead[4] WIDTH 150  bitmap 4

             for n:=1 to len(aItems)
                ADDROWEX TO GRID oGrid ;
                   HEADER aItems[n, 1] BITMAP 0 COLOR hwg_Rgb(255, 12, 123) BACKCOLOR hwg_Rgb(192, 0, 255), ;
                   HEADER aItems[n, 2], ;
                   HEADER aItems[n, 3] BITMAP 3, ;
                   HEADER aItems[n, 1] BITMAP 1 COLOR hwg_Rgb(123, 122, 123) BACKCOLOR hwg_Rgb(192, 0, 255)
             next

             @ 0, 395 button "LVS_REPORT" size 95, 25 on click  {|| hwg_Listview_setview(oGrid:handle,LVS_REPORT)}
             @ 100, 395 button "LVS_ICON" size 95, 25 on click  {|| hwg_Listview_setview(oGrid:handle,LVS_ICON)}
             @ 200, 395 button "LVS_SMALLICON" size 95, 25 on click  {|| hwg_Listview_setview(oGrid:handle,LVS_SMALLICON)}
             @ 300, 395 button "LVS_LIST" size 95, 25 on click  {|| hwg_Listview_setview(oGrid:handle,LVS_LIST)}
             @ 700, 395 BUTTON "Close" SIZE 95, 25 ON CLICK {|| oForm:Close() }
             
        ACTIVATE DIALOG oForm 
                
Return Nil

Function OnKey(o, k)
//    hwg_Msginfo(str(k))
return nil    

Function OnPosChange(o, row)
//    hwg_Msginfo(str(row))
return nil

Function OnClick(o)
//    hwg_Msginfo("click")
return nil    

Function OnDispInfo(o, x, y)
return "Row: " + ltrim(str(x)) + " Col: " + ltrim(str(y))

