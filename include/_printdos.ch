// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand SET PRINTER TO <oPrinter> OF <oPtrObj>     ;
          => ;
          <oPtrObj>:=Printdos():New( <oPrinter>)

#xcommand @ <nX>,<nY> PSAY  <vari>  ;
             [ PICTURE <cPicture> ] OF <oPtrObj>   ;
          => ;
          <oPtrObj>:Say(<nX>, <nY>, <vari>, <cPicture>)

#xcommand EJECT OF <oPtrObj> => <oPtrObj>:Eject()

#xcommand END PRINTER <oPtrObj> => <oPtrObj>:End()
