/*
 * $Id: hrect.prg 2012 2013-03-07 09:03:56Z alkresin $
 *
 * HWGUI - Harbour Win32 GUI library source code:
 * C level class HRect (Panel)
 *
 * Copyright 2004 Ricardo de Moura Marques <ricardo.m.marques@caixa.gov.br>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#DEFINE TRANSPARENT 1

//-----------------------------------------------------------------
CLASS HRect INHERIT HControl

   DATA oLine1
   DATA oLine2
   DATA oLine3
   DATA oLine4

   METHOD New( oWndParent, nLeft, nTop, nRight, nBottom, lPress, nStyle )

ENDCLASS

//----------------------------------------------------------------
METHOD New( oWndParent, nLeft, nTop, nRight, nBottom, lPress, nStyle ) CLASS HRect
   LOCAL nCor1, nCor2

   IF nStyle = NIL
      nStyle := 3
   ENDIF
   IF lPress
      nCor2 := COLOR_3DHILIGHT
      nCor1 := COLOR_3DSHADOW
   ELSE
      nCor1 := COLOR_3DHILIGHT
      nCor2 := COLOR_3DSHADOW
   ENDIF

   DO CASE
   CASE nStyle = 1
      ::oLine1 = HRect_Line():New( oWndParent, , .F., nLeft,  nTop,    nRight - nLeft, , nCor1 )
      ::oLine3 = HRect_Line():New( oWndParent, , .F., nLeft,  nBottom, nRight - nLeft, , nCor2 )

   CASE nStyle = 2
      ::oLine2 = HRect_Line():New( oWndParent, , .T., nLeft,  nTop,    nBottom - nTop, , nCor1 )
      ::oLine4 = HRect_Line():New( oWndParent, , .T., nRight, nTop,    nBottom - nTop, , nCor2 )

   OTHERWISE
      ::oLine1 = HRect_Line():New( oWndParent, , .F., nLeft,  nTop,    nRight - nLeft, , nCor1 )
      ::oLine2 = HRect_Line():New( oWndParent, , .T., nLeft,  nTop,    nBottom - nTop, , nCor1 )
      ::oLine3 = HRect_Line():New( oWndParent, , .F., nLeft,  nBottom, nRight - nLeft, , nCor2 )
      ::oLine4 = HRect_Line():New( oWndParent, , .T., nRight, nTop,    nBottom - nTop, , nCor2 )
   ENDCASE

   RETURN Self

//---------------------------------------------------------------------------
CLASS HRect_Line INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA lVert
   DATA oPen

   METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, nColor )
   METHOD Activate()
   METHOD Paint( lpDis )

ENDCLASS

//---------------------------------------------------------------------------
METHOD New( oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, nColor ) CLASS HRect_Line

   ::Super:New( oWndParent, nId, SS_OWNERDRAW, nLeft, nTop,,,,, bSize, { | o, lp | o:Paint( lp ) } )

   //::title := ""
   ::lVert := IIf( lVert == NIL, .F., lVert )
   IF ::lVert
      ::nWidth  := 10
      ::nHeight := IIf( nLength == NIL, 20, nLength )
   ELSE
      ::nWidth  := IIf( nLength == NIL, 20, nLength )
      ::nHeight := 10
   ENDIF
   ::oPen := HPen():Add( BS_SOLID, 1, hwg_Getsyscolor( nColor ) )

   ::Activate()

   RETURN Self

//---------------------------------------------------------------------------
METHOD Activate() CLASS HRect_Line

   IF ! Empty( ::oParent:handle )
      ::handle := hwg_Createstatic( ::oParent:handle, ::id, ;
            ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      ::Init()
   ENDIF

   RETURN NIL

//---------------------------------------------------------------------------
METHOD Paint( lpdis ) CLASS HRect_Line
   LOCAL drawInfo := hwg_Getdrawiteminfo( lpdis )
   LOCAL hDC := drawInfo[ 3 ], x1 := drawInfo[ 4 ], y1 := drawInfo[ 5 ], x2 := drawInfo[ 6 ], y2 := drawInfo[ 7 ]

   hwg_Selectobject( hDC, ::oPen:handle )

   IF ::lVert
      hwg_Drawline( hDC, x1, y1, x1, y2 )
   ELSE
      hwg_Drawline( hDC, x1, y1, x2, y1 )
   ENDIF

   RETURN NIL

//Contribution   Luis Fernando Basso

CLASS HShape INHERIT HControl

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, nBorder, nCurvature, ;
         nbStyle, nfStyle, tcolor, bcolor, bSize, bInit, nBackStyle )  //, bClick, bDblClick)

ENDCLASS

METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, nBorder, nCurvature, ;
      nbStyle, nfStyle, tcolor, bcolor, bSize, bInit, nBackStyle ) CLASS HShape

   nBorder := IIf( nBorder = NIL, 1, nBorder )
   nbStyle := IIf( nbStyle = NIL, PS_SOLID, nbStyle )
   nfStyle := IIf( nfStyle = NIL, BS_TRANSPARENT , nfStyle )
   nCurvature := nCurvature

   RETURN HDrawShape():New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, bSize, tcolor, bcolor,,, ;
         nBorder, nCurvature, nbStyle, nfStyle, bInit, nBackStyle )

//---------------------------------------------------------------------------
CLASS HLContainer INHERIT HControl

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, nStyle, bSize, lnoBorder, bInit )  //, bClick, bDblClick)

ENDCLASS


METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, nStyle, bSize, lnoBorder, bInit ) CLASS HLContainer

   nStyle := IIf( nStyle = NIL, 3, nStyle )  // FLAT
   lnoBorder := IIf( lnoBorder = NIL, .F., lnoBorder )  // FLAT

   RETURN HDrawShape():New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, bSize,,, nStyle, lnoBorder,,,,, bInit ) //,bClick, bDblClick)

//---------------------------------------------------------------------------
CLASS HDrawShape INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA oPen, oBrush
   DATA ncStyle, nbStyle, nfStyle
   DATA nCurvature
   DATA nBorder, lnoBorder
   DATA brushFill
   DATA bClick, bDblClick

   METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, bSize, tcolor, bColor, ncStyle, ;
         lnoBorder, nBorder, nCurvature, nbStyle, nfStyle, bInit, nBackStyle )
   METHOD Activate()
   METHOD Paint( lpDis )
   METHOD SetColor( tcolor, bcolor, lRedraw )
   METHOD Curvature( nCurvature )
   //METHOD Refresh() INLINE hwg_Sendmessage( ::handle, WM_PAINT, 0, 0 ), hwg_Redrawwindow( ::handle, RDW_ERASE + RDW_INVALIDATE )

ENDCLASS

METHOD New( oWndParent, nId, nLeft, nTop, nWidth, nHeight, bSize, tcolor, bColor, ncStyle, ;
      lnoBorder, nBorder, nCurvature, nbStyle, nfStyle, bInit, nBackStyle )  CLASS HDrawShape

   HB_SYMBOL_UNUSED( ncStyle )

   ::bPaint   := { | o, p | o:paint( p ) }
   ::Super:New( oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, ,;
         bInit, bSize, ::bPaint, , tcolor, bColor ) //= NIL

   //::title := ""
   // OPAQUE DEFAULT
   ::backStyle := IIF( nbackStyle = NIL, OPAQUE, nbackStyle )
   ::lnoBorder := lnoBorder
   ::nBorder := nBorder
   ::nbStyle := nbStyle
   ::nfStyle := nfStyle
   ::nCurvature := nCurvature
   ::SetColor( ::tcolor , ::bColor )

   ::Activate()

   IF ::ncStyle == NIL
      ::oPen := HPen():Add( ::nbStyle, ::nBorder, ::tColor )
   //ELSE  // CONTAINER
   //    ::oPen := HPen():Add( PS_SOLID, 5, hwg_Getsyscolor( COLOR_3DHILIGHT ) )
   ENDIF

   RETURN Self

//---------------------------------------------------------------------------
METHOD Activate() CLASS HDrawShape

   IF ! Empty( ::oParent:handle )
      ::handle := hwg_Createstatic( ::oParent:handle, ::id, ;
            ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      ::Init()
   ENDIF

   RETURN NIL

METHOD SetColor( tcolor, bColor, lRedraw ) CLASS HDrawShape

   ::brushFill := HBrush():Add( tColor, ::nfstyle )
   ::Super:SetColor( tColor, bColor )
   IF ! Empty( lRedraw )
      hwg_Redrawwindow( ::handle, RDW_ERASE + RDW_INVALIDATE )
   ENDIF

   RETURN NIL

METHOD Curvature( nCurvature ) CLASS HDrawShape

   IF nCurvature != NIL
      ::nCurvature := nCurvature
      hwg_Redrawwindow( ::oParent:Handle, RDW_ERASE + RDW_INVALIDATE + RDW_ERASENOW, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      hwg_Invalidaterect( ::oParent:Handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight )
   ENDIF

   RETURN NIL

//---------------------------------------------------------------------------
METHOD Paint( lpdis ) CLASS HDrawShape
   LOCAL drawInfo := hwg_Getdrawiteminfo( lpdis )
   LOCAL hDC := drawInfo[ 3 ], oldbkMode
   LOCAL  x1 := drawInfo[ 4 ], y1 := drawInfo[ 5 ]
   LOCAL  x2 := drawInfo[ 6 ], y2 := drawInfo[ 7 ]

   oldbkMode := hwg_Setbkmode( hdc, ::backStyle )
   hwg_Selectobject( hDC, ::oPen:handle )
   IF ::ncStyle != NIL
      /*
      IF ::lnoBorder = .F.
         IF ::ncStyle == 0      // RAISED
            hwg_Drawedge( hDC, x1, y1, x2, y2, BDR_RAISED, BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM )  // raised  forte      8
         ELSEIF ::ncStyle == 1  // sunken
            hwg_Drawedge( hDC, x1, y1, x2, y2, BDR_SUNKEN, BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM ) // sunken mais forte
         ELSEIF ::ncStyle == 2  // FRAME
            hwg_Drawedge( hDC, x1, y1, x2, y2, BDR_RAISED + BDR_RAISEDOUTER, BF_LEFT + BF_TOP + BF_RIGHT + BF_BOTTOM ) // FRAME
         ELSE                   // FLAT
            hwg_Drawedge( hDC, x1, y1, x2, y2, BDR_SUNKENINNER, BF_TOP )
            hwg_Drawedge( hDC, x1, y1, x2, y2, BDR_RAISEDOUTER, BF_BOTTOM )
            hwg_Drawedge( hDC, x1, y2, x2, y1, BDR_SUNKENINNER, BF_LEFT )
            hwg_Drawedge( hDC, x1, y2, x2, y1, BDR_RAISEDOUTER, BF_RIGHT )
         ENDIF
      ELSE
         hwg_Drawedge( hDC, x1, y1, x2, y2, 0, 0 )
      ENDIF
      */
   ELSE
      IF ::backStyle = OPAQUE
         IF ::Brush != NIL
            hwg_Selectobject( hDC, ::Brush:handle )
         ENDIF
         //hwg_Roundrect( hDC, x1 + 1, y1 + 1, x2, y2 , ::nCurvature, ::nCurvature)
      ENDIF
      IF ::nfStyle != BS_TRANSPARENT .OR. ::backStyle = OPAQUE
         hwg_Selectobject( hDC, ::BrushFill:handle )
      ELSE
         hwg_Selectobject( hDC, hwg_Getstockobject( NULL_BRUSH ) )
      ENDIF
      hwg_Roundrect( hDC, x1 + 1, y1 + 1, x2, y2 , ::nCurvature, ::nCurvature)
   ENDIF
   hwg_Setbkmode( hDC, oldbkMode )

   RETURN NIL

