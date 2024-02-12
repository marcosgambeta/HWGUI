#xcommand @ <nX>,<nY> BUTTON [ <lExt: EXTENDED,EXT> ] [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oBut> := ] HButtonX():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>,<ctoolt>,<color>,<bcolor>,<bGfocus> );;
          [ <oBut>:name := <(oBut)> ]

#xcommand REDEFINE BUTTON [ <lExt: EXTENDED,EXT> ] [ <oBut> ]   ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ CAPTION <cCaption> ]     ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oBut> := ] HButtonX():Redefine( <oWnd>,<nId>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bClick>,<ctoolt>,<color>,<bcolor>,<cCaption>,<bGfocus> )
