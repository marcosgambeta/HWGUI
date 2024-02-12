/*
 *$Id: guilib.ch 2076 2013-06-13 15:37:33Z druzus $
 */

#define HWG_VERSION            "2.17"
#define HWG_BUILD            1001
#define WND_MAIN               1
#define WND_MDI                2
#define WND_MDICHILD           3
#define WND_CHILD              4
#define WND_DLG_RESOURCE       10
#define WND_DLG_NORESOURCE     11

#define OBTN_INIT              0
#define OBTN_NORMAL            1
#define OBTN_MOUSOVER          2
#define OBTN_PRESSED           3

#define SHS_NOISE              0
#define SHS_DIAGSHADE          1
#define SHS_HSHADE             2
#define SHS_VSHADE             3
#define SHS_HBUMP              4
#define SHS_VBUMP              5
#define SHS_SOFTBUMP           6
#define SHS_HARDBUMP           7
#define SHS_METAL              8

#define PAL_DEFAULT            0
#define PAL_METAL              1

#define BRW_ARRAY              1
#define BRW_DATABASE           2

#define ANCHOR_TOPLEFT         0   // Anchors control to the top and left borders of the container and does not change the distance between the top and left borders. (Default)
#define ANCHOR_TOPABS          1   // Anchors control to top border of container and does not change the distance between the top border.
#define ANCHOR_LEFTABS         2   // Anchors control to left border of container and does not change the distance between the left border.
#define ANCHOR_BOTTOMABS       4   // Anchors control to bottom border of container and does not change the distance between the bottom border.
#define ANCHOR_RIGHTABS        8   // Anchors control to right border of container and does not change the distance between the right border.
#define ANCHOR_TOPREL          16  // Anchors control to top border of container and maintains relative distance between the top border.
#define ANCHOR_LEFTREL         32  // Anchors control to left border of container and maintains relative distance between the left border.
#define ANCHOR_BOTTOMREL       64  // Anchors control to bottom border of container and maintains relative distance between the bottom border.
#define ANCHOR_RIGHTREL        128 // Anchors control to right border of container and maintains relative distance between the right border.
#define ANCHOR_HORFIX          256 // Anchors center of control relative to left and right borders but remains fixed in size.
#define ANCHOR_VERTFIX         512 // Anchors center of control relative to top and bottom borders but remains fixed in size.

#define HORZ_PTS 9
#define VERT_PTS 12

#ifdef __XHARBOUR__
   #ifndef HB_SYMBOL_UNUSED
      #define HB_SYMBOL_UNUSED( x )    ( (x) := (x) )
   #endif
#endif

#ifdef __LINUX__
   /* for some ancient [x]Harbour versions which do not set __PLATFORM__UNIX */
   #ifndef __PLATFORM__UNIX
      #define  __PLATFORM__UNIX
   #endif
#endif

#ifndef __GTK__
   #ifdef __PLATFORM__UNIX
      #define __GTK__
   #endif
#endif

// Allow the definition of different classes without defining a new command

#xtranslate __IIF(.T., [<true>], [<false>]) => <true>
#xtranslate __IIF(.F., [<true>], [<false>]) => <false>

// Commands for windows, dialogs handling

#include "_window.ch"

#include "_dialog.ch"

#xcommand MENU FROM RESOURCE OF <oWnd> ON <id1> ACTION <b1>      ;
             [ ON <idn> ACTION <bn> ]    ;
          => ;
          <oWnd>:aEvents := \{ \{ 0,<id1>, <{b1}> \} [ , \{ 0,<idn>, <{bn}> \} ] \}

#xcommand DIALOG ACTIONS OF <oWnd> ON <id1>,<id2> ACTION <b1>      ;
             [ ON <idn1>,<idn2> ACTION <bn> ]  ;
          => ;
          <oWnd>:aEvents := \{ \{ <id1>,<id2>, <b1> \} [ , \{ <idn1>,<idn2>, <bn> \} ] \}

// Commands for control handling

#include "_progressbar.ch"

#include "_status.ch"

#include "_sayex.ch"

#include "_say.ch"

#include "_bitmap.ch"

#include "_icon.ch"

#include "_image.ch"

