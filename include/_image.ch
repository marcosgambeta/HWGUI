// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>,<nY> IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
             [ TYPE <ctype>     ]       ;
          => ;
          [<oImage> := ] HSayFImage():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<image>,<bInit>,<bSize>,<ctoolt>,<ctype> );;
          [ <oImage>:name := <(oImage)> ]                                                              

#xcommand REDEFINE IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
          => ;
          [<oImage> := ] HSayFImage():Redefine( <oWnd>,<nId>,<image>, ;
             <bInit>,<bSize>,<ctoolt> )
