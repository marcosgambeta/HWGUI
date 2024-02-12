#xcommand @ <nX>,<nY> PANEL [ <oPanel> ] ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oPanel> :=] HPanel():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<bInit>,<bSize>,<bDraw>,<bcolor> );;
          [ <oPanel>:name := <(oPanel)> ]

#xcommand REDEFINE PANEL [ <oPanel> ]  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ HEIGHT <nHeight> ]       ;
             [ WIDTH <nWidth> ]         ;
          => ;
          [<oPanel> :=] HPanel():Redefine( <oWnd>,<nId>,<nWidth>,<nHeight>,<bInit>,<bSize>,<bDraw>, <bcolor> )
