#xcommand @ <nX>,<nY> SAY [ <lExt: EXTENDED,EXT> ] [ <oSay> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oSay> := ] HStaticEx():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<ctoolt>, ;
             <color>,<bcolor>,<.lTransp.>,<bClick>,<bDblClick>,<bOther> );;
          [ <oSay>:name := <(oSay)> ]

#xcommand REDEFINE SAY [ <lExt: EXTENDED,EXT> ] [ <oSay> CAPTION ] <cCaption>   ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oSay> := ] HStaticEx():Redefine( <oWnd>,<nId>,<cCaption>, ;
             <oFont>,<bInit>,<bSize>,<bDraw>,<ctoolt>,<color>,<bcolor>,<.lTransp.>,<bClick>,<bDblClick> )