#include "_line.ch"

#include "_editbox.ch"

#include "_richedit.ch"

#include "_buttonx.ch"

#include "_button.ch"

#include "_buttonex.ch"

#include "_groupboxex.ch"

#include "_groupbox.ch"

#include "_tree.ch"

#include "_tab.ch"

#include "_checkbox.ch"

#include "_radiogroup.ch"

#include "_radiobutton.ch"

#include "_combobox.ch"

#include "_updown.ch"

#include "_panel.ch"

#include "_browse.ch"

#include "_grid.ch"

#include "_ownerbutton.ch"

#include "_shadebutton.ch"

#include "_datepicker.ch"

#include "_splitter.ch"

#include "_font.ch"

/* Print commands */

#xcommand START PRINTER DEFAULT => OpenDefaultPrinter(); StartDoc()

/* SAY ... GET system     */

#xcommand @ <nX>,<nY> GET [ <oEdit> VAR ]  <vari>  ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ WHEN  <bGfocus> ]        ;
             [ VALID <bLfocus> ]        ;
             [<lPassword: PASSWORD>]    ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
             [ ON KEYDOWN <bKeyDown>   ];
             [ ON CHANGE <bChange> ]    ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oEdit> := ] HEdit():New( <oWnd>,<nId>,<vari>,               ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},             ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize> ,,  ;
             <bGfocus>,<bLfocus>,<ctoolt>,<color>,<bcolor>,<cPicture>,;
             <.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange>,<bOther>);;
          [ <oEdit>:name := <(oEdit)> ]

/* Added MULTILINE: AJ: 11-03-2007*/
#xcommand REDEFINE GET [ <oEdit> VAR ] <vari>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ WHEN  <bGfocus> ]        ;
             [ VALID <bLfocus> ]        ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ TOOLTIP <ctoolt> ]       ;
             [<lMultiLine: MULTILINE>]  ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ ON CHANGE <bChange> ]    ;
          => ;
          [<oEdit> := ] HEdit():Redefine( <oWnd>,<nId>,<vari>, ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},    ;
             <oFont>,,,,<{bGfocus}>,<{bLfocus}>,<ctoolt>,<color>,<bcolor>,<cPicture>,<nMaxLength>,<.lMultiLine.>,<bKeyDown>, <bChange>)

#xcommand @ <nX>,<nY> GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             CAPTION  <caption>         ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bLfocus> ]        ;
             [ <lEnter: ENTER> ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;             
          => ;
          [<oCheck> := ] HCheckButton():New( <oWnd>,<nId>,<vari>,              ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},                   ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<caption>,<oFont>, ;
             <bInit>,<bSize>,,<bClick>,<ctoolt>,<color>,<bcolor>,<bWhen>,<.lEnter.>,<.lTransp.>,<bLfocus>);;
          [ <oCheck>:name := <(oCheck)> ]

#xcommand REDEFINE GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bWhen> ]           ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():Redefine( <oWnd>,<nId>,<vari>, ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},           ;
             <oFont>,,,,<bClick>,<ctoolt>,<color>,<bcolor>,<bWhen>,<.lEnter.>)

#xcommand @ <nX>,<nY> GET COMBOBOX [ <oCombo> VAR ] <vari> ;
            ITEMS  <aItems>            ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <nWidth>, <nHeight> ] ;
            [ DISPLAYCOUNT <nDisplay>] ;
            [ ITEMHEIGHT <nhItem>    ] ;
            [ COLUMNWIDTH <ncWidth>  ] ;
            [ MAXLENGTH <nMaxLength> ] ;
            [ COLOR <color> ]          ;
            [ BACKCOLOR <bcolor> ]     ;
            [ ON INIT <bInit> ]        ;
            [ ON CHANGE <bChange> ]    ;
            [ STYLE <nStyle> ]         ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
            [ <edit: EDIT> ]           ;
            [ <text: TEXT> ]           ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ ON INTERACTIVECHANGE <bIChange> ]    ;
          => ;
    [<oCombo> := ] HComboBox():New( <oWnd>,<nId>,<vari>,    ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
                    <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
                    <aItems>,<oFont>,<bInit>,,,<bChange>,<ctoolt>, ;
                    <.edit.>,<.text.>,<bGfocus>,<color>,<bcolor>,;
                                                                                <bLfocus>,<bIChange>,<nDisplay>,<nhItem>,<ncWidth>,<nMaxLength> );;
    [ <oCombo>:name := <(oCombo)> ]                                                                      