// END NEW CLASSE
//-----------------------------------------------------------------
FUNCTION hwg_Rect( oWndParent, nLeft, nTop, nRight, nBottom, lPress, nST )


   IF lPress = NIL
      lPress := .F.
   ENDIF

   RETURN  HRect():New( oWndParent, nLeft, nTop, nRight, nBottom, lPress, nST )

//---------------------------------------------------------------------------
CLASS HContainer INHERIT HControl, HScrollArea

   CLASS VAR winclass   INIT "STATIC"
   DATA oPen, oBrush
   DATA ncStyle   INIT 3
   DATA nBorder
   DATA lnoBorder INIT .T.
   DATA bLoad
   DATA bClick, bDblClick
   DATA lCreate   INIT .F.
   DATA xVisible  INIT .T. HIDDEN
   DATA lTABSTOP INIT .F. HIDDEN

   METHOD New( oWndParent, nId, nstyle, nLeft, nTop, nWidth, nHeight, ncStyle, bSize,;
         lnoBorder, bInit, nBackStyle, tcolor, bcolor, bLoad, bRefresh, bOther)  //, bClick, bDblClick)
   METHOD Activate()
   METHOD Init()
   METHOD Create( ) INLINE ::lCreate := .T.
   METHOD onEvent( msg, wParam, lParam )
   METHOD Paint( lpDis )
   METHOD Visible( lVisibled ) SETGET

