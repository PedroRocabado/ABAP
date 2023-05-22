DATA: it_fieldcat TYPE slis_t_fieldcat_alv.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid           " Nombre programa
      i_structure_name       = 'ZARBCIG_CONSUMO'  " Nombre estructura en el diccionario
    CHANGING
      ct_fieldcat            = it_fieldcat        "tabla donde se guardara el catalogo
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

IF sy-subrc = 0.
ENDIF.
