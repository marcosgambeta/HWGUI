/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HLine class
 *
 * Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"
#include "common.ch"

#define  CONTROL_FIRST_ID   34000
#define TRANSPARENT 1

   // HLine

CLASS HLine INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA lVert
   DATA LineSlant
   DATA nBorder
   DATA oPenLight, oPenGray

   METHOD New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, bInit, tcolor, nHeight, cSlant, nBorder)
   METHOD Activate()
   METHOD Paint(lpDis)

ENDCLASS

METHOD New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize, bInit, tcolor, nHeight, cSlant, nBorder) CLASS HLine

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, , , , bInit, ;
      bSize, {|o, lp|o:Paint(lp)} , , tcolor)

   ::title := ""
   ::lVert := iif(lVert == NIL, .F., lVert)
   ::LineSlant := iif(Empty(cSlant) .OR. !cSlant $ "/\", "", cSlant)
   ::nBorder := iif(Empty(nBorder), 1, nBorder)

   IF Empty(::LineSlant)
      IF ::lVert
         ::nWidth  := ::nBorder + 1 //10
         ::nHeight := iif(nLength == NIL, 20, nLength)
      ELSE
         ::nWidth  := iif(nLength == NIL, 20, nLength)
         ::nHeight := ::nBorder + 1 //10
      ENDIF
      ::oPenLight := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DHILIGHT))
      ::oPenGray  := HPen():Add(BS_SOLID, 1, hwg_Getsyscolor(COLOR_3DSHADOW))
   ELSE
      ::nWidth  := nLength
      ::nHeight := nHeight
      ::oPenLight := HPen():Add(BS_SOLID, ::nBorder, tColor)
   ENDIF

   ::Activate()

   RETURN Self

METHOD Activate() CLASS HLine

   IF !Empty(::oParent:handle)
      ::handle := hwg_Createstatic(::oParent:handle, ::id, ::style, ;
         ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

   RETURN NIL

METHOD Paint(lpdis) CLASS HLine
   LOCAL drawInfo := hwg_Getdrawiteminfo(lpdis)
   LOCAL hDC := drawInfo[3]
   LOCAL x1  := drawInfo[4], y1 := drawInfo[5]
   LOCAL x2  := drawInfo[6], y2 := drawInfo[7]

   hwg_Selectobject(hDC, ::oPenLight:handle)

   IF Empty(::LineSlant)
      IF ::lVert
         hwg_Drawline(hDC, x1 + 1, y1, x1 + 1, y2)
      ELSE
         hwg_Drawline(hDC, x1, y1 + 1, x2, y1 + 1)
      ENDIF
      hwg_Selectobject(hDC, ::oPenGray:handle)
      IF ::lVert
         hwg_Drawline(hDC, x1, y1, x1, y2)
      ELSE
         hwg_Drawline(hDC, x1, y1, x2, y1)
      ENDIF
   ELSE
      IF (x2 - x1) <= ::nBorder
         hwg_Drawline(hDC, x1, y1, x1, y2)
      ELSEIF (y2 - y1) <= ::nBorder
         hwg_Drawline(hDC, x1, y1, x2, y1)
      ELSEIF ::LineSlant == "/"
         hwg_Drawline(hDC, x1, y1 + y2, x1 + x2, y1)
      ELSEIF ::LineSlant == "\"
         hwg_Drawline(hDC, x1, y1, x1 + x2, y1 + y2)
      ENDIF
   ENDIF

   RETURN NIL
