// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> UPDOWN [ <oUpd> INIT ] <nInit> ;
             RANGE <nLower>,<nUpper>    ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ WIDTH <nUpDWidth> ]      ;
             [ INCREMENT <nIncr> ]      ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oUpd> := ] HUpDown():New( <oWnd>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bDraw>,<bGfocus>,         ;
             <bLfocus>,<ctoolt>,<color>,<bcolor>,<nUpDWidth>,<nLower>,<nUpper>,<nIncr> );;
          [ <oUpd>:name := <(oUpd)> ]

/* SAY ... GET system     */

#xcommand @ <nX>,<nY> GET UPDOWN [ <oUpd> VAR ]  <vari>  ;
             RANGE <nLower>,<nUpper>    ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ INCREMENT <nIncr> ]      ;
             [ WIDTH <nUpDWidth> ]      ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ WHEN  <bGfocus> ]        ;
             [ VALID <bLfocus> ]        ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [<lnoborder: NOBORDER>]    ;
             [ TOOLTIP <ctoolt> ]       ;
             [ ON INIT <bInit> ]        ;
             [ ON KEYDOWN <bKeyDown>   ];
             [ ON CHANGE <bChange> ]    ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oUpd> := ] HUpDown():New( <oWnd>,<nId>,<vari>,{|v|Iif(v==Nil,<vari>,<vari>:=v)}, ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,,,;
             <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor>, ;
             <nUpDWidth>,<nLower>,<nUpper>,<nIncr>,<cPicture>,<.lnoborder.>,;
             <nMaxLength>,<bKeyDown>,<bChange>,<bOther>,,);;
          [ <oUpd>:name := <(oUpd)> ]
