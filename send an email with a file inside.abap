DATA:
      strtab  TYPE TABLE OF string,
      line    TYPE string,
      datatab TYPE TABLE OF zfica_013e, "tabla de donde sacaremos los datos a enviar por mail
      wa      LIKE LINE OF datatab,
      timest  TYPE string,
      cap     TYPE string,
      aux     TYPE string.
CONSTANTS:
c_tab(1) TYPE c VALUE
             cl_abap_char_utilities=>horizontal_tab.
FIELD-SYMBOLS
               <fs> TYPE ANY.

               
SELECT * INTO TABLE datatab FROM zfica_013e.
LOOP AT datatab INTO wa.
  DO. "recorremos columna a columna de la tabla en cuestion
    CLEAR aux.
    ASSIGN COMPONENT sy-index OF STRUCTURE wa TO <fs>.
    IF sy-subrc IS NOT INITIAL.
      EXIT.
    ENDIF.
    MOVE <fs> TO aux.
    CONCATENATE line aux INTO line SEPARATED BY space. "y lo vamos acumulando en aux
  ENDDO.
  CONCATENATE line cl_abap_char_utilities=>cr_lf INTO line. "al final le agregamos un salto de carro
  APPEND line TO strtab. "y lo guardamos en nuestra tabla tipo string
  CLEAR line.
ENDLOOP.

DATA: lt_lines TYPE TABLE OF string,
      lv_line  TYPE string,
      lv_lin   TYPE xstring,
      cr_lf    TYPE xstring.

" Convertir el contenido a un binario
DATA: lt_content_bin TYPE solix_tab,
      lt_header      TYPE soli_tab,
      lv_header      TYPE char255,
      lv_bin_length  TYPE i,
      lv_length      TYPE char12,
      linex          TYPE xstring,
      lv_text        TYPE xstring,
      l_sender       TYPE REF TO    if_sender_bcs.

DATA: lv_param  TYPE zparametro,
      ls_param  TYPE zcsc_002,
      lt_param  TYPE STANDARD TABLE OF zcsc_002,
      lv_mail   TYPE ad_smtpadr,
      l_recipient       TYPE REF TO    if_recipient_bcs.

CONSTANTS:
      lc_req TYPE zreq VALUE 'CONTR_ER'.

LOOP AT strtab INTO line.   "recorremos la tabla que creamos 
  CALL FUNCTION 'SCMS_STRING_TO_XSTRING' "y la transformamos a xstring
    EXPORTING
      text = line
    IMPORTING
      buffer = linex.
  CONCATENATE lv_text linex INTO lv_text IN BYTE MODE.
ENDLOOP.

MOVE 'Contenido del cuerpo del correo' TO lv_header. "le agregamos la cabecera del mail
APPEND lv_header TO lt_header.

" Convierte el xstring a binario
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer        = lv_text
  IMPORTING
    output_length = lv_bin_length
  TABLES
    binary_tab    = lt_content_bin.
MOVE lv_bin_length TO lv_length.

" Crear el documento
DATA: lo_document TYPE REF TO cl_document_bcs. "objeto que tiene los metodos para mandar el mail

lo_document = cl_document_bcs=>create_document(
                i_type    = 'RAW'   "aqui podemos elegir tambien XLS o HTM
                i_text    = lt_header
                i_subject = 'Asunto del correo'
              ).

" Agregar el adjunto
lo_document->add_attachment(
  i_attachment_type    = 'TXT' " Tipo de archivo adjunto (TXT)
  i_attachment_subject = 'Mi archivo adjunto' " Asunto del adjunto
  i_attachment_size    = lv_length " Tamaño del adjunto
  i_att_content_hex    = lt_content_bin " Contenido de la tabla pasado a binario
).
"ACLARACION IMPORTANTE: uso el paramtro i_att_content_hex porque al trabajar en hexadecimal, admite
"mas caracteres que 255. El error que me estaban reportando cuando hice esto, era justamente
"porque la tabla que estaba intentando mandar por mail tenia mas de 255 caracteres por linea.
"si se diera elc caso de que la tabla a enviar tenga menos de 255, se puede usar el parametro
" i_att_context_text

" Enviar el correo
DATA: l_send_request TYPE REF TO cl_bcs.  "objeto que envia el mail

l_send_request = cl_bcs=>create_persistent( ).

CALL METHOD l_send_request->set_document( lo_document ).

CALL METHOD l_send_request->set_sender
  EXPORTING
    i_sender = l_sender.
      CALL FUNCTION 'ZCS_REQ_PARAMETER_GET'
        EXPORTING
          i_req   = lc_req
        TABLES
          t_param = lt_param.

"// Agrego los receptores del MAIL
LOOP AT lt_param INTO ls_param. "para el caso que me toco debia enviar el mail a ciertas casillas parametrizadas

  CLEAR lv_mail.
  lv_mail = ls_param-zvalor.
  TRANSLATE lv_mail TO LOWER CASE.

  l_recipient = cl_cam_address_bcs=>create_internet_address( lv_mail ).

  CALL METHOD l_send_request->add_recipient
    EXPORTING
      i_recipient  = l_recipient
      i_express    = 'U'
      i_copy       = ' '
      i_blind_copy = ' '
      i_no_forward = ' '.

ENDLOOP.

l_send_request->set_send_immediately( 'X' ).

" Enviar el correo
l_send_request->send( i_with_error_screen = 'X' ).

COMMIT WORK.
