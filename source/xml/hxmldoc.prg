/*
 * $Id: hxmldoc.prg 2080 2013-06-16 11:37:38Z alkresin $
 *
 * Harbour XML Library
 * HXmlDoc class
 *
 * Copyright 2003 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
*/

#include "hbclass.ch"
#include "fileio.ch"
#include "hxml.ch"

//-------------------------------------------------------------------------------------------------------------------//

/*
 *  CLASS DEFINITION
 *  HXMLNode
 */

CLASS HXMLNode

   CLASS VAR nLastErr SHARED

   DATA title
   DATA type
   DATA aItems INIT {}
   DATA aAttr INIT {}
   DATA cargo

   METHOD New(cTitle, type, aAttr)
   METHOD Add(xItem)
   METHOD GetAttribute(cName, cType, xDefault)
   METHOD SetAttribute(cName, cValue)
   METHOD DelAttribute(cName)
   METHOD Save(handle, level)
   METHOD Find(cTitle, nStart)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD New(cTitle, type, aAttr, cValue) CLASS HXMLNode

   IF cTitle != NIL
      ::title := cTitle
   ENDIF
   IF aAttr != NIL
      ::aAttr := aAttr
   ENDIF
   ::type := Iif(type != NIL, type, HBXML_TYPE_TAG)
   IF cValue != NIL
      ::Add(cValue)
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD Add(xItem) CLASS HXMLNode

   AAdd(::aItems, xItem)

RETURN xItem

//-------------------------------------------------------------------------------------------------------------------//

METHOD GetAttribute(cName, cType, xDefault) CLASS HXMLNode

   LOCAL i := AScan(::aAttr, {|a|a[1] == cName})

   IF i != 0
      IF cType == NIL .OR. cType == "C"
         RETURN ::aAttr[i, 2]
      ELSEIF cType == "N"
         RETURN Val(::aAttr[i, 2])
      ELSEIF cType == "L"
         RETURN (Lower(::aAttr[i, 2]) $ ".t.;on.yes")
      ENDIF
   ENDIF

RETURN xDefault

//-------------------------------------------------------------------------------------------------------------------//

METHOD SetAttribute(cName, cValue) CLASS HXMLNode

   LOCAL i := AScan(::aAttr, {|a|a[1] == cName})

   IF i == 0
      AAdd(::aAttr, {cName, cValue})
   ELSE
      ::aAttr[i, 2] := cValue
   ENDIF

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//

METHOD DelAttribute(cName) CLASS HXMLNode

   LOCAL i := AScan(::aAttr, {|a|a[1] == cName})

   IF i != 0
      Adel(::aAttr, i)
      Asize(::aAttr, Len(::aAttr) - 1)
   ENDIF

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//

METHOD Save(handle, level) CLASS HXMLNode

   LOCAL i
   LOCAL s := Space(level * 2) + "<"
   LOCAL lNewLine

   IF !__mvExist("HXML_NEWLINE")
      __mvPrivate("HXML_NEWLINE")
      __mvPut("HXML_NEWLINE", .T.)
   ENDIF
   lNewLine := m->hxml_newline
   IF ::type == HBXML_TYPE_COMMENT
      s += "!--"
   ELSEIF ::type == HBXML_TYPE_CDATA
      s += "![CDATA["
   ELSEIF ::type == HBXML_TYPE_PI
      s += "?" + ::title
   ELSE
      s += ::title
   ENDIF
   IF ::type == HBXML_TYPE_TAG .OR. ::type == HBXML_TYPE_SINGLE
      FOR i := 1 TO Len(::aAttr)
         s += " " + ::aAttr[i, 1] + '="' + HBXML_Transform(::aAttr[i,2]) + '"'
      NEXT
   ENDIF
   IF ::type == HBXML_TYPE_PI
      s += "?>" + Chr(10)
      m->hxml_newline := .T.
   ELSEIF ::type == HBXML_TYPE_SINGLE
      s += "/>" + Chr(10)
      m->hxml_newline := .T.
   ELSEIF ::type == HBXML_TYPE_TAG
      s += ">"
      IF Empty(::aItems) .OR. (Len(::aItems) == 1 .AND. HB_ISCHAR(::aItems[1]) .AND. Len(::aItems[1]) + Len(s) < 80)
         lNewLine := m->hxml_newline := .F.
      ELSE
         s += Chr(10)
         lNewLine := m->hxml_newline := .T.
      ENDIF
   ENDIF
   IF handle >= 0
      FWrite(handle, s)
   ENDIF

   FOR i := 1 TO Len(::aItems)
      IF HB_ISCHAR(::aItems[i])
        IF handle >= 0
           IF ::type == HBXML_TYPE_CDATA .OR. ::type == HBXML_TYPE_COMMENT
              FWrite(handle, ::aItems[i])
           ELSE
              FWrite(handle, HBXML_Transform(::aItems[i]))
           ENDIF
           IF lNewLine
              FWrite(handle, Chr(10))
           ENDIF
        ELSE
           IF ::type == HBXML_TYPE_CDATA .OR. ::type == HBXML_TYPE_COMMENT
              s += ::aItems[i]
           ELSE
              s += HBXML_Transform(::aItems[i])
           ENDIF
           IF lNewLine
              s += Chr(10)
           ENDIF
        ENDIF
        m->hxml_newline := .F.
      ELSE
        s += ::aItems[i]:Save(handle, level + 1)
      ENDIF
   NEXT
   m->hxml_newline := .T.
   IF handle >= 0
      IF ::type == HBXML_TYPE_TAG
         FWrite(handle, IIf(lNewLine, Space(level * 2), "") + "</" + ::title + ">" + Chr(10))
      ELSEIF ::type == HBXML_TYPE_CDATA
         FWrite(handle, "]]>" + Chr(10))
      ELSEIF ::type == HBXML_TYPE_COMMENT
         FWrite(handle, "-->" + Chr(10))
      ENDIF
   ELSE
      IF ::type == HBXML_TYPE_TAG
         s += IIf(lNewLine, Space(level * 2), "") + "</" + ::title + ">" + Chr(10)
      ELSEIF ::type == HBXML_TYPE_CDATA
         s += "]]>" + Chr(10)
      ELSEIF ::type == HBXML_TYPE_COMMENT
         s += "-->" + Chr(10)
      ENDIF
      RETURN s
   ENDIF

