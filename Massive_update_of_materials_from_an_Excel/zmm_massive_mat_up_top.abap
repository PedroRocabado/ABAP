TYPE-POOLS: truxs.
*&---------------------------------------------------------------------*
*&  Estructuras internas
*&---------------------------------------------------------------------*
TYPES: BEGIN OF type_datos,
        matnr TYPE matnr, "Material
        extwg TYPE extwg, "Criticidad
   END OF type_datos.

TYPES: type_t_datos TYPE STANDARD TABLE OF type_datos.
*&---------------------------------------------------------------------*
*&  Tablas internas
*&---------------------------------------------------------------------*
DATA: ti_data TYPE type_t_datos.

DATA: wa_bapimathead  LIKE bapimathead,
      wa_bapi_mara    LIKE bapi_mara,
      wa_check_update LIKE bapi_marax,
      status_bapi     LIKE bapiret2.

*&---------------------------------------------------------------------*
*&  ESTRUCTURA PARA IR PASANDO A LA FUNCION
*&---------------------------------------------------------------------*
DATA: wa_criticidad TYPE type_datos.

*&---------------------------------------------------------------------*
*& DEFINICION DE TABLAS Y ESTRUCTURAS NECESARIAS ALV
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.
*
** Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat          TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
      gt_sort              TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.

*&---------------------------------------------------------------------*
*& Parámetros de Selección
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK q1 WITH FRAME TITLE text-001. "agregar texto cabecera
PARAMETERS: archivo  TYPE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK q1.
