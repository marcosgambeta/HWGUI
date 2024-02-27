# HWGUI
Fork of the HWGUI v2.17

## Compatibility

* Harbour  
* xHarbour  
* Harbour++  
* C and C++ compilers  
* 32-bit and 64-bit  

## Building

### Harbour

```
hbmk2 hwguiall.hbp -gc3
```

The parameter -gc3 is optional. The binaries are bigger, but more faster.

### xHarbour and BCC

Option 1:

```
set HB_PATH=C:\xharbour
set __XHARBOUR__=ON
make_b32.bat
```

Option 2:

Copy hbmk2 from Harbour to xHarbour:

```
copy harbour\bin\hbmk2*.* xharbour\bin
```

Compile using the parameter -xhb:

```
hbmk2 hwguiall.hbp -xhb
```

Note: static libraries are OK, but fail creating the DLL
```
hbmk2: Criando biblioteca dinâmica... lib\win\bcc\hwguidyn-bcc.dll
Turbo Incremental Link 6.80 Copyright (c) 1997-2017 Embarcadero Technologies, Inc.
Fatal: Unable to open file 'HBMAINSTD.LIB'
hbmk2[hwguidyn]: Erro: Executando comando de linkagem da biblioteca dinâmica. 2
ilink32.exe @C:\Users\marco\AppData\Local\Temp\8naiv0.lnk
```

### Harbour++ and MinGW

```
hbmk2 hwguiall.hbp -cflag=-fpermissive -gc3
```

The parameter -gc3 is optional. The binaries are bigger, but more faster.

## Notes

The source code is unstable with the flag 'HWG_USE_POINTER_ITEM' active. While the source code
is being revised, the flag will remain disabled. But you can active in the file hwgui.hbp.

```
#-cflag=-DHWG_USE_POINTER_ITEM
```

If your project use deprecated functions (functions without the prefix hwg_), you can compile the HWGUI libraries
with the flag HWG_DEPRECATED_FUNCTIONS_ON:

```
hbmk2 hwguiall.hbp -cflag=-DHWG_DEPRECATED_FUNCTIONS_ON
```

If you have problems compiling/using this repository, open a issue. Dont forget to tell the tools and versions that you are using.

This repository is a fork. The original code can be found at the link below:

https://sourceforge.net/p/hwgui/code/HEAD/tree/branches/hwgui_2_17/