ENDCLASS

METHOD New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ncStyle, bSize,;
      lnoBorder, bInit, nBackStyle, tcolor, bcolor, bLoad, bRefresh, bOther) CLASS HContainer  //, bClick, bDblClick)

   ::lTABSTOP :=  nStyle = WS_TABSTOP
   ::bPaint   := { | o, p | o:paint( p ) }
   nStyle := SS_OWNERDRAW + IIF( nStyle = WS_TABSTOP, WS_TABSTOP , 0 ) + Hwg_Bitand( nStyle, SS_NOTIFY )
   ::Super:New( oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, , ;
         bInit, bSize, ::bPaint,, tcolor, bColor )

   //::title := ""
   ::ncStyle := IIF( ncStyle = NIL .AND. nStyle < WS_TABSTOP, 3, ncStyle )
   ::lnoBorder := IIF( lnoBorder = NIL, .F., lnoBorder )
   ::backStyle := IIF( nbackStyle = NIL, OPAQUE, nbackStyle ) // OPAQUE DEFAULT
   ::bLoad := bLoad
   ::bRefresh := bRefresh
   ::bOther := bOther
   ::SetColor( ::tColor, ::bColor )
   ::Activate()
   IF ::bLoad != NIL
      // SET ENVIRONMENT
      Eval( ::bLoad,Self )
   ENDIF
   ::oPen := HPen():Add( PS_SOLID, 1, hwg_Getsyscolor( COLOR_3DHILIGHT ) )

  RETURN Self

