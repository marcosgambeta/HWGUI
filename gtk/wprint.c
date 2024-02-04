/*
 * $Id: wprint.c 2037 2013-05-21 10:14:43Z alkresin $
 *
 * HWGUI - Harbour Linux (GTK) GUI library source code:
 * C level print functions
 *
 * Copyright 2013 Alexander S.Kresin <alex@kresin.ru>
 * www - http://www.kresin.ru
 */

#include "guilib.h"
#include "hbapi.h"
#include "hbapifs.h"
#include "hbapiitm.h"
#include "hbvm.h"

#include <locale.h>
#include "gtk/gtk.h"

#define DT_CENTER 1
#define DT_RIGHT 2
#define DT_VCENTER 4

#ifdef G_CONSOLE_MODE
static BOOL bGtypeInit = 0;
static gchar szAppLocale[] = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";

gchar *hwg_convert_to_utf8(const char *szText)
{
  if (*szAppLocale)
  {
    return g_convert(szText, -1, "UTF-8", szAppLocale, NULL, NULL, NULL);
  }
  else
  {
    return g_locale_to_utf8(szText, -1, NULL, NULL, NULL);
  }
}

gchar *hwg_convert_from_utf8(const char *szText)
{
  if (*szAppLocale)
  {
    return g_convert(szText, -1, szAppLocale, "UTF-8", NULL, NULL, NULL);
  }
  else
  {
    return g_locale_from_utf8(szText, -1, NULL, NULL, NULL);
  }
}

HB_FUNC(HWG_SETAPPLOCALE)
{
  memcpy(szAppLocale, hb_parc(1), hb_parclen(1));
  szAppLocale[hb_parclen(1)] = '\0';
}
#else
#include "hwgtk.h"
#endif

typedef struct HWGUI_PRINT_STRU
{
  GtkPageSetup *page_setup;
  char *cName;
  GtkWidget *label;
  int count;

} HWGUI_PRINT, *PHWGUI_PRINT;

PHWGUI_PRINT hwg_openprinter(void)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_xgrab(sizeof(HWGUI_PRINT));
  GtkPaperSize *A4 = gtk_paper_size_new(GTK_PAPER_NAME_A4);

#ifdef G_CONSOLE_MODE
  if (!bGtypeInit)
  {
    g_type_init();
    bGtypeInit = 1;
  }
#endif
  memset(print, 0, sizeof(HWGUI_PRINT));

  print->page_setup = gtk_page_setup_new();
  gtk_page_setup_set_paper_size_and_default_margins(print->page_setup, A4);

  gtk_page_setup_set_top_margin(print->page_setup, 1., GTK_UNIT_MM);
  gtk_page_setup_set_bottom_margin(print->page_setup, 1., GTK_UNIT_MM);
  gtk_page_setup_set_left_margin(print->page_setup, 1., GTK_UNIT_MM);
  gtk_page_setup_set_right_margin(print->page_setup, 1., GTK_UNIT_MM);

  return print;
}

HB_FUNC(HWG_OPENPRINTER)
{
  hb_retnl((HB_LONG)hwg_openprinter());
}

HB_FUNC(HWG_GETPRINTERS)
{
  HB_FHANDLE hInput = hb_fsOpen("/etc/printcap", FO_READ);
  PHB_ITEM aMetr = NULL, temp;

  if (hInput != -1)
  {
    HB_ULONG ulLen = hb_fsSeek(hInput, 0, FS_END);
    unsigned char *cBuffer, *ptr, *ptr1;

    hb_fsSeek(hInput, 0, FS_SET);
    cBuffer = (unsigned char *)hb_xgrab(ulLen + 1);
    ulLen = hb_fsReadLarge(hInput, cBuffer, ulLen);
    cBuffer[ulLen] = '\0';

    ptr = cBuffer;
    while (1)
    {
      while (*ptr && (*ptr == ' ' || *ptr == 0x9 || *ptr == 0x0a))
      {
        ptr++;
      }
      if (*ptr)
      {
        if (*ptr == '#')
        {
          while (*ptr && *ptr != 0x0a)
          {
            ptr++;
          }
          if (*ptr)
          {
            ptr++;
          }
          continue;
        }
        if (!aMetr)
        {
          aMetr = hb_itemArrayNew(0);
        }
        ptr1 = ptr;
        while (*ptr && *ptr != 0x0a && *ptr != '|')
        {
          ptr++;
        }
        temp = hb_itemPutCL(NULL, (char *)ptr1, ptr - ptr1);
        hb_arrayAdd(aMetr, temp);
        hb_itemRelease(temp);
        while (*ptr && *ptr != 0x0a)
        {
          ptr++;
        }
        if (*ptr)
        {
          ptr++;
        }
      }
      else
      {
        break;
      }
    }
    hb_xfree(cBuffer);
  }
  if (aMetr)
  {
    hb_itemReturn(aMetr);
    hb_itemRelease(aMetr);
  }
  else
  {
    hb_ret();
  }
}

