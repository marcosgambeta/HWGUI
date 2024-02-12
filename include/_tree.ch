#xcommand @ <nX>,<nY> TREE [ <oTree> ]   ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ FONT <oFont> ]           ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lEdit: EDITABLE>]       ;
             [ <lDragDrop: DRAGDROP>]   ;
             [ <lCheck: CHECKBOXES> ]   ;
             [ ON CHECK <bCheck> ]      ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ ON RIGHTCLICK <bRClick> ];
             [ ON DBLCLICK <bDClick> ]  ;
             [ ON DRAG <bDrag> ]        ;
             [ ON DROP <bDrop> ]        ;
             [ ON OTHERMESSAGES <bOther>] ;
             [ STYLE <nStyle> ]         ;
             [ BITMAP <aBmp>  [<res: FROM RESOURCE>] [ BITCOUNT <nBC> ] ]  ;
          => ;
          [<oTree> := ] HTree():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
                <nHeight>,<oFont>,<bInit>,<bSize>,<color>,<bcolor>,<aBmp>,<.res.>,<.lEdit.>,<bClick>,<nBC>, ;
                <bRClick>, <bDClick>, <.lCheck.>, <bCheck>, <.lDragDrop.>, <bDrag>, <bDrop>, <bOther> );;
          [ <oTree>:name := <(oTree)> ]

#xcommand INSERT NODE [ <oNode> CAPTION ] <cTitle>  ;
             TO <oTree>                            ;
             [ AFTER <oPrev> ]                     ;
             [ BEFORE <oNext> ]                    ;
             [ BITMAP <aBmp> ]                     ;
             [ ON CLICK <bClick> ]                 ;
             [ ON ACTION <bAction> ]                 ;
             [ <lCheck: CHECKED>]        ;
          => ;
          [<oNode> := ] <oTree>:AddNode( <cTitle>,<oPrev>,<oNext>,<bClick>,<aBmp>, <.lCheck.>, <bAction> )
