#xcommand @ <nX>,<nY> BROWSE [ <oBrw> ]  ;
             [ <lArr: ARRAY> ]          ;
             [ <lDb: DATABASE> ]        ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bEnter> ]      ;
             [ ON RIGHTCLICK <bRClick> ];
             [ ON GETFOCUS <bGfocus> ][WHEN <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ][ VALID <bLfocus> ] ;
             [ STYLE <nStyle> ]         ;
             [ <lNoVScr: NO VSCROLL> ]  ;
             [ <lNoBord: NOBORDER> ]    ;
             [ FONT <oFont> ]           ;
             [ <lAppend: APPEND> ]      ;
             [ <lAutoedit: AUTOEDIT> ]  ;
             [ ON UPDATE <bUpdate> ]    ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON POSCHANGE <bPosChg> ] ;
             [ ON CHANGEROWCOL <bChgrowcol> ] ;
             [ <lMulti: MULTISELECT> ]  ;
             [ <lDescend: DESCEND> ]    ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ WHILE <bWhile> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ FIRST <bFirst> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ LAST <bLast> ]           ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ FOR <bFor> ]             ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON OTHERMESSAGES <bOther>  ] ;
             [ TOOLTIP <ctoolt> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oBrw> :=] __IIF(<.class.>, <classname>, HBrowse)():New( Iif(<.lDb.>,BRW_DATABASE,Iif(<.lArr.>,BRW_ARRAY,0)),;
             <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize>, ;
             <bDraw>,<bEnter>,<bGfocus>,<bLfocus>,<.lNoVScr.>,<.lNoBord.>, <.lAppend.>,;
             <.lAutoedit.>, <bUpdate>, <bKeyDown>, <bPosChg>, <.lMulti.>, <.lDescend.>,;
             <bWhile>, <bFirst>, <bLast>, <bFor>, <bOther>, <color>, <bcolor>, <bRClick>,<bChgrowcol>, <ctoolt>  );;
          [ <oBrw>:name := <(oBrw)> ]

#xcommand REDEFINE BROWSE [ <oBrw> ]   ;
             [ <lArr: ARRAY> ]          ;
             [ <lDb: DATABASE> ]        ;
             [ <lFlt: FILTER> ]        ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bEnter> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ FONT <oFont> ]           ;
          => ;
          [<oBrw> :=] HBrowse():Redefine( Iif(<.lDb.>,BRW_DATABASE,Iif(<.lArr.>,BRW_ARRAY,Iif(<.lFlt.>,BRW_FILTER,0))),;
             <oWnd>,<nId>,<oFont>,<bInit>,<bSize>,<bDraw>,<bEnter>,<bGfocus>,<bLfocus> )

#xcommand ADD COLUMN <block> TO <oBrw> ;
             [ HEADER <cHeader> ]       ;
             [ TYPE <cType> ]           ;
             [ LENGTH <nLen> ]          ;
             [ DEC <nDec>    ]          ;
             [ <lEdit: EDITABLE> ]      ;
             [ JUSTIFY HEAD <nJusHead> ];
             [ JUSTIFY LINE <nJusLine> ];
             [ PICTURE <cPict> ]        ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ VALID <bValid> ]         ;
             [ WHEN <bWhen> ]           ;
             [ ON CLICK <bClick> ]      ;
             [ ITEMS <aItem> ]          ;
             [ [ON] COLORBLOCK <bClrBlck> ]  ;
             [ [ON] BHEADCLICK <bHeadClick> ]  ;
          => ;
          <oBrw>:AddColumn( HColumn():New( <cHeader>,<block>,<cType>,<nLen>,<nDec>,<.lEdit.>,;
             <nJusHead>, <nJusLine>, <cPict>, <{bValid}>, <{bWhen}>, <aItem>, <{bClrBlck}>, <{bHeadClick}>, <color>, <bcolor>, <bClick> ) )

#xcommand INSERT COLUMN <block> TO <oBrw> ;
             [ HEADER <cHeader> ]       ;
             [ TYPE <cType> ]           ;
             [ LENGTH <nLen> ]          ;
             [ DEC <nDec>    ]          ;
             [ <lEdit: EDITABLE> ]      ;
             [ JUSTIFY HEAD <nJusHead> ];
             [ JUSTIFY LINE <nJusLine> ];
             [ PICTURE <cPict> ]        ;
             [ VALID <bValid> ]         ;
             [ WHEN <bWhen> ]           ;
             [ ITEMS <aItem> ]          ;
             [ BITMAP <oBmp> ]          ;
             [ COLORBLOCK <bClrBlck> ]  ;
             INTO <nPos>                ;
          => ;
          <oBrw>:InsColumn( HColumn():New( <cHeader>,<block>,<cType>,<nLen>,<nDec>,<.lEdit.>,;
             <nJusHead>, <nJusLine>, <cPict>, <{bValid}>, <{bWhen}>, <aItem>, <oBmp>, <{bClrBlck}> ),<nPos> )
