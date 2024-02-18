/*
 *$Id: barcode.prg 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * HWGUI - Harbour Win32 GUI library
 *
 * File to Demonstrate Display Barcode to Form and Printer
 * using hwgui xml technique.
 *
 * Copyright 2010 Richard Roesnadi <richsoft8@yahoo.com.id>
 * www - http://www.richard-software.com
*/



EXTERNAL HBARCODE

PROCEDURE SHOWBARCODE

 HFORMTMPL():READ("BARCODE.XML"):SHOWMODAL()

RETURN
