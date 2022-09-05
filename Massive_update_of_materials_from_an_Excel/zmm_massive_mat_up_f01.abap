*&---------------------------------------------------------------------*
*&      Form  set_filepath
*&---------------------------------------------------------------------*
* Este FORM sirve para el explorador en el que se selecciona el archivo
*----------------------------------------------------------------------*
FORM set_filepath  CHANGING po_ruta TYPE rlgrap-filename.

  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.XLS'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc        TYPE i.

  CLEAR po_ruta.

  wl_sel_text = text-s01.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    po_ruta = lx_filetable-filename.
  ENDIF.


ENDFORM.                    " SET_FILEPATH

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL_IT
*&---------------------------------------------------------------------*
FORM upload_excel_it USING    pi_ruta TYPE rlgrap-filename
                     CHANGING to_file TYPE type_t_datos.


  TYPES: BEGIN OF type_excel,
       matnr(18) TYPE c, "Material
       extwg(1) TYPE c,
  END OF type_excel.

  DATA: tl_exc TYPE STANDARD TABLE OF type_excel.
  DATA: it_raw TYPE truxs_t_text_data.


  FIELD-SYMBOLS: <fs> TYPE type_excel,
                 <fo> TYPE LINE OF type_t_datos.

  REFRESH: to_file, tl_exc.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
*     i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = pi_ruta
    TABLES
      i_tab_converted_data = tl_exc[]    "ACTUAL DATA
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF ( sy-subrc <> 0 ).
    MESSAGE text-e02  TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.

    DELETE  tl_exc INDEX 1.                    "eliminar la cabecera

    LOOP AT tl_exc ASSIGNING <fs>.

      APPEND INITIAL LINE TO to_file ASSIGNING <fo>. "ME QUITA LA PRIMER FILA DE LA CABECERA DEL EXCEL

      PERFORM conversion_sap_format USING <fs>-matnr CHANGING <fo>-matnr. "AGREGO LOS CAMPOS
      PERFORM conversion_sap_format USING <fs>-extwg CHANGING <fo>-extwg. "AGREGO LOS CAMPOS

    ENDLOOP.


    DATA: crit TYPE extwg.
    CLEAR wa_criticidad.
    LOOP AT to_file INTO wa_criticidad.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_criticidad-extwg
        IMPORTING
          output = crit.


      wa_bapimathead-material = wa_criticidad-matnr.
      wa_bapimathead-basic_view = 'X'.

      wa_check_update-extmatlgrp = 'X'.
      wa_bapi_mara-extmatlgrp = crit.

      CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
        EXPORTING
          headdata    = wa_bapimathead
          clientdata  = wa_bapi_mara
          clientdatax = wa_check_update
        IMPORTING
          return      = status_bapi.

      IF status_bapi-type = 'S'.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ENDIF.
      wa_criticidad-extwg = crit.
      MODIFY to_file FROM wa_criticidad TRANSPORTING extwg.
    ENDLOOP.


  ENDIF.

ENDFORM.                    " UPLOAD_EXCEL_IT
*&---------------------------------------------------------------------*
*&      Form  CARGAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargar_alv.

  PERFORM init_fieldcat.
  PERFORM init_layout.
  PERFORM mostrar_alv_01.

ENDFORM.                    " CARGAR_ALV

*&---------------------------------------------------------------------*
*&      Form  init_fieldcat
*&---------------------------------------------------------------------*
*       Informacion de cada columna del ALV
*----------------------------------------------------------------------*
FORM init_fieldcat.

  REFRESH: gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_DATA'.
  gt_fieldcat-fieldname     = 'MATNR'.
  gt_fieldcat-ddictxt       = 'L'.
  gt_fieldcat-seltext_l     = 'Material'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_DATA'.
  gt_fieldcat-fieldname     = 'EXTWG'.
  gt_fieldcat-ddictxt       = 'L'.
  gt_fieldcat-seltext_l     = 'Criticidad'.
  APPEND gt_fieldcat. CLEAR gt_fieldcat.


ENDFORM.                    " init_fieldcat



*&---------------------------------------------------------------------*
*&      Form  init_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init_layout.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
ENDFORM.                    " init_layout


*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mostrar_alv_01.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
        i_callback_program             = g_repid
*        i_callback_user_command        = 'USER_COMMAND_01'
*        i_callback_pf_status_set       = 'SET_PF_STATUS_01'
*        i_structure_name               = 'T_OUTTAB'
        is_layout                      = gs_layout
        it_fieldcat                    = gt_fieldcat[]
*        it_sort                        = gt_sort[]
*        it_excluding                   = gt_exclude[]
*        I_DEFAULT                      = 'X'
        i_save                         = ' '           "Grabar Variante
         is_variant                     = ls_vari
         it_events                      = gt_events[]
*        IT_EVENT_EXIT                  =
*        IS_PRINT                       =
*        IS_REPREP_ID                   =
*        I_SCREEN_START_COLUMN          = 0
*        I_SCREEN_START_LINE            = 0
*        I_SCREEN_END_COLUMN            = 0
*        I_SCREEN_END_LINE              = 0
*     IMPORTING
*        E_EXIT_CAUSED_BY_CALLER        =
*        ES_EXIT_CAUSED_BY_USER         =
     TABLES
        t_outtab                       = ti_data
     EXCEPTIONS
        program_error                  = 1
        OTHERS                         = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " MOSTRAR_ALV_01


*---------------------------------------------------------------------*
*       FORM USER_COMMAND_01  Process Call Back Events (Begin)         *
*---------------------------------------------------------------------*
FORM user_command_01 USING ucomm    LIKE sy-ucomm
                        selfield TYPE slis_selfield.

ENDFORM.                    "user_command_01
*&---------------------------------------------------------------------*
*       FORM SET_PF_STATUS_01
*&---------------------------------------------------------------------*
FORM set_pf_status_01 USING lt_cua_exclude TYPE slis_t_extab.

  DATA: lf_gui_status  TYPE gui_status.

  SET PF-STATUS 'ZZSTANDARD'.

ENDFORM.                    "set_pf_status_01
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
FORM conversion_sap_format  USING    pi_output
                            CHANGING po_output.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pi_output
    IMPORTING
      output = po_output.

ENDFORM.                    " CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_UNIT
*&---------------------------------------------------------------------*
FORM conversion_sap_unit  USING    pi_output
                          CHANGING po_output.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = pi_output
      language       = sy-langu
    IMPORTING
      output         = po_output
    EXCEPTIONS
      unit_not_found = 1.

  IF sy-subrc <> 0.
    CLEAR po_output.
  ENDIF.

ENDFORM.                    " CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_NUM
*&---------------------------------------------------------------------*
FORM conversion_sap_num  USING    pi_output
                          CHANGING po_output.

  CALL FUNCTION 'MOVE_CHAR_TO_NUM'
    EXPORTING
      chr             = pi_output
    IMPORTING
      num             = po_output
    EXCEPTIONS
      convt_no_number = 1
      convt_overflow  = 2
      OTHERS          = 3.

  IF sy-subrc <> 0.
    CLEAR po_output.
  ENDIF.

ENDFORM.                    " CONVERSION_SAP_FORMAT
