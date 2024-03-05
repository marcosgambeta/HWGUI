/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HBitmap class
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "hbclass.ch"
#include "windows.ch"
#include "guilib.ch"

CLASS HBitmap INHERIT HObject

   CLASS VAR aBitmaps   INIT {}
   CLASS VAR lSelFile   INIT .T.
   DATA handle
   DATA name
   DATA nFlags
   DATA nWidth, nHeight
   DATA nCounter   INIT 1

   METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight)
   METHOD AddStandard(nId)
   METHOD AddFile(name, hDC, lTranparent, nWidth, nHeight)
   METHOD AddWindow(oWnd, lFull)
   METHOD Draw(hDC, x1, y1, width, height) INLINE hwg_Drawbitmap(hDC, ::handle, SRCCOPY, x1, y1, width, height)
   METHOD RELEASE()

ENDCLASS

METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight) CLASS HBitmap
   LOCAL lPreDefined := .F., i, aBmpSize

   IF nFlags == NIL
      nFlags := LR_DEFAULTCOLOR
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   IF HB_ISNUMERIC(name)
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
#ifdef __XHARBOUR__
   FOR EACH i  IN  ::aBitmaps
      IF i:name == name .AND. i:nFlags == nFlags .AND. ;
            ((nWidth == NIL .OR. nHeight == NIL) .OR. ;
            (i:nWidth == nWidth .AND. i:nHeight == nHeight))
         i:nCounter++
         RETURN i
      ENDIF
   NEXT
#else
   FOR i := 1 TO Len(::aBitmaps)
      IF ::aBitmaps[i]:name == name .AND. ::aBitmaps[i]:nFlags == nFlags .AND. ;
            ((nWidth == NIL .OR. nHeight == NIL) .OR. ;
            (::aBitmaps[i]:nWidth == nWidth .AND. ::aBitmaps[i]:nHeight == nHeight))
         ::aBitmaps[i]:nCounter++
         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
#endif
   IF lOEM
      ::handle := hwg_Loadimage(0, Val(name), IMAGE_BITMAP, NIL, NIL, Hwg_bitor(nFlags, LR_SHARED))
   ELSE
      //::handle := hwg_Loadimage(NIL, IIf(lPreDefined, Val(name), name), IMAGE_BITMAP, NIL, NIL, nFlags)
      ::handle := hwg_Loadimage(NIL, IIf(lPreDefined, Val(name), name), IMAGE_BITMAP, nWidth, nHeight, nFlags)
   ENDIF
   ::name := name
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   ::nFlags := nFlags
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddStandard(nId) CLASS HBitmap
   LOCAL i, aBmpSize, name := "s" + LTrim(Str(nId))

#ifdef __XHARBOUR__

   FOR EACH i  IN  ::aBitmaps
      IF i:name == name
         i:nCounter++
         RETURN i
      ENDIF
   NEXT
#else
   FOR i := 1 TO Len(::aBitmaps)
      IF ::aBitmaps[i]:name == name
         ::aBitmaps[i]:nCounter++
         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
#endif
   ::handle := hwg_Loadbitmap(nId, .T.)
   ::name := name
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddFile(name, hDC, lTranparent, nWidth, nHeight) CLASS HBitmap
   LOCAL i, aBmpSize, cname := CutPath(name), cCurDir

#ifdef __XHARBOUR__
   FOR EACH i IN ::aBitmaps
      IF i:name == cname .AND. (nWidth == NIL .OR. nHeight == NIL)
         i:nCounter++
         RETURN i
      ENDIF
   NEXT
#else
   FOR i := 1 TO Len(::aBitmaps)
      IF ::aBitmaps[i]:name == cname .AND. (nWidth == NIL .OR. nHeight == NIL)
         ::aBitmaps[i]:nCounter++
         RETURN ::aBitmaps[i]
      ENDIF
   NEXT
#endif
   name := IIf(!File(name) .AND. File(cname), cname, name)
   IF ::lSelFile .AND. !File(name)
      cCurDir := DiskName() + ":\" + CurDir()
      name := hwg_SelectFile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", CutPath(name), FilePath(name), "Locate " + name) //"*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF

   IF Lower(Right(name, 4)) != ".bmp" .OR. (nWidth == NIL .AND. nHeight == NIL .AND. lTranparent == NIL)
      IF Lower(Right(name, 4)) == ".bmp"
         ::handle := hwg_Openbitmap(name, hDC)
      ELSE
         ::handle := hwg_Openimage(name)
      ENDIF
   ELSE
      IF lTranparent != NIL .AND. lTranparent
         ::handle := hwg_Loadimage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE + LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS)
      ELSE
         ::handle := hwg_Loadimage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE)
      ENDIF
   ENDIF
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name := cname
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD AddWindow(oWnd, lFull) CLASS HBitmap
   LOCAL aBmpSize

   ::handle := hwg_Window2bitmap(oWnd:handle, lFull)
   ::name := LTrim(hb_valToStr(oWnd:handle))
   aBmpSize := hwg_Getbitmapsize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, Self)

   RETURN Self

METHOD RELEASE() CLASS HBitmap
   LOCAL i, nlen := Len(::aBitmaps)

   ::nCounter--
   IF ::nCounter == 0
#ifdef __XHARBOUR__
      FOR EACH i IN ::aBitmaps
         IF i:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, hB_enumIndex())
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#else
      FOR i := 1 TO nlen
         IF ::aBitmaps[i]:handle == ::handle
            hwg_Deleteobject(::handle)
            ADel(::aBitmaps, i)
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
#endif
   ENDIF

   RETURN NIL

EXIT PROCEDURE CleanBitmaps

   LOCAL i

   FOR i := 1 TO Len(HBitmap():aBitmaps)
      hwg_Deleteobject(HBitmap():aBitmaps[i]:handle)
   NEXT

   RETURN
