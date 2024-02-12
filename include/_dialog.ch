// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand INIT DIALOG <oDlg>              ;
          [ <res:FROM RESOURCE> <Resid> ] ;
          [ TITLE <cTitle> ]              ;
          [ AT <nX>,<nY> ]                  ;
          [ SIZE <nWidth>,<nHeight> ]     ;
          [ ICON <ico> ]                  ;
          [ COLOR <clr> ]                 ;
          [ BACKGROUND BITMAP <oBmp> ]    ;
          [ STYLE <nStyle> ]              ;
          [ FONT <oFont> ]                ;
          [ <lClipper:CLIPPER> ]          ;
          [ <lExitOnEnter:NOEXIT> ]       ; //Modified By Sandro
          [ <lExitOnEsc:NOEXITESC> ]      ; //Modified By Sandro
          [ <lnoClosable:NOCLOSABLE> ]    ;
          [ ON INIT <bInit> ]             ;
          [ ON SIZE <bSize> ]             ;
          [ ON PAINT <bPaint> ]           ;
          [ ON GETFOCUS <bGfocus> ]       ;
          [ ON LOSTFOCUS <bLfocus> ]      ;
          [ [ ON OTHER MESSAGES <bOther> ] [ ON OTHERMESSAGES <bOther> ] ] ;
          [ ON REFRESH <bRefresh> ]       ;
          [ ON EXIT <bExit> ]             ;
          [ HELPID <nHelpId> ]            ;
          => ;
          <oDlg> := HDialog():New( ;
             Iif(<.res.>, WND_DLG_RESOURCE, WND_DLG_NORESOURCE), ;
             <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, <cTitle>, <oFont>, <bInit>, <bExit>, ;
             <bSize>, <bPaint>, <bGfocus>, <bLfocus>, <bOther>, <.lClipper.>, <oBmp>, ;
             <ico>, <.lExitOnEnter.>, <nHelpId>, <Resid>, <.lExitOnEsc.>, <clr>, <bRefresh>, <.lnoClosable.> )

#xcommand ACTIVATE DIALOG <oDlg> ;
          [ <lNoModal:NOMODAL> ] ;
          [ SHOW <nShow> ] ;
          [ ON ACTIVATE <bInit> ] ;
          => ;
          <oDlg>:Activate( <.lNoModal.>, <bInit>, <nShow> )
