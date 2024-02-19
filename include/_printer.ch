// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand INIT PRINTER <oPrinter>   ;
             [ NAME <cPrinter> ]     ;
             [ <lPixel: PIXEL> ]     ;
             [ FORMTYPE  <nFormType> ];
             [ BIN <nBin> ];
             [ <lLandScape: LANDSCAPE>];
             [ COPIES <nCopies> ];
          =>  ;
          <oPrinter> := HPrinter():New( <cPrinter>,!<.lPixel.>, <nFormType>, <nBin>, <.lLandScape.>, <nCopies> )

#xcommand INIT DEFAULT PRINTER <oPrinter>   ;
             [ <lPixel: PIXEL> ]             ;
             [ FORMTYPE  <nFormType> ];
             [ BIN <nBin> ];
             [ <lLandScape: LANDSCAPE>];
             [ COPIES <nCopies> ];
          =>  ;
          <oPrinter> := HPrinter():New( "",!<.lPixel.>, <nFormType>, <nBin>, <.lLandScape.>, <nCopies>  )
