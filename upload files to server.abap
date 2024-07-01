"codigo suelto para cargar archivos al servidor 

***************************
* TABLA INTERNA
***************************

DATA: BEGIN OF ti_entrada OCCURS 0,
            campo(8000),
      END OF ti_entrada.

***************************
* VARIABLES GLOBALES
***************************
DATA: w_location_s TYPE dxlocation,
      w_location_d TYPE dxlocation,
      ofile TYPE string,
      dest_file TYPE string,
      p_del.

*************************
* PANTALLA SELECCION
*************************
SELECTION-SCREEN BEGIN OF BLOCK sel00 WITH FRAME TITLE text-000.

PARAMETERS: p_up     RADIOBUTTON GROUP uno.
SELECTION-SCREEN COMMENT /1(75) text-012.
PARAMETERS: snfile(1024)  LOWER CASE DEFAULT 'archivo.txt',
            ssfile(1024)  LOWER CASE DEFAULT '/usr/sap/archivos_bs/bp/Extracto',
*            slfile(1024)  default 'C:\'.
            slfile LIKE rlgrap-filename OBLIGATORY.
SELECTION-SCREEN COMMENT /9(79) text-012.
SELECTION-SCREEN ULINE /1(77).
SELECTION-SCREEN COMMENT /1(79) text-012.
PARAMETERS: p_down   RADIOBUTTON GROUP uno.
SELECTION-SCREEN COMMENT /9(79) text-012.
PARAMETERS:
            bsfile(1024) LOWER CASE DEFAULT '/usr/sap/archivos_bs/bp/Extracto',
            bnfile(1024) LOWER CASE DEFAULT 'archivo.txt',
            blfile(1024) LOWER CASE DEFAULT 'C:\'.
SELECTION-SCREEN COMMENT /1(79) text-012.
SELECTION-SCREEN END OF BLOCK sel00.

* Evento F4 para indicar camino y nombre de archivo para leer/escribir
AT SELECTION-SCREEN ON VALUE-REQUEST FOR slfile.
  PERFORM z_buscar_archivo.

***************************
START-OF-SELECTION.
***************************

  IF p_up = 'X'.
    PERFORM subir_a_server.
  ENDIF.

  IF p_down = 'X'.
    PERFORM bajar_a_pc.
  ENDIF.

* Opcion Oculta
  IF p_del = 'X'.
    PERFORM borrar_del_server.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  SUBIR_A_SERVER
*&---------------------------------------------------------------------*
FORM subir_a_server .

  CLEAR ofile.
*  concatenate slfile snfile into  ofile.
  MOVE slfile TO  ofile.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = ofile
      filetype                      = 'ASC'
     has_field_separator           = ' '
     header_length                 = 0
     read_by_line                  = 'X'
     dat_mode                      = ' '
     codepage                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
     replacement                   = '#'
     check_bom                     = ' '
     no_auth_check                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
    TABLES
      data_tab                      = ti_entrada
   EXCEPTIONS
     file_open_error               = 1
     file_read_error               = 2
     no_batch                      = 3
     gui_refuse_filetransfer       = 4
     invalid_type                  = 5
     no_authority                  = 6
     unknown_error                 = 7
     bad_data_format               = 8
     header_not_allowed            = 9
     separator_not_allowed         = 10
     header_too_long               = 11
     unknown_dp_error              = 12
     access_denied                 = 13
     dp_out_of_memory              = 14
     disk_full                     = 15
     dp_timeout                    = 16
     OTHERS                        = 17
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  TRANSLATE dfile TO LOWER CASE.
*------- BEGIN OF MOD CAFERRO 11.04.2008 Orden:TDHK912913 -------------*
  DATA: result_tab TYPE match_result_tab.
  DATA: result_str TYPE match_result.
  DATA: lv_long    TYPE i.
* TRANSLATE ssfile TO LOWER CASE.
*  FIND ALL OCCURRENCES OF REGEX '/'
*      IN ssfile
*      RESULTS result_tab.
*  READ TABLE result_tab INDEX 1 TRANSPORTING NO FIELDS.
*  READ TABLE result_tab INDEX sy-tfill INTO result_str.
**  lv_long = strlen( ssfile ).
*  lv_long = result_str-offset.
*  CONCATENATE ssfile(LV_LONG) '/' snfile INTO ssfile.
*
  OPEN DATASET ssfile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
