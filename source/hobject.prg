/*
 * HWGUI - Harbour Win32 GUI library source code:
 * HObject class
 *
 * Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"

#ifndef __XHARBOUR__
REQUEST HB_GT_GUI_DEFAULT
#endif

CLASS HObject

   DATA aObjects     INIT {}
   METHOD AddObject(oCtrl) INLINE AAdd(::aObjects, oCtrl)
   METHOD DelObject(oCtrl)
   METHOD Release() INLINE ::DelObject(Self)

ENDCLASS

METHOD DelObject(oCtrl) CLASS HObject

   LOCAL h := oCtrl:handle
   LOCAL i := Ascan(::aObjects, {|o|o:handle == h})

   hwg_Sendmessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      Adel(::aObjects, i)
      Asize(::aObjects, Len(::aObjects) - 1)
   ENDIF
   RETURN NIL

PROCEDURE HB_GT_DEFAULT_NUL()
RETURN

INIT PROCEDURE HWGINIT

   hwg_ErrSys()

RETURN
