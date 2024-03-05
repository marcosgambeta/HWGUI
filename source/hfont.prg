/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HFont class
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HFont INHERIT HObject

   CLASS VAR aFonts   INIT {}
   DATA handle
   DATA name, width, height, weight
   DATA charset, italic, Underline, StrikeOut
   DATA nCounter   INIT 1

   METHOD Add(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle)
   METHOD SELECT(oFont, nCharSet)
   METHOD RELEASE()
   METHOD SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight)

ENDCLASS

METHOD Add(fontName, nWidth, nHeight, fnWeight, ;
      fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut, nHandle) CLASS HFont

   LOCAL i, nlen := Len(::aFonts)

   nHeight := IIf(nHeight == NIL, -13, nHeight)
   fnWeight := IIf(fnWeight == NIL, 0, fnWeight)
   fdwCharSet := IIf(fdwCharSet == NIL, 0, fdwCharSet)
   fdwItalic := IIf(fdwItalic == NIL, 0, fdwItalic)
   fdwUnderline := IIf(fdwUnderline == NIL, 0, fdwUnderline)
   fdwStrikeOut := IIf(fdwStrikeOut == NIL, 0, fdwStrikeOut)

   FOR i := 1 TO nlen
      IF ::aFonts[i]:name == fontName .AND.          ;
            ::aFonts[i]:width == nWidth .AND.           ;
            ::aFonts[i]:height == nHeight .AND.         ;
            ::aFonts[i]:weight == fnWeight .AND.        ;
            ::aFonts[i]:CharSet == fdwCharSet .AND.     ;
            ::aFonts[i]:Italic == fdwItalic .AND.       ;
            ::aFonts[i]:Underline == fdwUnderline .AND. ;
            ::aFonts[i]:StrikeOut == fdwStrikeOut

         ::aFonts[i]:nCounter++
         IF nHandle != NIL
            hwg_Deleteobject(nHandle)
         ENDIF
         RETURN ::aFonts[i]
      ENDIF
   NEXT

   IF nHandle == NIL
      ::handle := hwg_Createfont(fontName, nWidth, nHeight, fnWeight, fdwCharSet, fdwItalic, fdwUnderline, fdwStrikeOut)
   ELSE
      ::handle := nHandle
   ENDIF

   ::name := fontName
   ::width := nWidth
   ::height := nHeight
   ::weight := fnWeight
   ::CharSet := fdwCharSet
   ::Italic := fdwItalic
   ::Underline := fdwUnderline
   ::StrikeOut := fdwStrikeOut

   AAdd(::aFonts, Self)

   RETURN Self

METHOD SELECT(oFont, nCharSet) CLASS HFont
   LOCAL af := hwg_SelectFont(oFont)

   IF af == NIL
      RETURN NIL
   ENDIF

   RETURN ::Add(af[2], af[3], af[4], af[5], IIf(Empty(nCharSet), af[6], nCharSet), af[7], af[8], af[9], af[1])

METHOD SetFontStyle(lBold, nCharSet, lItalic, lUnder, lStrike, nHeight) CLASS HFont
   LOCAL weight, Italic, Underline, StrikeOut

   IF lBold != NIL
      weight = IIf(lBold, FW_BOLD, FW_REGULAR)
   ELSE
      weight := ::weight
   ENDIF
   Italic := IIf(lItalic == NIL, ::Italic, IIf(lItalic, 1, 0))
   Underline := IIf(lUnder == NIL, ::Underline, IIf(lUnder, 1, 0))
   StrikeOut := IIf(lStrike == NIL, ::StrikeOut, IIf(lStrike, 1, 0))
   nheight := IIf(nheight == NIL, ::height, nheight)
   nCharSet := IIf(nCharSet == NIL, ::CharSet, nCharSet)

   RETURN HFont():Add(::name, ::width, nheight, weight, ;
      nCharSet, Italic, Underline, StrikeOut)

METHOD RELEASE() CLASS HFont
   LOCAL i, nlen := Len(::aFonts)

   ::nCounter--
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i IN ::aFonts
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aFonts, hb_enumindex())
            ASize(::aFonts, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aFonts[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aFonts, i)
            ASize(::aFonts, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL

EXIT PROCEDURE CleanFonts

   LOCAL i

   FOR i := 1 TO Len(HFont():aFonts)
      hwg_Deleteobject(HFont():aFonts[i]:handle)
   NEXT

   RETURN