//---------------------------------------------------------------------------
METHOD Activate() CLASS HContainer

   IF !Empty( ::oParent:handle )
      ::handle := hwg_Createstatic( ::oParent:handle, ::id, ::style, ;
            ::nLeft, ::nTop, ::nWidth, ::nHeight )
      IF ! ::lInit
         hwg_Addtooltip( ::handle, ::handle, "" )
         ::nHolder := 1
         hwg_Setwindowobject( ::handle, Self )
         Hwg_InitStaticProc( ::handle )
         ::linit := .T.
         IF Empty( ::oParent:oParent ) .AND. ::oParent:Type >= WND_DLG_RESOURCE
            ::Create()
            ::lCreate := .T.
         ENDIF
      ENDIF
      ::Init()
   ENDIF
   IF ! ::lCreate
      ::Create()
      ::lCreate := .T.
   ENDIF

   RETURN NIL

METHOD Init() CLASS HContainer

   IF ! ::lInit
      ::Super:init()
      hwg_Addtooltip( ::handle, ::handle, "" )
      ::nHolder := 1
      hwg_Setwindowobject( ::handle, Self )
      Hwg_InitStaticProc( ::handle )
      //hwg_Setwindowpos( ::Handle, HWND_BOTTOM, 0, 0, 0, 0 , SWP_NOSIZE + SWP_NOMOVE + SWP_NOZORDER)
   ENDIF

   RETURN  NIL