*  OPEN DATASET dfile FOR UPDATE IN TEXT MODE ENCODING DEFAULT.
*------- END OF MOD CAFERRO 11.04.2008 Orden:TDHK912913 ---------------*
  LOOP AT ti_entrada.
    TRANSFER ti_entrada TO ssfile.
  ENDLOOP.
  CLOSE DATASET ssfile.

ENDFORM.                    " SUBIR_A_SERVER
*&---------------------------------------------------------------------*
*&      Form  BAJAR_A_PC
*&---------------------------------------------------------------------*
FORM bajar_a_pc .

  CLEAR dest_file.




*  CONCATENATE bsfile '/' bnfile INTO bsfile.
*  TRANSLATE bsfile TO LOWER CASE.
  CONCATENATE blfile bnfile INTO dest_file.
*  TRANSLATE dest_file TO LOWER CASE.


  OPEN DATASET bsfile FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DO.

      READ DATASET bsfile INTO ti_entrada.
      IF sy-subrc <> 0.
        EXIT.
      ELSE.
        APPEND ti_entrada.
        CLEAR ti_entrada.
      ENDIF.
    ENDDO.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*     BIN_FILESIZE                    =
        filename                        = dest_file
        filetype                        = 'ASC'
*     APPEND                          = ' '
*     WRITE_FIELD_SEPARATOR           = ' '
*     HEADER                          = '00'
*     TRUNC_TRAILING_BLANKS           = ' '
*     WRITE_LF                        = 'X'
*     COL_SELECT                      = ' '
*     COL_SELECT_MASK                 = ' '
*     DAT_MODE                        = ' '
*     CONFIRM_OVERWRITE               = ' '
*     NO_AUTH_CHECK                   = ' '
*     CODEPAGE                        = ' '
*     IGNORE_CERR                     = ABAP_TRUE
*     REPLACEMENT                     = '#'
*     WRITE_BOM                       = ' '
*     TRUNC_TRAILING_BLANKS_EOL       = 'X'
*     WK1_N_FORMAT                    = ' '
*     WK1_N_SIZE                      = ' '
*     WK1_T_FORMAT                    = ' '
*     WK1_T_SIZE                      = ' '
*   IMPORTING
*     FILELENGTH                      =
      TABLES
        data_tab                        = ti_entrada
*     FIELDNAMES                      =
     EXCEPTIONS
       file_write_error                = 1
       no_batch                        = 2
       gui_refuse_filetransfer         = 3
       invalid_type                    = 4
       no_authority                    = 5
       unknown_error                   = 6
       header_not_allowed              = 7
       separator_not_allowed           = 8
       filesize_not_allowed            = 9
       header_too_long                 = 10
       dp_error_create                 = 11
       dp_error_send                   = 12
       dp_error_write                  = 13
       unknown_dp_error                = 14
       access_denied                   = 15
       dp_out_of_memory                = 16
       disk_full                       = 17
       dp_timeout                      = 18
       file_not_found                  = 19
       dataprovider_exception          = 20
       control_flush_error             = 21
       OTHERS                          = 22
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
*    MESSAGE 'No se puede abrir el archivo' TYPE 'I'.
  ENDIF.

ENDFORM.                    " BAJAR_A_PC
*&---------------------------------------------------------------------*
*&      Form  BORRAR_DEL_SERVER
*&---------------------------------------------------------------------*
FORM borrar_del_server .

  CONCATENATE bsfile '/' bnfile INTO bsfile.
  TRANSLATE bsfile TO LOWER CASE.


  DELETE DATASET bsfile.

ENDFORM.                    " BORRAR_DEL_SERVER
*&---------------------------------------------------------------------*
*&      Form  Z_BUSCAR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM z_buscar_archivo .
  DATA: lv_usr_action TYPE i, "Codigo de accion del usuario
    lv_path     TYPE string, "Directorio del archivo
    lv_fullpath TYPE string, "Ruta del arhivo completa
    lv_filename TYPE string, "Nombre del archivo
    lt_file_table TYPE filetable. "Recibe la lista de archivos que se selecciona.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title         = 'Abrir Archivo'
    CHANGING
      file_table           = lt_file_table
      rc                   = lv_usr_action
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc IS INITIAL.
    READ TABLE lt_file_table INDEX 1 INTO slfile.
  ENDIF.

ENDFORM.                    " Z_BUSCAR_ARCHIVO
