# HWGUI
HWGUI 2.17 - fork for personal use

## Compatibility

* Harbour  
* xHarbour  
* Harbour++  
* C and C++ compilers  
* 32-bit and 64-bit  

## Building

### xHarbour and BCC

Option 1:

```
set HB_PATH=C:\xharbour
set __XHARBOUR__=ON
make_b32.bat
```

Option 2:

Copy hbmk2 from Harbour to xHarbour

```
hbmk2 hwguiall.hbp -xhb
```

### Harbour++ and MinGW

```
hbmk2 hwguiall.hbp -cflag=-fpermissive
```

## Notes

The source code is unstable with the flag 'HWG_USE_POINTER_ITEM' active. While the source code
is being revised, the flag will remain disabled. But you can active in the file hwgui.hbp.

```
#-cflag=-DHWG_USE_POINTER_ITEM
```

If you have problems compiling/using this repository, open a issue. Dont forget to tell the tools and versions that you are using.

This repository is a fork. The original code can be found at the link below:

https://sourceforge.net/p/hwgui/code/HEAD/tree/branches/hwgui_2_17/
