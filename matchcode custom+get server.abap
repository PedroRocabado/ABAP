"llamada en el main program
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file. "Archivo de HR
  PERFORM f_matchcode_ser.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filelg.
  PERFORM f4_folfer.
 
 
 "en el f01
 FORM f_matchcode_ser.
   DATA: lv_server       TYPE  msname2,
          ls_rfcsi_export TYPE rfcsi,
          lv_i_path       TYPE dxlpath,
          lv_o_path       TYPE dxlpath.

  *----->>> Default Path
    lv_i_path = gc_server_direc.
  *----->>> Get logical server from System
    CALL FUNCTION 'RFC_SYSTEM_INFO'
      IMPORTING
        rfcsi_export = ls_rfcsi_export.

  *----->>> SAP Server name
    lv_server = ls_rfcsi_export-rfcdest.

  *----->>> If path is not defined = '?'
    IF ( lv_server IS INITIAL ).
      lv_server = '?'.
    ENDIF.


    CALL FUNCTION 'F4_DXFILENAME_TOPRECURSION'
      EXPORTING
        i_location_flag = 'A'
        i_server        = lv_server
        i_path          = lv_i_path
        fileoperation   = 'R'
      IMPORTING
  *     O_LOCATION_FLAG =
  *     O_SERVER        =
        o_path          = lv_o_path
  *     ABEND_FLAG      =
      EXCEPTIONS
        rfc_error       = 1
        error_with_gui  = 2
        OTHERS          = 3.
    IF sy-subrc EQ 0.
      IF lv_o_path IS NOT INITIAL.
        p_file = lv_o_path.
      ENDIF.
    ENDIF.
ENDFORM.    
