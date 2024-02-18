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

/* SAY ... GET system     */

#xcommand @ <nX>,<nY> GET [ <oEdit> VAR ]  <vari>  ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ WHEN  <bGfocus> ]        ;
             [ VALID <bLfocus> ]        ;
             [<lPassword: PASSWORD>]    ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
             [ ON KEYDOWN <bKeyDown>   ];
             [ ON CHANGE <bChange> ]    ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oEdit> := ] HEdit():New( <oWnd>,<nId>,<vari>,               ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},             ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize> ,,  ;
             <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor>,<cPicture>,;
             <.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange>,<bOther>);;
          [ <oEdit>:name := <(oEdit)> ]

/* Added MULTILINE: AJ: 11-03-2007*/
#xcommand REDEFINE GET [ <oEdit> VAR ] <vari>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ WHEN  <bGfocus> ]        ;
             [ VALID <bLfocus> ]        ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
             [<lMultiLine: MULTILINE>]  ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ ON CHANGE <bChange> ]    ;
          => ;
          [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,<vari>, ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},    ;
             <oFont>,,,,<{bGfocus}>,<{bLfocus}>,<ctoolt>,<color>,<bcolor>,<cPicture>,<nMaxLength>,<.lMultiLine.>,<bKeyDown>, <bChange>)
