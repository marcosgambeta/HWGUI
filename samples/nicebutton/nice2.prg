#include "hwgui.ch"
#include "nice.h"

request nicebuttproc

FUNCTION Main()

   LOCAL o
   LOCAL o1

   init dialog o from resource DIALOG_1 title "nice button test"

   redefine nicebutton o1 caption "teste" of o id IDC_1 Red 125 Green 201 blue 36

   activate dialog o

RETURN NIL
