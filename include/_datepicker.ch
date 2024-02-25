// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> DATEPICKER [ <oPick> ]  ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <dInit> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [<lShowTime: SHOWTIME>]    ;
          => ;
          [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<dInit>,,<nStyle>,<nX>,<nY>, ;
             <nWidth>,<nHeight>,<oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<ctoolt>, ;
             <color>,<bcolor>,<.lShowTime.>  );
          [; <oPick>:name := <(oPick)> ]

#xcommand REDEFINE DATEPICKER [ <oPick> VAR  ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <dInit> ]           ;
             [ ON SIZE <bSize>]         ;
             [ ON INIT <bInit> ]        ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON CHANGE <bChange> ]    ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [<lShowTime: SHOWTIME>]    ;             
          => ;
          [<oPick> :=] HDatePicker():redefine( <oWnd>,<nId>,<dInit>,{|v|Iif(v==Nil,<vari>,<vari>:=v)}, ;
             <oFont>,<bSize>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<ctoolt>, ;
             <color>,<bcolor>,<.lShowTime.>  )

/* SAY ... GET system     */

#xcommand @ <nX>,<nY> GET DATEPICKER [ <oPick> VAR ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ WHEN <bGfocus> ]         ;
             [ VALID <bLfocus> ]        ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [<lShowTime: SHOWTIME>]    ;
          => ;
          [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<vari>,    ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<ctoolt>,<color>,<bcolor>,<.lShowTime.>  );
          [; <oPick>:name := <(oPick)> ]
