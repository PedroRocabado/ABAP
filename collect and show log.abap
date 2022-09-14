DATA: gv_message TYPE string,
      gt_log     TYPE STANDARD TABLE OF symsg.
MESSAGE i001(<msg_class>) WITH sy-uname <variables> INTO gv_message. 
"luego de un mensaje que queramos que se guarde en el log, usamos el sig perform
PERFORM collect_message.

PERFORM mostrar_log.

*----------------------------------------------------------*

FORM collect_message.

  DATA: ls_return TYPE bus_bapi-return,
        ls_log    LIKE symsg.

  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type   = sy-msgty
      cl     = sy-msgid
      number = sy-msgno
      par1   = sy-msgv1
      par2   = sy-msgv2
      par3   = sy-msgv3
      par4   = sy-msgv4
    IMPORTING
      return = ls_return.
  IF NOT ls_return IS INITIAL.
*   Se guarda el mensaje en la tabla del log
    ls_log-msgty = ls_return-type.
    ls_log-msgid = ls_return-id.
    ls_log-msgno = ls_return-number.
    ls_log-msgv1 = ls_return-message_v1.
    ls_log-msgv2 = ls_return-message_v2.
    ls_log-msgv3 = ls_return-message_v3.
    ls_log-msgv4 = ls_return-message_v4.
    APPEND ls_log TO gt_log.
  ENDIF.

ENDFORM. 
*-------------------------------------------------------------------*
FORM mostrar_log.
  DATA: lv_handle TYPE balloghndl,
        ls_log    TYPE bal_s_log,
        ls_msg    TYPE symsg,
        ls_logmsg TYPE bal_s_msg,
        lt_log_handles TYPE bal_t_logh,
        ls_display_profile TYPE bal_s_prof.

* - Completa los datos para la creación del log en la estructura LS_LOG
  ls_log-extnumber = sy-title.
  ls_log-object    = gc_log_obj.
  ls_log-subobject = gc_log_subobj.
  ls_log-alprog    = sy-cprog.

  "Función para Creación de Log
  CALL FUNCTION 'BAL_LOG_CREATE'                           "#EC FB_NORC
    EXPORTING
      i_s_log                 = ls_log
    IMPORTING
      e_log_handle            = lv_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  IF sy-subrc IS NOT INITIAL.
*  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
  ENDIF.

* Lee cada uno de los registros de la tabla con los mensajes recopilados (gt_log),
* para incorporarlos como entradas en el log (ls_logmsg)
  LOOP AT gt_log INTO ls_msg.
    ls_logmsg-msgty = ls_msg-msgty.
    ls_logmsg-msgid = ls_msg-msgid.
    ls_logmsg-msgno = ls_msg-msgno.
    ls_logmsg-msgv1 = ls_msg-msgv1.
    ls_logmsg-msgv2 = ls_msg-msgv2.
    ls_logmsg-msgv3 = ls_msg-msgv3.
    ls_logmsg-msgv4 = ls_msg-msgv4.

    "Función que agrega registros al Log
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lv_handle
        i_s_msg          = ls_logmsg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc IS NOT INITIAL.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
    ENDIF.
  ENDLOOP.

  "Función que graba el log en la base de datos.
  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = 'X'
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
  ENDIF.


  CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile.

  INSERT lv_handle INTO TABLE lt_log_handles.

  "Función para Visualización del Log
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile  = ls_display_profile
      i_t_log_handle       = lt_log_handles
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      OTHERS               = 5.
  IF sy-subrc IS NOT INITIAL.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
  ENDIF.

ENDFORM.
