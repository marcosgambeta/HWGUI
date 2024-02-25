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
             <ctoolt>,<color>,<bcolor>,<bGfocus>,<.lEnter.>,<.lTransp.> );
          [; <oCheck>:name := <(oCheck)> ]

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

/* SAY ... GET system     */

#xcommand @ <nX>,<nY> GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             CAPTION  <caption>         ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bLfocus> ]        ;
             [ <lEnter: ENTER> ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():New( <oWnd>,<nId>,<vari>,              ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},                   ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<caption>,<oFont>, ;
             <bInit>,<bSize>,,<bClick>,<ctoolt>,<color>,<bcolor>,<bWhen>,<.lEnter.>,<.lTransp.>,<bLfocus>);
          [; <oCheck>:name := <(oCheck)> ]

#xcommand REDEFINE GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bWhen> ]           ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():Redefine( <oWnd>,<nId>,<vari>, ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},           ;
             <oFont>,,,,<bClick>,<ctoolt>,<color>,<bcolor>,<bWhen>,<.lEnter.>)
