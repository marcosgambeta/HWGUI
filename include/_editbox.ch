// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> EDITBOX [ <oEdit> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ ON CHANGE <bChange>]     ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [<lPassword: PASSWORD>]    ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oEdit> := ] HEdit():New( <oWnd>,<nId>,<caption>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<bGfocus>, ;
             <bLfocus>,<ctoolt>,<color>,<bcolor>,,<.lnoborder.>,,<.lPassword.>,<bKeyDown>, <bChange>,<bOther> );;
          [ <oEdit>:name := <(oEdit)> ]

#xcommand REDEFINE EDITBOX [ <oEdit> ] ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,,,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor>,,,,<bKeyDown> )
