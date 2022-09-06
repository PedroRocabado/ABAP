*---------------------------------------------------------------------------*
*Lógica del programa                                                        *
*1) El usuario introducirá las direcciones de correo electrónico a quienes  *
*se enviará el correo en un Select-Option                                   *
*2) Recogeremos los emails y los añadiremos a la tabla de receptores        *
*3) Crearemos el contenido del correo:                                      *
*    Cuerpo del correo                                                      *
*    Sujeto del correo                                                      *
*4) Indicaremos el remitente del email                                      *
*5) Indicaremos los receptores del email (Con la tabla anterior)            *
*6) Enviaremos el email y comprobaremos que se han enviado correctamente    *
*---------------------------------------------------------------------------*
TABLES: adr6.

TYPES: t_soli_t      TYPE TABLE OF soli.

DATA: li_addr        TYPE bcsy_smtpa,
      lcl_send_email TYPE REF TO cl_bcs,
      li_message     TYPE t_soli_t,
      lw_message     LIKE LINE OF li_message,
      lv_subject     TYPE so_obj_des,
      lcl_document   TYPE REF TO cl_document_bcs,
      lcl_recipient  TYPE REF TO if_recipient_bcs,
      lv_sent_to_all TYPE os_boolean,
      lcl_sender     TYPE REF TO cl_cam_address_bcs,
      lv_sender      TYPE adr6-smtp_addr.

SELECT-OPTIONS: s_emails FOR adr6-smtp_addr NO INTERVALS.

FIELD-SYMBOLS: <fs_mail> LIKE LINE OF s_emails,
               <fs_addr> LIKE LINE OF li_addr.

* Recoge los emails y los añade a la tabla de destinatario
LOOP AT s_emails[] ASSIGNING <fs_mail>.
  APPEND <fs_mail>-low TO li_addr.
ENDLOOP.

* Inicialización de la clase
lcl_send_email = cl_bcs=>create_persistent( ).

* Cuerpo del email
lw_message-line ='<b>Cuerpo del email</b>'.
APPEND lw_message TO li_message.

* Crear documento
lv_subject = 'Sujeto del email'.

lcl_document =  cl_document_bcs=>create_document( i_type    =  'HTM'
                                                  i_subject =  lv_subject
                                                  i_text    =  li_message ).

* Enviar documento al email
lcl_send_email->set_document( lcl_document ).

* Añadir remitente
lv_sender = 'sender@email.com'.
lcl_sender = cl_cam_address_bcs=>create_internet_address( lv_sender  ).
lcl_send_email->set_sender( i_sender = lcl_sender ).

* Añadir destinatarios al email
LOOP AT li_addr ASSIGNING <fs_addr>.
  lcl_recipient = cl_cam_address_bcs=>create_internet_address( <fs_addr> ).
  lcl_send_email->add_recipient( i_recipient = lcl_recipient ).
ENDLOOP.

* Enviar email
lv_sent_to_all = lcl_send_email->send( i_with_error_screen = 'X' ).
COMMIT WORK.

IF lv_sent_to_all EQ 'X'.
*   Enviado Correctamente
ELSE.
*   Error al enviar
ENDIF.
*--------------------------------------------------------------------*
*Comprobación en SOST
*--------------------------------------------------------------------*
*Con la transacción SOST podremos ver los emails enviados SAP,
*al acceder en nuestro caso vemos lo siguiente:
*
*Filtrado por fecha y hora de envío de email
*Listado con los emails que cumplan con las condiciones de filtrado
*con los siguientes parámetros:
*  Status:
*    Las posibles opciones son:
*      Verde (Enviado correcto)
*      Amarillo (En espera)
*      Rojo (Error)
*  Forma de envío:
*    Método de envío de email
*  Titulo documento:
*    Texto introducido como sujeto del email (lv_subject)
*  Emisor:
*    Correo del emisor del email (lv_sender)
*  Destinatario:
*    Destinatario del email, se creará una entrada
*    por cada destinatario (s_emails[])
*  Fecha Envío:
*    Fecha del envío
*  Hora Envío:
*    Hora del envío
*  Mensaje:
*    Código del mensaje para el campo Status
*--------------------------------------------------------------------*
