#xcommand @ <nX>,<nY> COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ INIT <nInit> ]           ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ DISPLAYCOUNT <nDisplay>] ;
             [ ITEMHEIGHT <nhItem>    ] ;
             [ COLUMNWIDTH <ncWidth>  ] ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ <edit: EDIT> ]           ;
             [ <text: TEXT> ]           ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON INTERACTIVECHANGE <bIChange> ]    ;
          => ;
          [<oCombo> := ] HComboBox():New( <oWnd>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>,<bChange>,<ctoolt>,;
             <.edit.>,<.text.>,<bGfocus>,<color>,<bcolor>, <bLfocus>,<bIChange>,;
                                                 <nDisplay>,<nhItem>,<ncWidth>,<nMaxLength>);;
          [ <oCombo>:name := <(oCombo)> ]

#xcommand REDEFINE COMBOBOX [ <oCombo> ITEMS ] <aItems> ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ INIT <nInit>    ]        ;
            [ DISPLAYCOUNT <nDisplay>] ;
            [ MAXLENGTH <nMaxLength> ] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CHANGE <bChange> ]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ ON INTERACTIVECHANGE <bIChange> ]    ;
          => ;
    [<oCombo> := ] HComboBox():Redefine( <oWnd>,<nId>,<nInit>,,<aItems>,<oFont>,<bInit>, ;
             <bSize>,<bDraw>,<bChange>,<ctoolt>,<bGfocus>, <bLfocus>, <bIChange>,<nDisplay>,<nMaxLength>)