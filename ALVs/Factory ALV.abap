"Lo interesante de este ALV es que puedo definir un TYPES y va a funicionar igual
"Es mas simple que los otros

DATA: lt_pa0001 TYPE STANDARD TABLE OF pa0001,  "tabla a mostrar
      lo_alv    TYPE REF TO cl_salv_table.    "objeto

SELECT *
  INTO TABLE lt_pa0001
  FROM pa0001.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = lo_alv    " Basis Class Simple ALV Tables
  CHANGING
    t_table        = lt_pa0001
).
"opcional, muestra el ALV como popup
lo_alv->set_screen_popup(
  EXPORTING
    start_column = 10
    end_column   = 110
    start_line   = 2
    end_line     = 15
).
"mostrar alv
lo_alv->display( ).
