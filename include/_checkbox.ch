// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> CHECKBOX [ <oCheck> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ INIT <lInit> ]           ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():New( <oWnd>,<nId>,<lInit>,,<nStyle>,<nX>,<nY>, ;
             <nWidth>,<nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>, ;
             <ctoolt>,<color>,<bcolor>,<bGfocus>,<.lEnter.>,<.lTransp.> );;
          [ <oCheck>:name := <(oCheck)> ]

#xcommand REDEFINE CHECKBOX [ <oCheck> ] ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <lInit>    ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():Redefine( <oWnd>,<nId>,<lInit>,,<oFont>, ;
             <bInit>,<bSize>,<bDraw>,<bClick>,<ctoolt>,<color>,<bcolor>,<bGfocus>,<.lEnter.> )