#xcommand REDEFINE GET COMBOBOX [ <oCombo> VAR ] <vari> ;
            ITEMS  <aItems>            ;
            [ OF <oWnd> ]              ;
            ID <nId>                   ;
            [ DISPLAYCOUNT <nDisplay>] ;
            [ MAXLENGTH <nMaxLength> ] ;
            [ ON CHANGE <bChange> ]    ;
            [ FONT <oFont> ]           ;
            [ TOOLTIP <ctoolt> ]       ;
            [ WHEN  <bGfocus> ]        ;
            [ VALID <bLfocus> ]        ;
            [ ON INTERACTIVECHANGE <bIChange> ]    ;
            [ <edit: EDIT> ]           ;
            [ <text: TEXT> ]           ;            
          => ;
    [<oCombo> := ] HComboBox():Redefine( <oWnd>,<nId>,<vari>, ;
                    {|v|Iif(v==Nil,<vari>,<vari>:=v)},        ;
                    <aItems>,<oFont>,,,,<bChange>,<ctoolt>,<bGfocus>, <bLfocus>,<bIChange>,<nDisplay>, <nMaxLength>,<.edit.>,<.text.>)

#xcommand REDEFINE GET COMBOBOXEX [ <oCombo> VAR ] <vari> ;
             ITEMS  <aItems>            ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON CHANGE <bChange> ]    ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bWhen> ]           ;
             [ CHECK <acheck>] ;
          => ;
          [<oCombo> := ] HComboBox():Redefine( <oWnd>,<nId>,<vari>, ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},        ;
             <aItems>,<oFont>,,,,<bChange>,<ctoolt>, <bWhen> ,<acheck>)

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
             <oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<ctoolt>,<color>,<bcolor>,<.lShowTime.>  );;
          [ <oPick>:name := <(oPick)> ]

#xcommand SAY <value> TO <oDlg> ID <id> ;
          => ;
          hwg_Setdlgitemtext( <oDlg>:handle, <id>, <value> )

#include "_menu.ch"

#xcommand ACCELERATOR <flag>, <key>       ;
             [ ID <nId> ]                  ;
             ACTION <act>                  ;
          => ;
          Hwg_DefineAccelItem( <nId>, <{act}>, <flag>, <key> )

#xcommand SET TIMER <oTimer> [ OF <oWnd> ] [ ID <id> ] ;
             VALUE <value> ACTION <bAction> ;
          => ;
          <oTimer> := HTimer():New( <oWnd>, <id>, <value>, <bAction> );;
          [ <oTimer>:name := <(oTimer)> ]

#xcommand SET KEY <nctrl>,<nkey> [ OF <oDlg> ] [ TO <func> ] ;
          => ;
          hwg_SetDlgKey( <oDlg>, <nctrl>, <nkey>, <{func}> )

#translate LastKey( )  =>  HWG_LASTKEY( )

/*             */
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

/* open an .dll resource */
#xcommand SET RESOURCES TO <cName1> => hwg_Loadresource( <cName1> )

#xcommand SET RESOURCES TO => hwg_Loadresource( NIL )

#xcommand SET COLORFOCUS <x:ON,OFF,&> [COLOR [<tColor>],[<bColor>]] [< lFixed : NOFIXED >] [< lPersistent : PERSISTENT >];
          => ;
          hwg_SetColorinFocus( <(x)> , <tColor>, <bColor>, <.lFixed.>, <.lPersistent.> )

#xcommand SET DISABLEBACKCOLOR <x:ON,OFF,&> [COLOR [<bColor>]] ;
          => ;
          hwg_SetDisableBackColor( <(x)> , <bColor> )

