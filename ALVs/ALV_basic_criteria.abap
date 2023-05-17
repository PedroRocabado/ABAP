FORM alv.
  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,         "tabla que con tendra todas las caracteristicas del alv.
        gs_fieldcat TYPE slis_fieldcat_alv,           "estructura correspondiente a la tabla de arriba.
        gs_layout   TYPE slis_layout_alv.             "plantilla con las caracteristicas del alv.
  DATA: gt_flights  TYPE TABLE OF spfli.              "tabla de ejemplo, puede ser cualquiera

  SELECT * INTO TABLE gt_flights FROM spfli.  "lleno la tabla de ejemplo [chequear el nombre de la tabla]

  gs_fieldcat-fieldname = 'CARRID'.           "nobmre del campo en la tabla interna a usar
  gs_fieldcat-seltext_l = 'Airline Code'.     "nombre que tendra la columna
  gs_fieldcat-key       = abap_true.          "le indico que esta columna es clave primaria, lo cual la pinta de azul y hace que se mantenga fija
  APPEND gs_fieldcat TO gt_fieldcat.

  gs_layout-zebra = abap_true.                "el alv se mostrara rallado
  gs_layout-edit  = abap_true.                "el alv es editable

  "Funcion basica para llamar a un ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid          "le paso el nombre de este programa
      i_callback_user_command = 'USER_COMMAND'    "le paso el nombre del form donde estara la logica de las acciones
      is_layout               = gs_layout         "le paso la plantilla
      it_fieldcat             = gt_fieldcat       "le paso el catalogo
    IMPORTING
    TABLES
      t_outtab = gt_flights.

  IF sy-subrc IS INITIAL.
  ENDIF.
ENDFORM.
FORM user_command USING r_ucom      LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
                         
ENDFORM.                     