/*
 * SetPrinterMode( print, nOrientation )
 */

HB_FUNC(HWG_SETPRINTERMODE)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_parnl(1);

  gtk_page_setup_set_orientation(print->page_setup,
                                 (hb_parni(2) == 1) ? GTK_PAGE_ORIENTATION_PORTRAIT : GTK_PAGE_ORIENTATION_LANDSCAPE);
}

HB_FUNC(HWG_CLOSEPRINTER)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_parnl(1);

  g_object_unref(G_OBJECT(print->page_setup));
  if (print->cName)
  {
    hb_xfree(print->cName);
  }
  hb_xfree(print);
}

void long2rgb(long int nColor, double *pr, double *pg, double *pb)
{
  short int r, g, b;

  nColor %= (65536 * 256);
  r = nColor % 256;
  g = ((nColor - r) % 65536) / 256;
  b = (nColor - g - r) / 65536;

  *pr = ((double)r) / 255.;
  *pg = ((double)g) / 255.;
  *pb = ((double)b) / 255.;
}

static void draw_page(cairo_t *cr, char *cpage)
{
  int iPathExist = 0;
  char *ptr, *ptre;
  char cBuf[512];
  double x1, y1, x2, y2;
  int iOpt, i1, i2;
  long int li;
  GdkPixbuf *pixbuf;
  cairo_text_extents_t exten;

  cairo_set_source_rgb(cr, 0, 0, 0);

  ptr = cpage;
  while (*ptr)
  {
    if (!strncmp(ptr, "txt", 3))
    {
      x1 = atof(ptr + 4);
      ptr = strchr(ptr + 4, ',');
      ptr++;
      y1 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      x2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      y2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      iOpt = atol(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      ptre = strchr(ptr, '\r');

      memcpy(cBuf, ptr, ptre - ptr);
      cBuf[ptre - ptr] = '\0';

      cairo_text_extents(cr, cBuf, &exten);
      if (exten.height < (y2 - y1))
      {
        if (iOpt & DT_VCENTER)
        {
          y2 = y2 - (y2 - y1 - exten.height) / 2;
        }
        else
        {
          y2 = y1 + 1 + exten.height;
        }
      }
      if (exten.width < (x2 - x1))
      {
        if (iOpt & DT_RIGHT)
        {
          x1 = x2 - exten.width - 1;
        }
        else if (iOpt & DT_CENTER)
        {
          x1 += (x2 - x1 - exten.width) / 2;
        }
      }
      cairo_move_to(cr, (gdouble)x1, (gdouble)y2);
      cairo_show_text(cr, cBuf);

      iPathExist = 1;
    }
    else if (!strncmp(ptr, "lin", 3))
    {
      x1 = atof(ptr + 4);
      ptr = strchr(ptr + 4, ',');
      ptr++;
      y1 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      x2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      y2 = atof(ptr);
      // ptr = strchr( ptr, ',' ); ptr++;
      // iOpt = atol( ptr );

      cairo_move_to(cr, (gdouble)x1, (gdouble)y1);
      cairo_line_to(cr, (gdouble)x2, (gdouble)y2);
      iPathExist = 1;
    }
    else if (!strncmp(ptr, "box", 3))
    {
      x1 = atof(ptr + 4);
      ptr = strchr(ptr + 4, ',');
      ptr++;
      y1 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      x2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      y2 = atof(ptr);

      cairo_rectangle(cr, (gdouble)x1, (gdouble)y1, (gdouble)(x2 - x1 + 1), (gdouble)(y2 - y1 + 1));
      iPathExist = 1;
    }
    else if (!strncmp(ptr, "fnt", 3))
    {
      if (iPathExist)
      {
        cairo_stroke(cr);
        iPathExist = 0;
      }

      ptr += 4;
      ptre = strchr(ptr, ',');
      memcpy(cBuf, ptr, ptre - ptr);
      cBuf[ptre - ptr] = '\0';
      ptr = ptre + 1;
      x1 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      i1 = (atoi(ptr) == 700) ? CAIRO_FONT_WEIGHT_BOLD : CAIRO_FONT_WEIGHT_NORMAL;
      ptr = strchr(ptr, ',');
      ptr++;
      i2 = (atoi(ptr) == 0) ? CAIRO_FONT_SLANT_NORMAL : CAIRO_FONT_SLANT_ITALIC;
      // g_debug( "font: %s %f %d %d", cBuf, d1, x1, y1 );

      cairo_select_font_face(cr, cBuf, i2, i1);
      cairo_set_font_size(cr, x1);
    }
    else if (!strncmp(ptr, "pen", 3))
    {
      x1 = atof(ptr + 4);
      ptr = strchr(ptr + 4, ',');
      ptr++;
      i1 = atoi(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      li = atol(ptr);

      if (iPathExist)
      {
        cairo_stroke(cr);
        iPathExist = 0;
      }

      cairo_set_line_width(cr, (gdouble)x1);
      long2rgb(li, &y1, &x2, &y2);
      cairo_set_source_rgb(cr, y1, x2, y2);
    }
    else if (!strncmp(ptr, "img", 3))
    {
      x1 = atof(ptr + 4);
      ptr = strchr(ptr + 4, ',');
      ptr++;
      y1 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      x2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      y2 = atof(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      iOpt = atol(ptr);
      ptr = strchr(ptr, ',');
      ptr++;
      ptre = strchr(ptr, '\r');

      memcpy(cBuf, ptr, ptre - ptr);
      cBuf[ptre - ptr] = '\0';

      if (iPathExist)
      {
        cairo_stroke(cr);
        iPathExist = 0;
      }

      pixbuf = gdk_pixbuf_new_from_file(cBuf, NULL);
      if (pixbuf)
      {
        pixbuf = gdk_pixbuf_scale_simple(pixbuf, x2 - x1 - 1, y2 - y1 - 1, GDK_INTERP_HYPER);
        gdk_cairo_set_source_pixbuf(cr, pixbuf, x1, y1);
        cairo_paint(cr);
        g_object_unref(pixbuf);
      }
    }

    while (*ptr != '\r')
    {
      ptr++;
    }
    while (*ptr == '\r' || *ptr == '\n')
    {
      ptr++;
    }  
  }
  if (iPathExist)
  {
    cairo_stroke(cr);
    iPathExist = 0;
  }
}

static void print_page(GtkPrintOperation *operation, GtkPrintContext *context, gint page_nr, PHB_ITEM ppages)
{
  char *cpage = hb_arrayGetCPtr(ppages, page_nr + 1);
  char *ptr;
  cairo_t *cr;
  GtkPageSetup *page_setup;

  cr = gtk_print_context_get_cairo_context(context);
  draw_page(cr, cpage);

  if (hb_arrayLen(ppages) >= page_nr + 2)
  {
    page_setup = gtk_print_context_get_page_setup(context);
    ptr = hb_arrayGetCPtr(ppages, page_nr + 2);
    if (!strncmp(ptr, "page", 4))
    {
      ptr = strchr(ptr + 5, ',');
      ptr += 4;
      // g_debug( "orient: %c", *ptr );
      gtk_page_setup_set_orientation(page_setup,
                                     (*ptr == 'p') ? GTK_PAGE_ORIENTATION_PORTRAIT : GTK_PAGE_ORIENTATION_LANDSCAPE);
      gtk_print_operation_set_default_page_setup(operation, page_setup);
    }
  }
}

#ifdef G_CONSOLE_MODE
static void print_destroy(GtkWidget *widget)
{
  gtk_widget_destroy(widget->parent->parent);
}

static int print_time(GtkWidget *widget)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)g_object_get_data((GObject *)widget, "print");
  char buf[48];
  gint x = 240 + (print->count % 100);

  if (print->count >= 9999)
  {
    x = 240;
  }
  else
  {
#if defined(__RUSSIAN__)
    sprintf(buf, "Печатаем %d сек.", print->count);
#else
    sprintf(buf, "Printing %d sec.", print->count);
#endif
    gtk_label_set_text(GTK_LABEL(print->label), buf);
  }
  gtk_window_resize(GTK_WINDOW(widget), x, 180);
  print->count++;

  if (print->count > 10000)
  {
    gtk_widget_destroy(widget);
    return 0;
  }
  else
  {
    return 1;
  }
}

static void print_run(GtkWidget *widget)
{
  if (!g_object_get_data((GObject *)widget, "flag"))
  {
    GtkPrintOperation *operation = (GtkPrintOperation *)g_object_get_data((GObject *)widget, "oper");
    PHWGUI_PRINT print = (PHWGUI_PRINT)g_object_get_data((GObject *)widget, "print");
    GtkPrintSettings *settings = gtk_print_settings_new();
    GtkPrintOperationResult res;
    GtkWidget *btn;
    char buf[48];

    g_object_set_data((GObject *)widget, "flag", (gpointer)1);

    if (print->cName && *(print->cName))
    {
      gtk_print_settings_set_printer(settings, (gchar *)print->cName);
      gtk_print_operation_set_print_settings(operation, settings);
    }

    print->count = 0;
    g_timeout_add(1000, G_CALLBACK(print_time), (gpointer)widget);

    res = gtk_print_operation_run(
        operation, (print->cName) ? GTK_PRINT_OPERATION_ACTION_PRINT : GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,
        GTK_WINDOW(widget), NULL);

    print->count = 9999;
#if defined(__RUSSIAN__)
    sprintf(buf, "Готово - %s", (res == GTK_PRINT_OPERATION_RESULT_ERROR) ? "Ошибка" : "Ок");
#else
    sprintf(buf, "Done - %s", (res == GTK_PRINT_OPERATION_RESULT_ERROR) ? "Error" : "Ok");
#endif
    gtk_label_set_text(GTK_LABEL(print->label), buf);

    /*
    #if defined (__RUSSIAN__)
          btn = gtk_button_new_with_label( "Закрыть" );
    #else
          btn = gtk_button_new_with_label( "Close" );
    #endif
          gtk_widget_set_size_request( btn, 80, 32);
          gtk_fixed_put( GTK_FIXED(print->label->parent), btn, 80, 130 );

          g_signal_connect( G_OBJECT(btn), "clicked",
             G_CALLBACK(print_destroy), NULL );
          gtk_widget_show( btn );
          gtk_widget_grab_focus( btn );
    */

    g_object_unref(settings);
    g_object_unref(operation);
  }
}

static void print_init(GtkPrintOperation *operation, PHWGUI_PRINT print)
{
  GtkWidget *prnwindow, *frame, *label;

  gtk_init(0, 0);

  prnwindow = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(prnwindow), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(prnwindow), 240, 180);
#if defined(__RUSSIAN__)
  gtk_window_set_title(GTK_WINDOW(prnwindow), "Печать");
#else
  gtk_window_set_title(GTK_WINDOW(prnwindow), "Print");
#endif

  frame = gtk_fixed_new();
  gtk_container_add(GTK_CONTAINER(prnwindow), frame);

  label = gtk_label_new("");
  gtk_widget_set_size_request(label, 120, 20);
  gtk_fixed_put(GTK_FIXED(frame), label, 60, 60);
  print->label = label;

  g_signal_connect_swapped(G_OBJECT(prnwindow), "destroy", G_CALLBACK(gtk_main_quit), NULL);

  g_object_set_data((GObject *)prnwindow, "oper", (gpointer)operation);
  g_object_set_data((GObject *)prnwindow, "print", (gpointer)print);

  g_signal_connect(prnwindow, "focus_in_event", G_CALLBACK(print_run), NULL);

  gtk_widget_show_all(prnwindow);
  gtk_main();
}