// Addded by jamaj
#xcommand DEFAULT <uVar1> := <uVal1> ;
             [, <uVarN> := <uValN> ] ;
          => ;
          <uVar1> := IIf( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
          [ <uVarN> := IIf( <uVarN> == nil, <uValN>, <uVarN> ); ]

#xcommand @ <nX>,<nY> GET IPADDRESS [ <oIp> VAR ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKCOLOR <bcolor> ]     ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ ON GETFOCUS <bGfocus> ]      ;
             [ ON LOSTFOCUS <bLfocus> ]     ;
          => ;
          [<oIp> := ] HIpEdit():New( <oWnd>,<nId>,<vari>,{|v| iif(v==Nil,<vari>,<vari>:=v)},<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>, <bGfocus>, <bLfocus> );;
          [ <oIp>:name := <(oIp)> ]

#define ISOBJECT(c)    ( Valtype(c) == "O" )
#define ISBLOCK(c)     ( Valtype(c) == "B" )
#define ISARRAY(c)     ( Valtype(c) == "A" )
#define ISNUMBER(c)    ( Valtype(c) == "N" )
#define ISLOGICAL(c)   ( Valtype(c) == "L" )

/* Commands for PrintDos Class*/

#xcommand SET PRINTER TO <oPrinter> OF <oPtrObj>     ;
          => ;
          <oPtrObj>:=Printdos():New( <oPrinter>)

#xcommand @ <nX>,<nY> PSAY  <vari>  ;
             [ PICTURE <cPicture> ] OF <oPtrObj>   ;
          => ;
          <oPtrObj>:Say(<nX>, <nY>, <vari>, <cPicture>)

#xcommand EJECT OF <oPtrObj> => <oPtrObj>:Eject()

#xcommand END PRINTER <oPtrObj> => <oPtrObj>:End()

/* Hprinter */

#xcommand INIT PRINTER <oPrinter>   ;
             [ NAME <cPrinter> ]     ;
             [ <lPixel: PIXEL> ]     ;
             [ FORMTYPE  <nFormType> ];
             [ BIN <nBin> ];
             [ <lLandScape: LANDSCAPE>];
             [ COPIES <nCopies> ];
          =>  ;
          <oPrinter> := HPrinter():New( <cPrinter>,!<.lPixel.>, <nFormType>, <nBin>, <.lLandScape.>, <nCopies> )

#xcommand INIT DEFAULT PRINTER <oPrinter>   ;
             [ <lPixel: PIXEL> ]             ;
             [ FORMTYPE  <nFormType> ];
             [ BIN <nBin> ];
             [ <lLandScape: LANDSCAPE>];
             [ COPIES <nCopies> ];
          =>  ;
          <oPrinter> := HPrinter():New( "",!<.lPixel.>, <nFormType>, <nBin>, <.lLandScape.>, <nCopies>  )

#include "_monthcalendar.ch"

#include "_listbox.ch"

#include "_splash.ch"

#include "_nicebutton.ch"

#include "_trackbar.ch"

#include "_animation.ch"

//Contribution   Ricardo de Moura Marques
#xcommand @ <nX>, <nY>, <X2>, <Y2> RECT <oRect> [<lPress: PRESS>] [OF <oWnd>] [RECT_STYLE <nST>];
          => <oRect> := HRect():New(<oWnd>,<nX>,<nY>,<X2>,<Y2>, <.lPress.>, <nST> )
          //  [ <oRect>:name := <(oRect)> ]

//New Control
#xcommand @ <nX>,<nY> SAY [ <oSay> CAPTION ] <caption> ;
             [ OF <oWnd> ]              ;
             LINK <cLink>               ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lTransp: TRANSPARENT>]  ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ BITMAP <hbit> ]          ;
             [ VISITCOLOR <vcolor> ]    ;
             [ LINKCOLOR <lcolor> ]     ;
             [ HOVERCOLOR <hcolor> ]    ;
          => ;
          [<oSay> := ] HStaticLink():New( <oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, ;
             <nHeight>, <caption>, <oFont>, <bInit>, <bSize>, <bDraw>, <ctoolt>, ;
             <color>, <bcolor>, <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor>,<hbit>, <bClick>  );;
          [ <oSay>:name := <(oSay)> ]

