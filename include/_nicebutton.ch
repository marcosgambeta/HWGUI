// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

// Nice Buttons by Luiz Rafael
#xcommand @ <nX>,<nY> NICEBUTTON [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ ON INIT <bInit> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ STYLE <nStyle> ]         ;
             [ EXSTYLE <nStyleEx> ]         ;
             [ TOOLTIP <ctoolt> ]       ;
             [ RED <r> ] ;
             [ GREEN <g> ];
             [ BLUE <b> ];
          => ;
          [<oBut> := ] HNicebutton():New( <oWnd>,<nId>,<nStyle>,<nStyleEx>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<bInit>,<bClick>,<caption>,<ctoolt>,<r>,<g>,<b> );
          [; <oBut>:name := <(oBut)> ]

#xcommand REDEFINE NICEBUTTON [ <oBut> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ ON INIT <bInit> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ EXSTYLE <nStyleEx> ]         ;
             [ TOOLTIP <ctoolt> ]       ;
             [ RED <r> ] ;
             [ GREEN <g> ];
             [ BLUE <b> ];
          => ;
          [<oBut> := ] HNicebutton():Redefine( <oWnd>,<nId>,<nStyleEx>, ;
             <bInit>,<bClick>,<caption>,<ctoolt>,<r>,<g>,<b> )
