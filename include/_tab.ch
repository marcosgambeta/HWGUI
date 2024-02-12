#xcommand @ <nX>,<nY> TAB [ <oTab> ITEMS ] <aItems> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CHANGE <bChange> ]    ;
             [ ON CLICK <bClick> ]      ;
             [ ON RIGHTCLICK <bRClick> ];
             [ ON GETFOCUS <bGetFocus> ];
             [ ON LOSTFOCUS <bLostFocus>];
             [ BITMAP <aBmp>  [<res: FROM RESOURCE>] [ BITCOUNT <nBC> ] ]  ;
          => ;
          [<oTab> := ] HTab():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<aItems>,<bChange>, <aBmp>, <.res.>,<nBC>,;
             <bClick>, <bGetFocus>, <bLostFocus>, <bRClick> ) ;;
          [ <oTab>:name := <(oTab)> ]

#xcommand BEGIN PAGE <cname> OF <oTab> ;
            [ <enable: DISABLED> ]     ;
            [ COLOR <tcolor>]          ;
            [ BACKCOLOR <bcolor>]      ;
            [ TOOLTIP <ctoolt> ]       ;
          =>;
          <oTab>:StartPage( <cname>, ,! <.enable.> ,<tcolor>,<bcolor>, <ctoolt> )

#xcommand END PAGE OF <oTab> => <oTab>:EndPage()

#xcommand ENDPAGE OF <oTab> => <oTab>:EndPage()

#xcommand REDEFINE TAB  <oSay>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CHANGE <bChange> ]    ;
          => ;
          [<oSay> := ] Htab():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<bChange> )
