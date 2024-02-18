// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> TOOLBAR [ <oTool> ] ;
            [ OF <oWnd> ]               ;
            [ ID <nId> ]                ;
            [ SIZE <nWidth>, <nHeight> ]  ;
            [ BUTTONWIDTH <btnwidth> ]  ;
            [ INDENT <nIndent>       ]  ;
                                 [ BITMAPSIZE <bmpwidth> [, <bmpheight> ] ]  ;
            [ FONT <oFont> ]            ;
            [ ON INIT <bInit> ]         ;
            [ ON SIZE <bSize> ]         ;
            [<lTransp: TRANSPARENT>]    ;
            [<lVertical: VERTICAL>]     ;
            [ STYLE <nStyle> ]          ;
            [ LOADSTANDARDIMAGE <nIDB>] ;
            [ ITEMS <aItems> ]          ;
          => ;
    [<oTool> := ]  Htoolbar():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,<btnwidth>,<oFont>,;
              <bInit>,<bSize>,,,,,<.lTransp.>,<.lVertical.>,<aItems>,<bmpwidth>,<bmpheight>,<nIndent>,<nIDB>) ;;
    [ <oTool>:name := <(oTool)> ]

#xcommand REDEFINE TOOLBAR  <oSay>     ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ITEM <aitem>];
          => ;
          [<oSay> := ] Htoolbar():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem> )

#xcommand TOOLBUTTON  <O>       ;
             ID <nId>              ;
             [ BITMAP <nBitIp> ]   ;
             [ STYLE <bstyle> ]    ;
             [ STATE <bstate>]     ;
             [ TEXT <ctext> ]      ;
             [ TOOLTIP <c> ]       ;
             [ MENU <d>]           ;
             ON CLICK <bclick>    ;
          =>;
          <O>:AddButton(<nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>)

#xcommand ADD TOOLBUTTON  <O> ;
             ID <nId> ;
             [ BITMAP <nBitIp> ];
             [ STYLE <bstyle> ];
             [ STATE <bstate>];
             [ TEXT <ctext> ] ;
             [ TOOLTIP <c> ];
             [ MENU <d>];
             ON CLICK <bclick>;
          =>;
          aadd(<O> ,\{<nBitIp>,<nId>,<bstate>,<bstyle>,,<ctext>,<bclick>,<c>,<d>,,\})

#xcommand ADDTOOLBUTTON  <oTool> ;
             [ ID <nId> ];
             [ BITMAP <nBitIp> ];
             [ STYLE <bstyle> ];
             [ STATE <bstate>];
             [ TEXT <ctext> ] ;
             [ TOOLTIP <c> ];
             [ MENU <d>];
             [ NAME < cButton > ];
             ON CLICK <bclick>;
          =>;
          <oTool>:AddButton( <nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>,<cButton> )
