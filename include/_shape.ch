// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SHAPE [<oShape>] [OF <oWnd>] ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BORDERWIDTH <nBorder> ]  ;
             [ CURVATURE <nCurvature>]  ;
             [ COLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]     ;
             [ BORDERSTYLE <nbStyle>]   ;
             [ FILLSTYLE <nfStyle>]     ;
             [ BACKSTYLE <nbackStyle>]  ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
          => ;
          [ <oShape> := ] HShape():New(<oWnd>, <nId>, <nX>, <nY>, <nWidth>, <nHeight>, ;
             <nBorder>, <nCurvature>, <nbStyle>,<nfStyle>, <tcolor>, <bcolor>, <bSize>,<bInit>,<nbackStyle>);
          [; <oShape>:name := <(oShape)> ]