METHOD onEvent( msg, wParam, lParam ) CLASS HContainer
   LOCAL nEval

   IF ::bOther != NIL
      IF ( nEval := Eval( ::bOther,Self,msg,wParam,lParam ) ) != NIL .AND. nEval != -1
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_PAINT
      RETURN - 1
   ELSEIF msg == WM_ERASEBKGND
      RETURN 0
   ENDIF
   IF ::lTABSTOP
      IF msg == WM_SETFOCUS
         hwg_GetSkip( ::oparent, ::handle, , ::nGetSkip )
      ELSEIF msg == WM_KEYUP
         IF wParam = VK_DOWN
            hwg_GetSkip( ::oparent, ::handle, , 1 )
         ELSEIF  wParam = VK_UP
            hwg_GetSkip( ::oparent, ::handle, , -1 )
         ELSEIF wParam = VK_TAB
            hwg_GetSkip( ::oParent, ::handle, , iif( hwg_IsCtrlShift(.F., .T.), -1, 1) )
         ENDIF
         RETURN 0
      ELSEIF msg = WM_SYSKEYUP
      ENDIF
   ENDIF

   RETURN ::Super:onEvent( msg, wParam, lParam )

METHOD Visible( lVisibled ) CLASS HContainer

   IF lVisibled != NIL
      IF lVisibled
         ::Show()
      ELSE
         ::Hide()
      ENDIF
      ::xVisible := lVisibled
   ENDIF

   RETURN ::xVisible

//---------------------------------------------------------------------------
METHOD Paint( lpdis ) CLASS HContainer
   LOCAL drawInfo, hDC
   LOCAL x1, y1, x2, y2

   drawInfo := hwg_Getdrawiteminfo( lpdis )
   hDC := drawInfo[ 3 ]
   x1  := drawInfo[ 4 ]
   y1  := drawInfo[ 5 ]
   x2  := drawInfo[ 6 ]
   y2  := drawInfo[ 7 ]

   hwg_Selectobject( hDC, ::oPen:handle )

   IF ::ncStyle != NIL
      hwg_Setbkmode( hDC, ::backStyle )
      IF ! ::lnoBorder
         IF ::ncStyle == 0      // RAISED
            hwg_Drawedge( hDC, x1, y1, x2, y2,BDR_RAISED,BF_LEFT+BF_TOP+BF_RIGHT+BF_BOTTOM)  // raised  forte      8
         ELSEIF ::ncStyle == 1  // sunken
            hwg_Drawedge( hDC, x1, y1, x2, y2,BDR_SUNKEN,BF_LEFT+BF_TOP+BF_RIGHT+BF_BOTTOM ) // sunken mais forte
         ELSEIF ::ncStyle == 2  // FRAME
            hwg_Drawedge( hDC, x1, y1, x2, y2,BDR_RAISED+BDR_RAISEDOUTER,BF_LEFT+BF_TOP+BF_RIGHT+BF_BOTTOM) // FRAME
         ELSE                   // FLAT
            hwg_Drawedge( hDC, x1, y1, x2, y2,BDR_SUNKENINNER,BF_TOP)
            hwg_Drawedge( hDC, x1, y1, x2, y2,BDR_RAISEDOUTER,BF_BOTTOM)
            hwg_Drawedge( hDC, x1, y2, x2, y1,BDR_SUNKENINNER,BF_LEFT)
            hwg_Drawedge( hDC, x1, y2, x2, y1,BDR_RAISEDOUTER,BF_RIGHT)
         ENDIF
      ELSE
         hwg_Drawedge( hDC, x1, y1, x2, y2,0,0)
      ENDIF
      IF ::backStyle != TRANSPARENT
         IF ::Brush != NIL
            hwg_Fillrect( hDC, x1 + 2, y1 + 2, x2 - 2, y2 - 2 , ::brush:handle )
         ENDIF
      ELSE
         hwg_Fillrect( hDC, x1 + 2, y1 + 2, x2 - 2, y2 - 2 , hwg_Getstockobject( 5 ) )
      ENDIF
      //hwg_Setbkmode( hDC, 0 )
   ENDIF

   RETURN 1

// END NEW CLASSE
