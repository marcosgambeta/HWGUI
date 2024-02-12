#xcommand ADD STATUS [<oStat>] [ TO <oWnd> ] ;
             [ ID <nId> ]           ;
             [ HEIGHT <nHeight> ]   ;
             [ ON INIT <bInit> ]    ;
             [ ON SIZE <bSize> ]    ;
             [ ON PAINT <bDraw> ]   ;
             [ ON DBLCLICK <bDblClick> ];
             [ ON RIGHTCLICK <bRClick> ];
             [ STYLE <nStyle> ]     ;
             [ FONT <oFont> ]       ;
             [ PARTS <aparts,...> ] ;
          => ;
          [ <oStat> := ] HStatus():New( <oWnd>,<nId>,<nStyle>,<oFont>,\{<aparts>\},<bInit>,;
             <bSize>,<bDraw>, <bRClick>, <bDblClick>, <nHeight> );;
          [ <oStat>:name := <(oStat)> ]
