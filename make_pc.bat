@echo off

rem $Id: make_pc.bat 1623 2011-04-02 07:34:40Z druzus $
rem
rem Batch file for building under Pelles C
rem
rem Please modify environment accordingly
rem

SET POCCDIR=%POCC%
SET HARBOURDIR=%HB_PATH%
SET _PATH=%PATH%
SET PATH=%POCCDIR%\BIN;%HARBOURDIR%\BIN\XCC;%_PATH%

if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

if not exist lib md lib
if not exist obj md obj
 

:BUILD

   pomake /F makefile.pc HB_PATH=%HARBOURDIR% POCCMAIN=%POCCDIR% %1 %2
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   rem notepad make_b32.log
   goto EXIT

:CLEAN
   del lib\*.lib
   del lib\*.bak
   del obj\*.obj
   del obj\*.c
   del make_b32.log

   goto EXIT

:EXIT

SET PATH=%_PATH%
SET _PATH=
