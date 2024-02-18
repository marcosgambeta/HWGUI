// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> GRAPH [ <oGraph> DATA ] <aData> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON SIZE <bSize> ]        ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oGraph> := ] HGraph():New( <oWnd>,<nId>,<aData>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bSize>,<ctoolt>,<color>,<bcolor> );;
          [ <oGraph>:name := <(oGraph)> ]