#endif

/*
 * hwg_gp_print( handle, aPages, nPages, printType, cPrinterName )
 * printType: 0 - printer, 1 - pdf, 2 - ps, 3 - png
 */

HB_FUNC(HWG_GP_PRINT)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_parnl(1);
  int iOper = hb_parni(4);

  if (print->cName)
  {
    hb_xfree(print->cName);
  }
  print->cName = NULL;

  if (HB_ISCHAR(5))
  {
    int iLen = hb_parclen(5);
    print->cName = (char *)hb_xgrab(iLen + 1);
    memcpy(print->cName, hb_parc(5), iLen);
    print->cName[iLen] = '\0';
  }

  if (!iOper)
  {
    GtkPrintOperation *operation = gtk_print_operation_new();

    gtk_print_operation_set_default_page_setup(operation, print->page_setup);
    gtk_print_operation_set_n_pages(operation, hb_parni(3));
    g_signal_connect(operation, "draw-page", G_CALLBACK(print_page), hb_param(2, HB_IT_ARRAY));

#ifdef G_CONSOLE_MODE
    print_init(operation, print);
#else
    gtk_print_operation_run(operation,
                            (print->cName) ? GTK_PRINT_OPERATION_ACTION_PRINT : GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,
                            NULL, NULL);
#endif
  }
  else if (iOper == 1)
  {
    GtkPrintOperation *operation = gtk_print_operation_new();

    gtk_print_operation_set_default_page_setup(operation, print->page_setup);
    gtk_print_operation_set_n_pages(operation, hb_parni(3));
    gtk_print_operation_set_export_filename(operation, print->cName);
    g_signal_connect(operation, "draw-page", G_CALLBACK(print_page), hb_param(2, HB_IT_ARRAY));

    gtk_print_operation_run(operation, GTK_PRINT_OPERATION_ACTION_EXPORT, NULL, NULL);
  }
  else if (iOper == 2)
  {
    int i, iPages = hb_parni(3);
    cairo_surface_t *surface =
        cairo_ps_surface_create(print->cName, gtk_page_setup_get_page_width(print->page_setup, GTK_UNIT_POINTS),
                                gtk_page_setup_get_page_height(print->page_setup, GTK_UNIT_POINTS));
    cairo_t *cr = cairo_create(surface);

    for (i = 1; i <= iPages; i++)
    {
      draw_page(cr, hb_arrayGetCPtr(hb_param(2, HB_IT_ARRAY), i));
      cairo_show_page(cr);
    }

    cairo_destroy(cr);
    cairo_surface_destroy(surface);
  }
  else if (iOper == 3)
  {
    int i, iPages = hb_parni(3), iLen = hb_parclen(5);
    char sfile[256];

    for (i = 1; i <= iPages; i++)
    {
      cairo_surface_t *surface = cairo_image_surface_create(
          CAIRO_FORMAT_ARGB32, gtk_page_setup_get_page_width(print->page_setup, GTK_UNIT_POINTS),
          gtk_page_setup_get_page_height(print->page_setup, GTK_UNIT_POINTS));
      cairo_t *cr = cairo_create(surface);
      draw_page(cr, hb_arrayGetCPtr(hb_param(2, HB_IT_ARRAY), i));
      memcpy(sfile, print->cName, iLen);
      sfile[iLen] = '\0';
      if (i > 1)
      {
        sprintf(sfile + iLen - 4, "_%d%s", i, ".png");
      }
      cairo_surface_write_to_png(surface, sfile);
      cairo_destroy(cr);
      cairo_surface_destroy(surface);
    }
  }
}

