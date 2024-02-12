#xcommand @ <nX>,<nY> SAY [ <oSay> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oSay> := ] HStatic():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<ctoolt>, ;
             <color>,<bcolor> );;
          [ <oSay>:name := <(oSay)> ]

#xcommand REDEFINE SAY   [ <oSay> CAPTION ] <cCaption>   ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oSay> := ] HStatic():Redefine( <oWnd>,<nId>,<cCaption>, ;
             <oFont>,<bInit>,<bSize>,<bDraw>,<ctoolt>,<color>,<bcolor> )
