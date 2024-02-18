#include "hwgui.ch"

Function Main
Local oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" AT 0, 0 SIZE hwg_Getdesktopwidth(), hwg_Getdesktopheight() - 28

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION oMainWindow:Close()
      MENUITEM "&More" ACTION DlgGet()
      MENUITEM "Shell ABout" ACTION hwg_Shellabout("Rodrigo Moreno", "Test")
      MENUITEM "Exclamation" ACTION hwg_Msgexclamation("Are You Sure ?", "Warning")
      MENUITEM "Retry Cancel" ACTION hwg_Msgretrycancel("Are You Sure ?", "Retry")
      MENUITEM "Calc" ACTION hwg_Shellexecute("calc")
   ENDMENU

   ACTIVATE WINDOW oMainWindow

Return Nil

Function DlgGet
Local oModDlg
Local oFont := HFont():Add("MS Sans Serif", 0, -13)
Local cRes, aCombo := {"First", "Second"}
Local oGet
Local e1 := "Dialog from prg", c1 := .F., c2 := .T., r1 := 2, cm := 1
Local upd := 12, d1 := Date()+1

   INIT DIALOG oModDlg TITLE "Test" AT 0, 0 SIZE 450, 350 FONT oFont ;
      STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU

   @ 20, 10 SAY "Input something:" SIZE 260, 22
   @ 20, 35 GET oGet VAR e1  ;
        STYLE WS_DLGFRAME   ;
        SIZE 260, 26 COLOR hwg_VColor("FF0000")

   @ 20, 70 GET CHECKBOX c1 CAPTION "Check 1" SIZE 90, 20
   @ 20, 95 GET CHECKBOX c2 CAPTION "Check 2" SIZE 90, 20 COLOR hwg_VColor("0000FF")

   @ 160, 70 GROUPBOX "RadioGroup" SIZE 130, 75

   GET RADIOGROUP r1
   @ 180, 90 RADIOBUTTON "Radio 1"  ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("0000FF"),,.T.)}
   @ 180, 115 RADIOBUTTON "Radio 2" ;
        SIZE 90, 20 ON CLICK {||oGet:SetColor(hwg_VColor("FF0000"),,.T.)}
   END RADIOGROUP

   @ 20, 120 GET COMBOBOX cm ITEMS aCombo SIZE 100, 150

   @ 20, 170 GET UPDOWN upd RANGE 0, 80 SIZE 50, 30
   @ 160, 170 GET DATEPICKER d1 SIZE 80, 20

   @  10, 240 BUTTON "Ok" ID IDOK SIZE 50, 32
   @  70, 240 BUTTON "Cancel" ID IDCANCEL SIZE 50, 32
   @ 130, 240 BUTTON "Enable/Disable" SIZE 100, 32 ON CLICK {|| IIF(oGet:IsEnabled(), oGet:Disable(), oGet:Enable())}
   @ 240, 240 BUTTON "SetFocus" SIZE 70, 32 ON CLICK {|| oGet:Setfocus() }
   @ 320, 240 BUTTON "Enabled ?" SIZE 70, 32 ON CLICK {|| IIF(oGet:IsEnabled(), hwg_Msginfo("Yes"), hwg_Msgstop("No")) }
   @ 400, 240 BUTTON "Close" SIZE 50, 32 ON CLICK {|| oModDlg:Close() }

   @  10, 280 BUTTON "WinDir" SIZE 100, 32 ON CLICK {|| hwg_Msginfo(hwg_Getwindowsdir()) }
   @ 120, 280 BUTTON "SystemDir" SIZE 100, 32 ON CLICK {|| hwg_Msginfo(hwg_Getsystemdir()) }
   @ 230, 280 BUTTON "TempDir" SIZE 100, 32 ON CLICK {|| hwg_Msginfo(hwg_Gettempdir()) }

   ACTIVATE DIALOG oModDlg

   oFont:Release()

   IF oModDlg:lResult
      hwg_Msginfo(e1 + chr(10) + chr(13) +                               ;
               "Check1 - " + Iif(c1,"On","Off") + chr(10) + chr(13) + ;
               "Check2 - " + Iif(c2,"On","Off") + chr(10) + chr(13) + ;
               "Radio: " + Str(r1, 1) + chr(10) + chr(13) +            ;
               "Combo: " + aCombo[cm] + chr(10) + chr(13) +           ;
               "UpDown: "+Str(upd) + chr(10) + chr(13) +              ;
               "DatePicker: "+Dtoc(d1),                               ;
               "Results:")
   ENDIF

Return Nil
