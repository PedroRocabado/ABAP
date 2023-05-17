FORM alv.
  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,         "tabla que con tendra todas las caracteristicas del alv.
        gs_fieldcat TYPE slis_fieldcat_alv,           "estructura correspondiente a la tabla de arriba.
        gs_layout   TYPE slis_layout_alv,             "plantilla con las caracteristicas del alv.
        gt_events   TYPE slis_t_event,                "tabla que contiene los eventos que quiero que tenga el alv.
        gs_events   TYPE slis_alv_event.              " estructura correspiente a la tabla de arriba.
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
      i_callback_program        = sy-repid          "le paso el nombre de este programa
      i_callback_pf_status_set  = 'SET_PF_STATUS'   "le paso los botones que quiero que muestre
      i_callback_user_command   = 'USER_COMMAND'    "le paso el nombre del form donde estara la logica de las acciones
      is_layout                 = gs_layout         "le paso la plantilla
      it_fieldcat               = gt_fieldcat       "le paso el catalogo
      it_events                 = gt_events         "le paso la tabla con los eventos que quiero que considere
    IMPORTING
    TABLES
      t_outtab = gt_flights.

  IF sy-subrc IS INITIAL.
  ENDIF.
ENDFORM.
"configurar las acciones del alv
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
 CASE r_ucomm.
  WHEN '&X'.
    "aqui elijo que va a hacer cada boton cuando haga click &X
 ENDCASE.
ENDFORM.                     
"configurar los botones
"NOTA: es buena practica copiar el status standard KKBL a nuestro programa y modificarlo
FORM set_pf_status USING rt_extab TYPE slis_t_exbar.
  SET PF-STATUS 'STATUS'. "en el gui status configuro los botones
ENDFORM.
"para agregar un titulo al ALV
FORM add_events.  " se llama en el main program
  gs_events-name = 'TOP_OF_PAGE'.    "el nombre del evento, por el TOP_OF_PAGE, que es el titulo
  gs_events-form = 'TOP_OFPAGE'.     "el perform al que va a llamar para sacar el titulo del alv
  APPEND gs_events TO  gt_events.
ENDFORM.
"defino el form donde esta lo que quiero escribir
FORM top_of_page.
  WRITE: / 'Hora de ejecucion: ', sy-uzeit EVIRONMENT TIME FORMAT.    "mostrara en el titulo del alv la hora del sistema
ENDFORM.