RETURN ""

//-------------------------------------------------------------------------------------------------------------------//

METHOD Find(cTitle, nStart, block) CLASS HXMLNode

   LOCAL i

   IF nStart == NIL
      nStart := 1
   ENDIF
   DO WHILE .T.
      i := AScan(::aItems, {|a|Valtype(a) != "C" .AND. a:title == cTitle}, nStart)
      IF i == 0
         EXIT
      ELSE
         nStart := i
         IF block == NIL .OR. Eval(block, ::aItems[i])
            RETURN ::aItems[i]
         ELSE
            nStart++
         ENDIF
      ENDIF
   ENDDO

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

/*
 *  CLASS DEFINITION
 *  HXMLDoc
 */

CLASS HXMLDoc INHERIT HXMLNode

   METHOD New(encoding)
   METHOD Read(fname)
   METHOD ReadString(buffer) INLINE ::Read(, buffer)
   METHOD Save(fname, lNoHeader)
   METHOD Save2String() INLINE ::Save()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD New(encoding) CLASS HXMLDoc

   IF encoding != NIL
      Aadd(::aAttr, {"version", "1.0"})
      Aadd(::aAttr, {"encoding", encoding})
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD Read(fname, buffer) CLASS HXMLDoc

   LOCAL han

   IF fname != NIL
      han := FOpen(fname, FO_READ)
      ::nLastErr := 0
      IF han != -1
         ::nLastErr := hbxml_GetDoc(Self, han)
         FClose(han)
      ENDIF
   ELSEIF buffer != NIL
      ::nLastErr := hbxml_GetDoc(Self, buffer)
   ELSE
      RETURN NIL
   ENDIF

RETURN IIf(::nLastErr == 0, Self, NIL)

//-------------------------------------------------------------------------------------------------------------------//

METHOD Save(fname, lNoHeader) CLASS HXMLDoc

   LOCAL handle := -2
   LOCAL cEncod
   LOCAL i
   LOCAL s

   IF fname != NIL
      handle := FCreate(fname)
   ENDIF
   IF handle != -1
      IF lNoHeader == NIL .OR. !lNoHeader
         IF (cEncod := ::GetAttribute("encoding")) == NIL
            cEncod := "UTF-8"
         ENDIF
         s := '<?xml version="1.0" encoding="' + cEncod + '"?>' + Chr(10)
         IF fname != NIL
            FWrite(handle, s)
         ENDIF
      ELSE
         s := ""
      ENDIF
      FOR i := 1 TO Len(::aItems)
         s += ::aItems[i]:Save(handle, 0)
      NEXT
      IF fname != NIL
         FClose(handle)
      ELSE
         RETURN s
      ENDIF
   ENDIF

RETURN .T.

//-------------------------------------------------------------------------------------------------------------------//
