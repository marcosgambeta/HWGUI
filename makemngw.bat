@echo off
if "%1" == "clean" goto CLEAN
if "%1" == "CLEAN" goto CLEAN

:BUILD

   set CONTRIB_SUPPORT=ON
   rem set path=d:\softools\mingw\bin
   mingw32-make.exe -f makefile.gcc
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   goto EXIT

:BUILD_ERR

   goto EXIT

:CLEAN
   del lib\*.a
   del lib\*.bak
   del obj\*.o
   del obj\*.c

   goto EXIT

:EXIT
