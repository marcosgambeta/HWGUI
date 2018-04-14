/*
 * $Id: hprinter.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * HPrinter class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

CLASS HPrinter INHERIT HObject

   DATA hDCPrn INIT 0
   DATA hDC
   DATA cPrinterName
   DATA hPrinter INIT 0
   DATA aMeta
   DATA lPreview
   DATA cMetaName
   DATA nWidth, nHeight, nPWidth, nPHeight
   DATA nHRes, nVRes                     // Resolution ( pixels/mm )
   DATA nPage
   DATA lmm  INIT .F.
   DATA nCurrPage, oTrackV, oTrackH
   DATA nZoom, xOffset, yOffset, x1, y1, x2, y2
   DATA memDC       HIDDEN    // dc offscreen
   DATA memBitmap   HIDDEN    // bitmap offscreen
   DATA NeedsRedraw INIT .T.  HIDDEN // if offscreen needs redrawing...
   DATA FormType       INIT 0
   DATA BinNumber      INIT 0
   DATA Landscape      INIT .F.
   DATA Copies         INIT 1
   DATA fDuplexType    INIT 0      HIDDEN
   DATA fPrintQuality  INIT 0      HIDDEN
   DATA PaperLength    INIT 0                        // Value is * 1/10 of mm   1000 = 10cm
   DATA PaperWidth     INIT 0                        //   "    "    "     "       "     "
   DATA PixelsPerInchY
   DATA PixelsPerInchX
   DATA TopMargin
   DAta BottomMargin
   DATA LeftMargin
   DATA RightMargin

   METHOD New( cPrinter, lmm, nFormType, nBin, lLandScape, nCopies, lProprierties, hDCPrn )
   METHOD SetMode( nOrientation )
   METHOD AddFont( fontName, nHeight , lBold, lItalic, lUnderline, nCharSet )
   METHOD SetFont( oFont )  INLINE hwg_Selectobject( ::hDC, oFont:handle )
   METHOD Settextcolor( nColor )  INLINE hwg_Settextcolor( ::hDC, nColor )
   METHOD SetTBkColor( nColor )   INLINE hwg_Setbkcolor( ::hDC, nColor )
   METHOD Setbkmode( lmode )   INLINE hwg_Setbkmode( ::hDC, IIF( lmode, 1, 0 ) )
   METHOD StartDoc( lPreview, cMetaName )
   METHOD EndDoc()
   METHOD StartPage()
   METHOD EndPage()
   METHOD ReleaseMeta()
   METHOD PlayMeta( oWnd )
   METHOD PrintMeta( nPage )
   METHOD Preview( cTitle, aBitmaps, aTooltips, aBootUser  )
   METHOD END()
   METHOD Box( x1, y1, x2, y2, oPen, oBrush )
   METHOD Line( x1, y1, x2, y2, oPen )
   METHOD Say( cString, x1, y1, x2, y2, nOpt, oFont, nTextColor, nBkColor )
   METHOD Bitmap( x1, y1, x2, y2, nOpt, hBitmap )
   METHOD GetTextWidth( cString, oFont )
   METHOD ResizePreviewDlg( oCanvas, nZoom, msg, wParam, lParam ) HIDDEN
   METHOD ChangePage( oSayPage, n, nPage ) HIDDEN
ENDCLASS

METHOD New( cPrinter, lmm, nFormType, nBin, lLandScape, nCopies, lProprierties, hDCPrn ) CLASS HPrinter
   LOCAL aPrnCoors, cPrinterName

   IF Valtype( nFormType ) = "N"
      ::FormType := nFormType
   ENDIF
   IF valtype( nBin ) == "N"
      ::BinNumber := nBin
   ENDIF
   IF Valtype( lLandScape ) =="L"
      ::Landscape := lLandScape
   ENDIF
   IF valtype( nCopies ) == "N"
      IF nCopies > 0
         ::Copies := nCopies
      ENDIF
   ENDIF
   IF valtype( lProprierties ) <> "L"
      lProprierties := .T.
   ENDIF

   IF lmm != NIL
      ::lmm := lmm
   ENDIF
   IF hDCPrn = NIL
      hDCPrn := 0
   ENDIF
   IF hDCPrn <> 0
      ::hDCPrn := hDCPrn
      ::cPrinterName := cPrinter
   ELSE
      IF cPrinter == NIL
         ::hDCPrn := hwg_PrintSetup( @cPrinterName )
         ::cPrinterName := cPrinterName
     ELSEIF Empty( cPrinter )
         cPrinterName := HWG_GETDEFAULTPRINTER()
         ::hDCPrn := Hwg_OpenPrinter( cPrinterName )
         ::cPrinterName := cPrinterName
      ELSE
         ::hDCPrn := Hwg_OpenPrinter( cPrinter )
         ::cPrinterName := cPrinter
      ENDIF
   ENDIF
   IF empty( ::hDCPrn )
      RETURN NIL
   ELSE
      IF lProprierties
         IF !Hwg_SetDocumentProperties(::hDCPrn, ::cPrinterName, @::FormType, @::Landscape, @::Copies, @::BinNumber, @::fDuplexType, @::fPrintQuality, @::PaperLength, @::PaperWidth )
           RETURN NIL
         ENDIF
      ENDIF
      aPrnCoors := hwg_GetDeviceArea( ::hDCPrn )
      ::nWidth  := IIf( ::lmm, aPrnCoors[ 3 ], aPrnCoors[ 1 ] )
      ::nHeight := IIf( ::lmm, aPrnCoors[ 4 ], aPrnCoors[ 2 ] )
      ::nPWidth  := IIf( ::lmm, aPrnCoors[ 8 ], aPrnCoors[ 1 ] )
      ::nPHeight := IIf( ::lmm, aPrnCoors[ 9 ], aPrnCoors[ 2 ] )
      ::nHRes   := aPrnCoors[ 1 ] / aPrnCoors[ 3 ]
      ::nVRes   := aPrnCoors[ 2 ] / aPrnCoors[ 4 ]
      ::PixelsPerInchY   := aPrnCoors[ 6 ]
      ::PixelsPerInchX   := aPrnCoors[ 5 ]
      ::TopMargin        := aPrnCoors[ 10 ]
      ::BottomMargin     := (::nPHeight - ::TopMargin)+1
      ::LeftMargin       := aPrnCoors[ 11]
      ::RightMargin      := (::nPWidth - ::LeftMargin)+1
      // writelog( ::cPrinterName + str(aPrnCoors[1])+str(aPrnCoors[2])+str(aPrnCoors[3])+str(aPrnCoors[4])+str(aPrnCoors[5])+str(aPrnCoors[6])+str(aPrnCoors[8])+str(aPrnCoors[9]) )
   ENDIF

   RETURN Self

METHOD SetMode( nOrientation ) CLASS HPrinter
   LOCAL hPrinter := ::hPrinter, hDC, aPrnCoors

   hDC := hwg_SetPrinterMode( ::cPrinterName, @hPrinter, nOrientation )
   IF hDC != NIL
      IF ::hDCPrn != 0
         hwg_Deletedc( ::hDCPrn )
      ENDIF
      ::hDCPrn := hDC
      ::hPrinter := hPrinter
      aPrnCoors := hwg_GetDeviceArea( ::hDCPrn )
      ::nWidth  := IIf( ::lmm, aPrnCoors[ 3 ], aPrnCoors[ 1 ] )
      ::nHeight := IIf( ::lmm, aPrnCoors[ 4 ], aPrnCoors[ 2 ] )
      ::nPWidth  := IIf( ::lmm, aPrnCoors[ 8 ], aPrnCoors[ 1 ] )
      ::nPHeight := IIf( ::lmm, aPrnCoors[ 9 ], aPrnCoors[ 2 ] )
      ::nHRes   := aPrnCoors[ 1 ] / aPrnCoors[ 3 ]
      ::nVRes   := aPrnCoors[ 2 ] / aPrnCoors[ 4 ]
      // writelog( ":"+str(aPrnCoors[1])+str(aPrnCoors[2])+str(aPrnCoors[3])+str(aPrnCoors[4])+str(aPrnCoors[5])+str(aPrnCoors[6])+str(aPrnCoors[8])+str(aPrnCoors[9]) )
      RETURN .T.
   ENDIF

   RETURN .F.

METHOD AddFont( fontName, nHeight , lBold, lItalic, lUnderline, nCharset ) CLASS HPrinter
   LOCAL oFont

   IF ::lmm .AND. nHeight != NIL
      nHeight *= ::nVRes
   ENDIF
   oFont := HFont():Add( fontName,, nHeight,          ;
         IIf( lBold != NIL .AND. lBold, 700, 400 ), nCharset, ;
         IIf( lItalic != NIL .AND. lItalic, 255, 0 ), IIf( lUnderline != NIL .AND. lUnderline, 1, 0 ) )

   RETURN oFont

METHOD END() CLASS HPrinter

   IF !empty( ::hDCPrn )
      hwg_Deletedc( ::hDCPrn )
      ::hDCPrn := NIL
   ENDIF
   IF !empty( ::hPrinter )
      hwg_ClosePrinter( ::hPrinter )
   ENDIF
   ::ReleaseMeta()

   RETURN NIL

METHOD Box( x1, y1, x2, y2, oPen, oBrush ) CLASS HPrinter

   IF oPen != NIL
      hwg_Selectobject( ::hDC, oPen:handle )
   ENDIF
   IF oBrush != NIL
      hwg_Selectobject( ::hDC, oBrush:handle )
   ENDIF
   IF ::lmm
      hwg_Box( ::hDC, ::nHRes * x1, ::nVRes * y1, ::nHRes * x2, ::nVRes * y2 )
   ELSE
      hwg_Box( ::hDC, x1, y1, x2, y2 )
   ENDIF

   RETURN NIL

METHOD Line( x1, y1, x2, y2, oPen ) CLASS HPrinter

   IF oPen != NIL
      hwg_Selectobject( ::hDC, oPen:handle )
   ENDIF
   IF ::lmm
      hwg_Drawline( ::hDC, ::nHRes * x1, ::nVRes * y1, ::nHRes * x2, ::nVRes * y2 )
   ELSE
      hwg_Drawline( ::hDC, x1, y1, x2, y2 )
   ENDIF

   RETURN NIL

METHOD Say( cString, x1, y1, x2, y2, nOpt, oFont, nTextColor, nBkColor ) CLASS HPrinter
   LOCAL hFont, nOldTC, nOldBC

   IF oFont != NIL
      hFont := hwg_Selectobject( ::hDC, oFont:handle )
   ENDIF
   IF nTextColor != NIL
      nOldTC := hwg_Settextcolor( ::hDC, nTextColor )
   ENDIF
   IF nBkColor != NIL
      nOldBC := hwg_Setbkcolor( ::hDC, nBkColor )
   ENDIF

   IF ::lmm
      hwg_Drawtext( ::hDC, cString, ::nHRes * x1, ::nVRes * y1, ::nHRes * x2, ::nVRes * y2, IIf( nOpt == NIL, DT_LEFT, nOpt ) )
   ELSE
      hwg_Drawtext( ::hDC, cString, x1, y1, x2, y2, IIf( nOpt == NIL, DT_LEFT, nOpt ) )
   ENDIF

   IF oFont != NIL
      hwg_Selectobject( ::hDC, hFont )
   ENDIF

   IF nTextColor != NIL
      hwg_Settextcolor( ::hDC, nOldTC )
   ENDIF

   IF nBkColor != NIL
      hwg_Setbkcolor( ::hDC, nOldBC )
   ENDIF

   RETURN NIL

METHOD Bitmap( x1, y1, x2, y2, nOpt, hBitmap ) CLASS HPrinter

   IF ::lmm
      hwg_Drawbitmap( ::hDC, hBitmap, IIf( nOpt == NIL, SRCAND, nOpt ), ::nHRes * x1, ::nVRes * y1, ::nHRes * ( x2 - x1 + 1 ), ::nVRes * ( y2 - y1 + 1 ) )
   ELSE
      hwg_Drawbitmap( ::hDC, hBitmap, IIf( nOpt == NIL, SRCAND, nOpt ), x1, y1, x2 - x1 + 1, y2 - y1 + 1 )
   ENDIF

   RETURN NIL

METHOD GetTextWidth( cString, oFont ) CLASS HPrinter
   LOCAL arr, hFont

   IF oFont != NIL
      hFont := hwg_Selectobject( ::hDC, oFont:handle )
   ENDIF
   arr := hwg_Gettextsize( ::hDC, cString )
   IF oFont != NIL
      hwg_Selectobject( ::hDC, hFont )
   ENDIF

   RETURN IIf( ::lmm, Int( arr[ 1 ] / ::nHRes ), arr[ 1 ] )

METHOD StartDoc( lPreview, cMetaName ) CLASS HPrinter

   IF lPreview != NIL .AND. lPreview
      ::lPreview := .T.
      ::ReleaseMeta()
      ::aMeta := { }
      ::cMetaName := cMetaName
   ELSE
      ::lPreview := .F.
      ::hDC := ::hDCPrn
      Hwg_StartDoc( ::hDC )
   ENDIF
   ::nPage := 0

   RETURN NIL

METHOD EndDoc() CLASS HPrinter

   IF ! ::lPreview
      Hwg_EndDoc( ::hDC )
   ENDIF

   RETURN NIL

METHOD StartPage() CLASS HPrinter
   LOCAL fname

   IF ::lPreview
      fname := IIf( ::cMetaName != NIL, ::cMetaName + LTrim( Str( Len( ::aMeta ) + 1 ) ) + ".emf", NIL )
      AAdd( ::aMeta, hwg_CreateMetaFile( ::hDCPrn, fname ) )
      ::hDC := ATail( ::aMeta )
   ELSE
      Hwg_StartPage( ::hDC )
   ENDIF
   ::nPage ++

   RETURN NIL

METHOD EndPage() CLASS HPrinter
   LOCAL nLen

   IF ::lPreview
      nLen := Len( ::aMeta )
      ::aMeta[ nLen ] := hwg_CloseEnhMetaFile( ::aMeta[ nLen ] )
      ::hDC := 0
   ELSE
      Hwg_EndPage( ::hDC )
   ENDIF

   RETURN NIL

METHOD ReleaseMeta() CLASS HPrinter
   LOCAL i, nLen

   IF ::aMeta == NIL .OR. Empty( ::aMeta )
      RETURN NIL
   ENDIF

   nLen := Len( ::aMeta )
   FOR i := 1 TO nLen
      hwg_DeleteEnhMetaFile( ::aMeta[ i ] )
   NEXT
   ::aMeta := NIL

   RETURN NIL

METHOD Preview( cTitle, aBitmaps, aTooltips, aBootUser ) CLASS HPrinter
   LOCAL oDlg, oToolBar, oSayPage, oBtn, oCanvas, oTimer, i, nLastPage := Len( ::aMeta ), aPage := { }
   LOCAL oFont := HFont():Add( "Times New Roman", 0, - 13, 700 )
   LOCAL lTransp := ( aBitmaps != NIL .AND. Len( aBitmaps ) > 9 .AND. aBitmaps[ 10 ] != NIL .AND. aBitmaps[ 10 ] )

   FOR i := 1 TO nLastPage
      AAdd( aPage, Str( i, 4 ) + ":" + Str( nLastPage, 4 ) )
   NEXT

   IF cTitle == NIL
      cTitle := "Print preview - " + ::cPrinterName
   ENDIF
   ::nZoom := 0
   ::nCurrPage := 1
   ::NeedsRedraw := .T.

   INIT DIALOG oDlg TITLE cTitle                  ;
         At 40, 10 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight()                        ;
         STYLE hwg_multibitor( WS_POPUP, WS_VISIBLE, WS_CAPTION, WS_SYSMENU, WS_SIZEBOX, WS_MAXIMIZEBOX, WS_CLIPCHILDREN ) ;
         ICON HIcon():AddResource("ICON_PRW");
         ON INIT { | o | o:Maximize(), ::ResizePreviewDlg( oCanvas, 1 ), SetTimerPrinter( oCanvas, @oTimer ) } ;
         ON EXIT { || oCanvas:brush := NIL, .T. }

   oDlg:bScroll := { | oWnd, msg, wParam, lParam | HB_SYMBOL_UNUSED( oWnd ), ::ResizePreviewDlg( oCanvas,, msg, wParam, lParam ) }
   oDlg:brush := HBrush():Add( 11316396 )

   @ 0, 0 PANEL oToolBar SIZE 88, oDlg:nHeight

   // Canvas should fill ALL the available space
   @ oToolBar:nWidth, 0 PANEL oCanvas ;
      SIZE oDlg:nWidth - oToolBar:nWidth, oDlg:nHeight ;
      ON SIZE { | o, x, y | o:Move(,, x - oToolBar:nWidth, y ), ::ResizePreviewDlg( o ) } ;
      ON PAINT { || ::PlayMeta( oCanvas ) } STYLE WS_VSCROLL + WS_HSCROLL

   oCanvas:bScroll := { | oWnd, msg, wParam, lParam | HB_SYMBOL_UNUSED( oWnd ), ::ResizePreviewDlg( oCanvas,, msg, wParam, lParam ) }
   // DON'T CHANGE NOR REMOVE THE FOLLOWING LINE !
   // I need it to have the correct side-effect to avoid flickering !!!
   oCanvas:brush := 0

   @ 3, 2 OWNERBUTTON oBtn OF oToolBar ON CLICK { || hwg_EndDialog() } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT "Exit" FONT oFont        ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 1 ], "Exit Preview" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 1 .AND. aBitmaps[ 2 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 2 ] ), HBitmap():AddFile( aBitmaps[ 2 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 31 LINE LENGTH oToolBar:nWidth - 1

   @ 3, 36 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::PrintMeta() } ;   // removed ::nCurrPage by Giuseppe Mastrangelo
         SIZE oToolBar:nWidth - 6, 24 TEXT "Print" FONT oFont         ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 2 ], "Print file" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 2 .AND. aBitmaps[ 3 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 3 ] ), HBitmap():AddFile( aBitmaps[ 3 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 62 COMBOBOX oSayPage ITEMS aPage of oToolBar ;
         SIZE oToolBar:nWidth - 6, 24 color "fff000" backcolor 12507070 ;
         ON CHANGE { || ::ChangePage( oSayPage,, oSayPage:GetValue() ) } STYLE WS_VSCROLL

   @ 3, 86 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ChangePage( oSayPage, 0 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT "|<<" FONT oFont                 ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 3 ], "First page" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 3 .AND. aBitmaps[ 4 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 4 ] ), HBitmap():AddFile( aBitmaps[ 4 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 110 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ChangePage( oSayPage, 1 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT ">>" FONT oFont                  ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 4 ], "Next page" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 4 .AND. aBitmaps[ 5 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 5 ] ), HBitmap():AddFile( aBitmaps[ 5 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 134 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ChangePage( oSayPage, - 1 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT "<<" FONT oFont    ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 5 ], "Previous page" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 5 .AND. aBitmaps[ 6 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 6 ] ), HBitmap():AddFile( aBitmaps[ 6 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 158 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ChangePage( oSayPage, 2 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT ">>|" FONT oFont   ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 6 ], "Last page" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 6 .AND. aBitmaps[ 7 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 7 ] ), HBitmap():AddFile( aBitmaps[ 7 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 189 LINE LENGTH oToolBar:nWidth - 1

   @ 3, 192 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ResizePreviewDlg( oCanvas, - 1 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT "(-)" FONT oFont   ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 7 ], "Zoom out" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 7 .AND. aBitmaps[ 8 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 8 ] ), HBitmap():AddFile( aBitmaps[ 8 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 3, 216 OWNERBUTTON oBtn OF oToolBar ON CLICK { || ::ResizePreviewDlg( oCanvas, 1 ) } ;
         SIZE oToolBar:nWidth - 6, 24 TEXT "(+)" FONT oFont   ;
         TOOLTIP IIf( aTooltips != NIL, aTooltips[ 8 ], "Zoom in" )
   IF aBitmaps != NIL .AND. Len( aBitmaps ) > 8 .AND. aBitmaps[ 9 ] != NIL
      oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBitmaps[ 9 ] ), HBitmap():AddFile( aBitmaps[ 9 ] ) )
      oBtn:title   := NIL
      oBtn:lTransp := lTransp
   ENDIF

   @ 1, 243 LINE LENGTH oToolBar:nWidth - 1

   IF aBootUser != NIL

      @ 1, 313 LINE LENGTH oToolBar:nWidth - 1

      @ 3, 316 OWNERBUTTON oBtn OF oToolBar  ;
            SIZE oToolBar:nWidth - 6, 24        ;
            TEXT IIf( Len( aBootUser ) == 4, aBootUser[ 4 ], "User Button" ) ;
            FONT oFont                   ;
            TOOLTIP IIf( aBootUser[ 3 ] != NIL, aBootUser[ 3 ], "User Button" )

      oBtn:bClick := aBootUser[ 1 ]

      IF aBootUser[ 2 ] != NIL
         oBtn:oBitmap := IIf( aBitmaps[ 1 ], HBitmap():AddResource( aBootUser[ 2 ] ), HBitmap():AddFile( aBootUser[ 2 ] ) )
         oBtn:title   := NIL
         oBtn:lTransp := lTransp
      ENDIF

   ENDIF

   oDlg:Activate()

   oTimer:END()

   oDlg:brush:Release()
   // oCanvas:brush:Release()
   oFont:Release()

   RETURN NIL

STATIC FUNCTION SetTimerPrinter( oDlg, oTimer )

   SET TIMER oTimer OF oDlg VALUE 500 ACTION { || TimerFunc( oDlg ) }

   RETURN NIL

STATIC FUNCTION TimerFunc( o )

   // hwg_Redrawwindow( o:handle, RDW_ERASE + RDW_INVALIDATE )
   hwg_Redrawwindow( o:handle, RDW_FRAME + RDW_INTERNALPAINT + RDW_UPDATENOW + RDW_INVALIDATE )  // Force a complete redraw

   RETURN NIL

METHOD ChangePage( oSayPage, n, nPage ) CLASS hPrinter

   ::NeedsRedraw := .T.
   IF nPage == NIL
      IF n == 0
         ::nCurrPage := 1
      ELSEIF n == 2
         ::nCurrPage := Len( ::aMeta )
      ELSEIF n == 1 .AND. ::nCurrPage < Len( ::aMeta )
         ::nCurrPage ++
      ELSEIF n == - 1 .AND. ::nCurrPage > 1
         ::nCurrPage --
      ENDIF
      oSayPage:SetItem( ::nCurrPage )
   ELSE
      ::nCurrPage := nPage
   ENDIF

   RETURN NIL

/***
 nZoom: zoom factor: -1 or 1, NIL if scroll message
*/
METHOD ResizePreviewDlg( oCanvas, nZoom, msg, wParam, lParam ) CLASS hPrinter
   LOCAL nWidth, nHeight, k1, k2, x, y
   LOCAL i, nPos, wmsg, nPosVert, nPosHorz

   x := oCanvas:nWidth
   y := oCanvas:nHeight

   HB_SYMBOL_UNUSED( lParam )

   nPosVert := hwg_Getscrollpos( oCanvas:handle, SB_VERT )
   nPosHorz := hwg_Getscrollpos( oCanvas:handle, SB_HORZ )

   IF msg = WM_VSCROLL
      hwg_Setscrollrange( oCanvas:handle, SB_VERT, 1, 20 )
      wmsg := hwg_Loword( wParam )
      IF wmsg = SB_THUMBPOSITION .OR. wmsg = SB_THUMBTRACK
         nPosVert := hwg_Hiword( wParam )
      ELSEIF wmsg = SB_LINEUP
         nPosVert := nPosVert - 1
         IF nPosVert < 1
            nPosVert := 1
         ENDIF
      ELSEIF wmsg = SB_LINEDOWN
         nPosVert := nPosVert + 1
         IF nPosVert > 20
            nPosVert := 20
         ENDIF
      ELSEIF wmsg = SB_PAGEDOWN
         nPosVert := nPosVert + 4
         IF nPosVert > 20
            nPosVert := 20
         ENDIF
      ELSEIF wmsg = SB_PAGEUP
         nPosVert := nPosVert - 4
         IF nPosVert < 1
            nPosVert := 1
         ENDIF
      ENDIF
      hwg_Setscrollpos( oCanvas:handle, SB_VERT, nPosVert )
      ::NeedsRedraw := .T.
   ENDIF

   IF msg = WM_HSCROLL
      hwg_Setscrollrange( oCanvas:handle, SB_HORZ, 1, 20 )
      wmsg := hwg_Loword( wParam )
      IF wmsg = SB_THUMBPOSITION .OR. wmsg = SB_THUMBTRACK
         nPosHorz := hwg_Hiword( wParam )
      ELSEIF wmsg = SB_LINEUP
         nPosHorz := nPosHorz - 1
         IF nPosHorz < 1
            nPosHorz := 1
         ENDIF
      ELSEIF wmsg = SB_LINEDOWN
         nPosHorz := nPosHorz + 1
         IF nPosHorz > 20
            nPosHorz := 20
         ENDIF
      ELSEIF wmsg = SB_PAGEDOWN
         nPosHorz := nPosHorz + 4
         IF nPosHorz > 20
            nPosHorz := 20
         ENDIF
      ELSEIF wmsg = SB_PAGEUP
         nPosHorz := nPosHorz - 4
         IF nPosHorz < 1
            nPosHorz := 1
         ENDIF
      ENDIF
      hwg_Setscrollpos( oCanvas:handle, SB_HORZ, nPosHorz )
      ::NeedsRedraw := .T.
   ENDIF

   IF msg == WM_MOUSEWHEEL
      hwg_Setscrollrange( oCanvas:handle, SB_VERT, 1, 20 )
      IF hwg_Hiword( wParam ) > 32678
         IF ++ nPosVert > 20
            nPosVert := 20
         ENDIF
      ELSE
         IF -- nPosVert < 1
            nPosVert := 1
         ENDIF
      ENDIF
      hwg_Setscrollpos( oCanvas:handle, SB_VERT, nPosVert )
      ::NeedsRedraw := .T.
   ENDIF

   IF nZoom != NIL
      // If already at maximum zoom returns
      IF nZoom < 0 .AND. ::nZoom == 0
         RETURN NIL
      ENDIF
      ::nZoom += nZoom
      ::NeedsRedraw := .T.
   ENDIF
   k1 := ::nWidth / ::nHeight
   k2 := ::nHeight / ::nWidth

   IF ::nWidth > ::nHeight
      nWidth := x - 20
      nHeight := Round( nWidth * k2, 0 )
      IF nHeight > y - 20
         nHeight := y - 20
         nWidth := Round( nHeight * k1, 0 )
      ENDIF
      ::NeedsRedraw := .T.
   ELSE
      nHeight := y - 10
      nWidth := Round( nHeight * k1, 0 )
      IF nWidth > x - 20
         nWidth := x - 20
         nHeight := Round( nWidth * k2, 0 )
      ENDIF
      ::NeedsRedraw := .T.
   ENDIF

   IF ::nZoom > 0
      FOR i := 1 TO ::nZoom
         nWidth := Round( nWidth * 1.5, 0 )
         nHeight := Round( nHeight * 1.5, 0 )
      NEXT
      ::NeedsRedraw := .T.
   ELSEIF ::nZoom == 0
      nWidth := Round( nWidth * 0.93, 0 )
      nHeight := Round( nHeight * 0.93, 0 )
   ENDIF

   ::xOffset := ::yOffset := 0
   IF nHeight > y
      nPos := nPosVert
      IF nPos > 0
         ::yOffset := Round( ( ( nPos - 1 ) / 18 ) * ( nHeight - y + 10 ), 0 )
      ENDIF
   ELSE
      hwg_Setscrollpos( oCanvas:handle, SB_VERT, 0 )
   ENDIF

   IF nWidth > x
      nPos := nPosHorz
      IF nPos > 0
         nPos := ( nPos - 1 ) / 18
         ::xOffset := Round( nPos * ( nWidth - x + 10 ), 0 )
      ENDIF
   ELSE
      hwg_Setscrollpos( oCanvas:handle, SB_HORZ, 0 )
   ENDIF

   ::x1 := IIf( nWidth < x, Round( ( x - nWidth ) / 2, 0 ), 10 ) - ::xOffset
   ::x2 := ::x1 + nWidth - 1
   ::y1 := IIf( nHeight < y, Round( ( y - nHeight ) / 2, 0 ), 10 ) - ::yOffset
   ::y2 := ::y1 + nHeight - 1

   IF nZoom != NIL .OR. msg != NIL
      hwg_Redrawwindow( oCanvas:handle, RDW_FRAME + RDW_INTERNALPAINT + RDW_UPDATENOW + RDW_INVALIDATE )  // Force a complete redraw
   ENDIF

   RETURN NIL

