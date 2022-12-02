TYPES: BEGIN OF typ_itab,
         aaa(20) TYPE c,
         bbb     TYPE i,
         ccc     TYPE p LENGTH 12 DECIMALS 3,
         pernr   TYPE pa9005-pernr,
       END OF typ_itab.

DATA: i_itab           TYPE TABLE OF typ_itab,
      l_tabledescr_ref TYPE REF TO   cl_abap_tabledescr,
      l_descr_ref      TYPE REF TO   cl_abap_structdescr,
      wa_table         TYPE          abap_compdescr.

l_tabledescr_ref ?= cl_abap_typedescr=>describe_by_data( i_itab ).
l_descr_ref      ?= l_tabledescr_ref->get_table_line_type( ).

LOOP AT l_descr_ref->components INTO wa_table .

  WRITE: / wa_table-name.       "aqui se escribe el nombre de las columnas

ENDLOOP.