#xcommand REDEFINE SAY [ <oSay> CAPTION ] <cCaption>      ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             LINK <cLink>               ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lTransp: TRANSPARENT>]  ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ VISITCOLOR <vcolor> ]    ;
             [ LINKCOLOR <lcolor> ]     ;
             [ HOVERCOLOR <hcolor> ]    ;
          => ;
          [<oSay> := ] HStaticLink():Redefine( <oWnd>, <nId>, <cCaption>, ;
             <oFont>, <bInit>, <bSize>, <bDraw>, <ctoolt>, <color>, <bcolor>,;
             <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor> )

#xcommand TOOLBUTTON  <O>       ;
             ID <nId>              ;
             [ BITMAP <nBitIp> ]   ;
             [ STYLE <bstyle> ]    ;
             [ STATE <bstate>]     ;
             [ TEXT <ctext> ]      ;
             [ TOOLTIP <c> ]       ;
             [ MENU <d>]           ;
             ON CLICK <bclick>    ;
          =>;
          <O>:AddButton(<nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>)

#xcommand @ <nX>,<nY> TOOLBAR [ <oTool> ] ;
            [ OF <oWnd> ]               ;
            [ ID <nId> ]                ;
            [ SIZE <nWidth>, <nHeight> ]  ;
            [ BUTTONWIDTH <btnwidth> ]  ;
            [ INDENT <nIndent>       ]  ;
                                 [ BITMAPSIZE <bmpwidth> [, <bmpheight> ] ]  ;
            [ FONT <oFont> ]            ;
            [ ON INIT <bInit> ]         ;
            [ ON SIZE <bSize> ]         ;
            [<lTransp: TRANSPARENT>]    ;
            [<lVertical: VERTICAL>]     ;
            [ STYLE <nStyle> ]          ;
            [ LOADSTANDARDIMAGE <nIDB>] ;
            [ ITEMS <aItems> ]          ;
          => ;
    [<oTool> := ]  Htoolbar():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,<btnwidth>,<oFont>,;
              <bInit>,<bSize>,,,,,<.lTransp.>,<.lVertical.>,<aItems>,<bmpwidth>,<bmpheight>,<nIndent>,<nIDB>) ;;
    [ <oTool>:name := <(oTool)> ]

#xcommand REDEFINE TOOLBAR  <oSay>     ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ITEM <aitem>];
          => ;
          [<oSay> := ] Htoolbar():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem> )

#xcommand CREATE MENUBAR <o> => <o> := \{ \}

#xcommand MENUBARITEM  <oWnd> CAPTION <c> ON <id1> ACTION <b1>      ;
          => ;
          Aadd( <oWnd>, \{ <c>, <id1>, <{b1}> \})

#xcommand ADD TOOLBUTTON  <O> ;
             ID <nId> ;
             [ BITMAP <nBitIp> ];
             [ STYLE <bstyle> ];
             [ STATE <bstate>];
             [ TEXT <ctext> ] ;
             [ TOOLTIP <c> ];
             [ MENU <d>];
             ON CLICK <bclick>;
          =>;
          aadd(<O> ,\{<nBitIp>,<nId>,<bstate>,<bstyle>,,<ctext>,<bclick>,<c>,<d>,,\})

#xcommand ADDTOOLBUTTON  <oTool> ;
             [ ID <nId> ];
             [ BITMAP <nBitIp> ];
             [ STYLE <bstyle> ];
             [ STATE <bstate>];
             [ TEXT <ctext> ] ;
             [ TOOLTIP <c> ];
             [ MENU <d>];
             [ NAME < cButton > ];
             ON CLICK <bclick>;
          =>;
          <oTool>:AddButton( <nBitIp>,<nId>,<bstate>,<bstyle>,<ctext>,<bclick>,<c>,<d>,<cButton> )

