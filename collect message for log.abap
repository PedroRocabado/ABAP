DATA: gv_message TYPE string,
      gt_log     TYPE STANDARD TABLE OF symsg.
MESSAGE i001(<msg_class>) WITH sy-uname <variables> INTO gv_message. 
"luego de un mensaje que queramos que se guarde en el log, usamos el sig perform
PERFORM collect_message.



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
