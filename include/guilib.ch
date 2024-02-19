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

#xcommand SAY <value> TO <oDlg> ID <id> ;
          => ;
          hwg_Setdlgitemtext( <oDlg>:handle, <id>, <value> )

#include "_menu.ch"

#xcommand ACCELERATOR <flag>, <key>       ;
             [ ID <nId> ]                  ;
             ACTION <act>                  ;
          => ;
          Hwg_DefineAccelItem( <nId>, <{act}>, <flag>, <key> )

#include "_timer.ch"

#xcommand SET KEY <nctrl>,<nkey> [ OF <oDlg> ] [ TO <func> ] ;
          => ;
          hwg_SetDlgKey( <oDlg>, <nctrl>, <nkey>, <{func}> )

#translate LastKey( )  =>  HWG_LASTKEY( )

#include "_graph.ch"

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

#include "_ipedit.ch"

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

#include "_printer.ch"

#include "_monthcalendar.ch"

#include "_listbox.ch"

#include "_splash.ch"

#include "_nicebutton.ch"

#include "_trackbar.ch"

#include "_animation.ch"

//Contribution   Ricardo de Moura Marques
#include "_rect.ch"

#include "_toolbar.ch"

#xcommand CREATE MENUBAR <o> => <o> := \{ \}

#xcommand MENUBARITEM  <oWnd> CAPTION <c> ON <id1> ACTION <b1>      ;
          => ;
          Aadd( <oWnd>, \{ <c>, <id1>, <{b1}> \})

#include "_gridex.ch"

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

//Contribution Luis Fernando Basso

#include "_shape.ch"

#include "_container.ch"
