#include "hwgui.ch"

PROCEDURE Main()

   LOCAL oDialog
   LOCAL oLabel1
   LOCAL oLabel2
   LOCAL oTimer1
   LOCAL oTimer2

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 20, 20 SAY oLabel1 CAPTION time() SIZE 120, 30
   @ 20, 60 SAY oLabel2 CAPTION substr(time(), 7, 2) SIZE 120, 30

   SET TIMER oTimer1 OF oDialog VALUE 1000 ACTION {||oLabel1:SetText(time())}
   SET TIMER oTimer2 OF oDialog VALUE 1000 ACTION {||oLabel2:SetText(substr(time(), 7, 2))}

   ACTIVATE DIALOG oDialog

RETURN