#xcommand @ <nX>,<nY> GRIDEX <oGrid>        ;
             [ OF <oWnd> ]               ;
             [ ID <nId> ]                ;
             [ STYLE <nStyle> ]          ;
             [ SIZE <nWidth>, <nHeight> ]  ;
             [ FONT <oFont> ]            ;
             [ ON INIT <bInit> ]         ;
             [ ON SIZE <bSize> ]         ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CLICK <bEnter> ]       ;
             [ ON GETFOCUS <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ]  ;
             [ ON KEYDOWN <bKeyDown> ]   ;
             [ ON POSCHANGE <bPosChg> ]  ;
             [ ON DISPINFO <bDispInfo> ] ;
             [ ITEMCOUNT <nItemCount> ]  ;
             [ <lNoScroll: NOSCROLL> ]   ;
             [ <lNoBord: NOBORDER> ]     ;
             [ <lNoLines: NOGRIDLINES> ] ;
             [ COLOR <color> ]           ;
             [ BACKCOLOR <bkcolor> ]     ;
             [ <lNoHeader: NO HEADER> ]  ;
             [BITMAP <aBit>];
             [ ITEMS <a>];
          => ;
          <oGrid> := HGridEx():New( <oWnd>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>,;
             <oFont>, <{bInit}>, <{bSize}>, <{bPaint}>, <{bEnter}>,;
             <{bGfocus}>, <{bLfocus}>, <.lNoScroll.>, <.lNoBord.>,;
             <{bKeyDown}>, <{bPosChg}>, <{bDispInfo}>, <nItemCount>,;
             <.lNoLines.>, <color>, <bkcolor>, <.lNoHeader.> ,<aBit>,<a>);;
          [ <oGrid>:name := <(oGrid)> ]

#xcommand ADDROW TO GRID <oGrid>    ;
             [ HEADER <cHeader> ]        ;
             [ JUSTIFY HEAD <nJusHead> ] ;
             [ BITMAP <n> ]              ;
             [ HEADER <cHeadern> ]        ;
             [ JUSTIFY HEAD <nJusHeadn> ] ;
             [ BITMAP <nn> ]              ;
          => ;
          <oGrid>:AddRow(<cHeader>,<nJusHead>,<n>) [;<oGrid>:AddRow(<cHeadern>,<nJusHeadn>,<nn>)]

#xcommand ADDROWEX TO GRID <oGrid>        ;
             [ HEADER <cHeader>         ;
             [ BITMAP <n> ]              ;
             [ COLOR <color> ]           ;
             [ BACKCOLOR <bkcolor> ]][,     ;
             HEADER <cHeadern>        ;
             [ BITMAP <nn> ]             ;
             [ COLOR <colorn> ]          ;
             [ BACKCOLOR <bkcolorn> ]]    ;
          => ;
          <oGrid>:AddRow(\{<cHeader>,<n>,<color>,<bkcolor> [,<cHeadern>,<nn>,<colorn>,<bkcolorn> ] \})

#xcommand ADDROWEX TO GRID <oGrid>        ;
             [ HEADER <cHeader>         ;
             [ BITMAP <n> ]              ;
             [ COLOR <color> ]           ;
             [ BACKCOLOR <bkcolor> ]][,     ;
             HEADER <cHeadern>        ;
             [ BITMAP <nn> ]             ;
             [ COLOR <colorn> ]          ;
             [ BACKCOLOR <bkcolorn> ]]    ;
          => ;
          <oGrid>:AddRow(\{<cHeader>,<n>,<color>,<bkcolor> [,<cHeadern>,<nn>,<colorn>,<bkcolorn> ] \})

#xcommand ADDROWEX  <oGrid>        ;
             HEADER <cHeader>         ;
             [ BITMAP <n> ]              ;
             [ COLOR <color> ]           ;
             [ BACKCOLOR <bkcolor> ]     ;
             [ HEADER <cHeadern> ]       ;
             [ BITMAP <nn> ]             ;
             [ COLOR <colorn> ]          ;
             [ BACKCOLOR <bkcolorn> ]    ;
          => ;
          <oGrid>:AddRow(\{<cHeader>,<n>,<color>,<bkcolor> [, <cHeadern>,<nn>,<colorn>,<bkcolorn>] \})

#xcommand REDEFINE STATUS  <oSay>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ PARTS <bChange,...> ]    ;
          => ;
          [<oSay> := ] HStatus():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,\{<bChange>\} )

#xcommand REDEFINE GRID  <oSay>  ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ITEM <aitem>];
          => ;
          [<oSay> := ] HGRIDex():Redefine( <oWnd>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,<aitem> )