METHOD PlayMeta( oWnd ) CLASS HPrinter
   LOCAL pps, hDC
   LOCAL rect
   LOCAL aArray
   STATIC lRefreshVideo := .T.
   STATIC Brush := NIL
   STATIC BrushShadow := NIL
   STATIC BrushBorder := NIL
   STATIC BrushWhite := NIL
   STATIC BrushBlack := NIL
   STATIC BrushLine := NIL
   STATIC BrushBackground := NIL

   rect := hwg_Getclientrect( oWnd:handle )

   // WriteLog(stR(rect[1])+ stR(rect[2])+ stR(rect[3])+ stR(rect[4]) )
   // offscreen canvas must be THE WHOLE CANVAS !

   IF ::xOffset == NIL
      ::ResizePreviewDlg( oWnd )
   ENDIF

   pps := hwg_Definepaintstru()
   hDC := hwg_Beginpaint( oWnd:handle, pps )
   aArray = hwg_Getppsrect( pps )
   // tracelog( "PPS"+str(aArray[1])+str(aArray[2])+str(aArray[3])+str(aArray[4]) )

   IF ( aArray[ 1 ] == 0 .AND. aArray[ 2 ] == 0 )  // IF WHOLE AREA
      IF ( ::NeedsRedraw .OR. lRefreshVideo )
         IF ValType( ::memDC ) == "U"
            ::memDC := hDC():New()
            ::memDC:Createcompatibledc( hDC )
            ::memBitmap := hwg_Createcompatiblebitmap( hDC, rect[ 3 ] - rect[ 1 ], rect[ 4 ] - rect[ 2 ] )
            ::memDC:Selectobject( ::memBitmap )
            Brush           := HBrush():Add( hwg_Getsyscolor( COLOR_3DHILIGHT + 1 ) ):handle
            BrushWhite      := HBrush():Add( hwg_Rgb( 255, 255, 255 ) ):handle
            BrushBlack      := HBrush():Add( hwg_Rgb( 0, 0, 0 ) ):handle
            BrushLine       := HBrush():Add( hwg_Rgb( 102, 100, 92 ) ):handle
            BrushBackground := HBrush():Add( hwg_Rgb( 204, 200, 184 ) ):handle
            BrushShadow     := HBrush():Add( hwg_Rgb( 178, 175, 161 ) ):handle
            BrushBorder     := HBrush():Add( hwg_Rgb( 129, 126, 115 ) ):handle
         ENDIF

         IF ::NeedsRedraw
            // Draw the canvas background (gray)
            hwg_Fillrect( ::memDC:m_hDC, rect[ 1 ], rect[ 2 ], rect[ 3 ], rect[ 4 ], BrushBackground )
            hwg_Fillrect( ::memDC:m_hDC, rect[ 1 ], rect[ 2 ], rect[ 1 ], rect[ 4 ], BrushBorder )
            hwg_Fillrect( ::memDC:m_hDC, rect[ 1 ], rect[ 2 ], rect[ 3 ], rect[ 2 ], BrushBorder )
            // Draw the PAPER background (white)
            hwg_Fillrect( ::memDC:m_hDC, ::x1 - 1, ::y1 - 1, ::x2 + 1, ::y2 + 1, BrushLine )
            hwg_Fillrect( ::memDC:m_hDC, ::x1, ::y1, ::x2, ::y2, BrushWhite )
            // Draw the actual printer data
            hwg_PlayEnhMetafile( ::memDC:m_hDC, ::aMeta[ ::nCurrPage ], ::x1, ::y1, ::x2, ::y2 )
            // Draw
            // hwg_Rectangle( ::memDC:m_hDC, ::x1, ::y1, ::x2, ::y2 )

            hwg_Fillrect( ::memDC:m_hDC, ::x2, ::y1 + 2, ::x2 + 1, ::y2 + 2, BrushBlack )
            hwg_Fillrect( ::memDC:m_hDC, ::x2 + 1, ::y1 + 1, ::x2 + 2, ::y2 + 2, BrushShadow )
            hwg_Fillrect( ::memDC:m_hDC, ::x2 + 1, ::y1 + 2, ::x2 + 2, ::y2 + 2, BrushLine )
            hwg_Fillrect( ::memDC:m_hDC, ::x2 + 2, ::y1 + 2, ::x2 + 3, ::y2 + 2, BrushShadow )


            hwg_Fillrect( ::memDC:m_hDC, ::x1 + 2, ::y2, ::x2, ::y2 + 2, BrushBlack )
            hwg_Fillrect( ::memDC:m_hDC, ::x1 + 2, ::y2 + 1, ::x2 + 1, ::y2 + 2, BrushLine )
            hwg_Fillrect( ::memDC:m_hDC, ::x1 + 2, ::y2 + 2, ::x2 + 2, ::y2 + 3, BrushShadow )
            ::NeedsRedraw := .F.
         ENDIF
         // tracelog("bitblt")
         lRefreshVideo := .F.
         hwg_Bitblt( hDC, rect[ 1 ], rect[ 2 ], rect[ 3 ], rect[ 4 ], ::memDC:m_hDC, 0, 0, SRCCOPY )
      ELSE   // window fully uncovered... force a repaint
         lRefreshVideo := .T.
      ENDIF
   ELSE
      // tracelog("no refresh video" )
      lRefreshVideo := .T.   // request a repaint
   ENDIF

   #if 0
      // Draws a line from upper left to bottom right of the PAPER
      // used to check for PAPER dimension...
      hwg_Drawline( hDC, ::x1, ::y1, ::x2, ::y2 )
   #endif

   hwg_Endpaint( oWnd:handle, pps )

   RETURN NIL

METHOD PrintMeta( nPage ) CLASS HPrinter

   IF ::lPreview

      ::StartDoc()
      IF nPage == NIL
         FOR nPage := 1 TO Len( ::aMeta )
            hwg_PrintEnhMetafile( ::hDCPrn, ::aMeta[ nPage ] )
         NEXT
      ELSE
         hwg_PrintEnhMetafile( ::hDCPrn, ::aMeta[ nPage ] )
      ENDIF
      ::EndDoc()
      ::lPreview := .T.
   ENDIF
   RETURN NIL
