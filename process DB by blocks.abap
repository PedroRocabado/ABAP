  STATICS: s_cursor TYPE cursor VALUE 0.
  DATA: lv_subrc          TYPE sy-subrc,
        lt_but000_aux     TYPE STANDARD TABLE OF but000,
        lt_but021_fs_aux  TYPE STANDARD TABLE OF but021_fs.

  OPEN CURSOR WITH HOLD s_cursor FOR
  SELECT * FROM but000
    WHERE partner IN s_partn
      AND crdat   IN s_chdat
      AND chdat   IN s_chdat.

  lv_subrc = sy-subrc.

  WHILE lv_subrc IS INITIAL.
    REFRESH: lt_but000_aux, lt_but021_fs_aux. "lt_but020_aux

    FETCH NEXT CURSOR s_cursor
    INTO TABLE lt_but000_aux
    PACKAGE SIZE gc_pack_size.    "constante con la cantidad de registros por bloque
    lv_subrc = sy-subrc.

    IF lv_subrc <> 0.   "terminara cuando no haya mas que procesar
      EXIT.
    ENDIF.
    
 "  procesamiento que se requiera con la lt_but000_aux que tendra la cantidad de registros especificada en gc_pack_size
 
 
 ENDWHILE.