#xcommand @ <nX>,<nY> PAGER [ <oTool> ] ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STYLE <nStyle> ]         ;
             [ <lVert: VERTICAL> ] ;
          => ;
          [<oTool> := ] HPager():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,,<.lVert.>);;
          [ <oTool>:name := <(oTool)> ]

#xcommand @ <nX>,<nY> REBAR [ <oTool> ] ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STYLE <nStyle> ]         ;
          => ;
          [<oTool> := ]        HREBAR():New( <oWnd>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,);;
          [ <oTool>:name := <(oTool)> ]

#xcommand ADDBAND <hWnd> to <opage> ;
             [BACKCOLOR <b> ] [FORECOLOR <f>] ;
             [STYLE <nstyle>] [TEXT <t>] ;
          => ;
          <opage>:ADDBARColor(<hWnd>,<f>,<b>,<t>,<nstyle>)

#xcommand ADDBAND <hWnd> to <opage> ;
             [BITMAP <b> ]  ;
             [STYLE <nstyle>] [TEXT <t>] ;
          => ;
          <opage>:Addbarbitmap(<hWnd>,<t>,<b>,<nstyle>)

#xcommand @ <nX>,<nY> GET LISTBOX [ <oListbox> VAR ]  <vari> ;
             ITEMS  <aItems>            ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ WHEN <bGFocus> ]         ;
             [ VALID <bLFocus> ]        ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oListbox> := ] HListBox():New( <oWnd>,<nId>,<vari>,;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bChange>,<ctoolt>,<color>,<bcolor>,<bGFocus>,<bLFocus>,<bKeyDown>,<bDblClick>,<bOther>);;
          [ <oListbox>:name := <(oListbox)> ]


#xcommand @ <nX>,<nY> GET COMBOBOXEX [ <oCombo> VAR ] <vari> ;
             ITEMS  <aItems>            ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ DISPLAYCOUNT <nDisplay>] ;
             [ ITEMHEIGHT <nhItem>    ] ;
             [ COLUMNWIDTH <ncWidth>  ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <ctoolt> ]       ;
             [ <edit: EDIT> ]           ;
             [ <text: TEXT> ]           ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bValid> ]         ;
             [ CHECK <acheck> ]         ;
             [ IMAGES <aImages> ]       ;
          => ;
          [<oCombo> := ] HCheckComboBox():New( <oWnd>,<nId>,<vari>,    ;
             {|v|Iif(v==Nil,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <aItems>,<oFont>,,,,<bChange>,<ctoolt>, ;
             <.edit.>,<.text.>,<bWhen>,<color>,<bcolor>, ;
                                                 <bValid>,<acheck>,<nDisplay>,<nhItem>,<ncWidth>, <aImages> );;
          [ <oCombo>:name := <(oCombo)> ]

//Contribution Luis Fernando Basso

#xcommand @ <nX>, <nY>  SHAPE [<oShape>] [OF <oWnd>] ;
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
             <nBorder>, <nCurvature>, <nbStyle>,<nfStyle>, <tcolor>, <bcolor>, <bSize>,<bInit>,<nbackStyle>);;
          [ <oShape>:name := <(oShape)> ]

#xcommand @ <nX>, <nY>  CONTAINER [<oCnt>] [OF <oWnd>] ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKSTYLE <nbackStyle>]    ;
             [ COLOR <tcolor> ]         ;
             [ BACKCOLOR <bcolor> ]     ;
             [ STYLE <ncStyle>]          ;
             [ <lnoBorder: NOBORDER> ]   ;
             [ ON LOAD <bLoad> ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ <lTabStop: TABSTOP> ]   ;
             [ ON REFRESH <bRefresh> ]      ;
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON OTHERMESSAGES <bOther>  ] ;
             [ <class: CLASS> <classname> ] ;
          =>  ;
          [<oCnt> := ] __IIF(<.class.>, <classname>,HContainer)():New(<oWnd>, <nId>,IIF(<.lTabStop.>,WS_TABSTOP,),;
               <nX>, <nY>, <nWidth>, <nHeight>, <ncStyle>, <bSize>, <.lnoBorder.>,<bInit>,<nbackStyle>,<tcolor>,<bcolor>,;
               <bLoad>,<bRefresh>,<bOther>);;
          [ <oCnt>:name := <(oCnt)> ]