/*
 * HORZRES	Width, in pixels, of the screen.
 * VERTRES	Height, in raster lines, of the screen.
 * HORZSIZE	Width, in millimeters, of the physical screen.
 * VERTSIZE	Height, in millimeters, of the physical screen.
 *
 */
HB_FUNC(HWG_GP_GETDEVICEAREA)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_parnl(1);

  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  temp = hb_itemPutNL(NULL, (HB_LONG)gtk_page_setup_get_page_width(print->page_setup, GTK_UNIT_POINTS));
  hb_itemArrayPut(aMetr, 1, temp);

  hb_itemPutNL(temp, (HB_LONG)gtk_page_setup_get_page_height(print->page_setup, GTK_UNIT_POINTS));
  hb_itemArrayPut(aMetr, 2, temp);

  hb_itemPutNL(temp, (HB_LONG)gtk_page_setup_get_page_width(print->page_setup, GTK_UNIT_MM));
  hb_itemArrayPut(aMetr, 3, temp);

  hb_itemPutNL(temp, (HB_LONG)gtk_page_setup_get_page_height(print->page_setup, GTK_UNIT_MM));
  hb_itemArrayPut(aMetr, 4, temp);

  hb_itemRelease(temp);
  hb_itemReturn(aMetr);
  hb_itemRelease(aMetr);
}

HB_FUNC(HWG_GP_GETTEXTSIZE)
{
  PHWGUI_PRINT print = (PHWGUI_PRINT)hb_parnl(1);
  char *cText;
  cairo_surface_t *surface;
  cairo_t *cr;
  cairo_text_extents_t exten;

  cText = hwg_convert_to_utf8(hb_parc(2));

  surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1024, 400);
  cr = cairo_create(surface);

  cairo_select_font_face(cr, hb_parc(3), CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
  cairo_set_font_size(cr, hb_parni(4));

  cairo_text_extents(cr, cText, &exten);

  cairo_destroy(cr);
  cairo_surface_destroy(surface);

  hb_retnl((HB_LONG)exten.width);
  g_free(cText);
}

HB_FUNC(HWG_GP_RELEASE)
{
  g_object_unref(G_OBJECT(hb_parnl(1)));
}
