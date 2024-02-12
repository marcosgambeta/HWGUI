#xcommand @ <nX>,<nY> LINE [ <oLine> ]   ;
             [ LENGTH <length> ]       ;
             [ HEIGHT <nHeight> ]      ;
             [ OF <oWnd> ]             ;
             [ ID <nId> ]              ;
             [ COLOR <color> ]         ;
             [ LINESLANT <cSlant> ]    ;
             [ BORDERWIDTH <nBorder> ] ;
             [<lVert: VERTICAL>]       ;
             [ ON INIT <bInit> ]       ;
             [ ON SIZE <bSize> ]       ;
          => ;
          [<oLine> := ] HLine():New( <oWnd>,<nId>,<.lVert.>,<nX>,<nY>,<length>,<bSize>, <bInit>,;
                                                      <color>, <nHeight>, <cSlant>,<nBorder>  );;
          [ <oLine>:name := <(oLine)> ]
