*--------------------------------------------------------------------*
* Ayuda de búsqueda personalizada
*--------------------------------------------------------------------*
*Para crear en ABAP: Ayuda de búsqueda personalizada, podemos hacerla
*mediante la transacción SE11 (de este modo formará parte
*del diccionario de datos) o podemos crear una ayuda de búsqueda
*personalizada en tiempo de ejecución.
*En este ejemplo crearemos una ayuda de búsqueda personalizada
*con la función F4IF_INT_TABLE_VALUE_REQUEST:
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
*Paso 1º: Asociar un MODULE al campo de la dympro
*  Esto lo haremos en el PROCESS ON VALUE_REQUEST,
*  nuestro modulo se llamara F4_HELP y lo asociaremos a nuestro campo
*  de la dympro llamado ZCLIENTES-LIFNR.
*--------------------------------------------------------------------*

process before output.
*

process after input.
*

process on value-request.
  field zclientes-lifnr module f4_help.

*--------------------------------------------------------------------*
*Paso 2º: Crear MODULE
*  Una vez hecho esto, crearemos el MODULE
*  haciendo doble clic sobre el (lo incluiremos en un include):
*--------------------------------------------------------------------*

  MODULE f4_help INPUT.
*
ENDMODULE.                    "

*--------------------------------------------------------------------*
*Paso 3º: Obtener datos que se mostrarán en la ayuda de búsqueda
*  En este caso queremos mostrar el número de acreedor y nombre,
*  así que realizaremos la consulta e incluiremos los datos
*  en una tabla interna.
*--------------------------------------------------------------------*

SELECT lifnr
       name1
  FROM lfa1
  INTO CORRESPONDING FIELDS OF TABLE li_lfa1
  WHERE land = 'ES'.

*--------------------------------------------------------------------*
*Paso 4º: Informar los valores de la ayuda de búsqueda
*  Para ello nos crearemos un tipo llamado t_valores con un campo CHAR
*  de longitud 40 e insertaremos los resultados de nuestra consulta.
*--------------------------------------------------------------------*

TYPES: BEGIN OF t_valores,
        data(40) TYPE c,
       END OF t_valores.

DATA: li_valores TYPE STANDARD TABLE OF t_valores WITH HEADER LINE.

LOOP AT li_lfa1 INTO lw_lfa1.
  CLEAR li_valores.
  MOVE lw_lfa1-lifnr TO li_valores-data.
  APPEND li_valores.

  CLEAR li_valores.
  MOVE lw_lfa1-nombre1 TO li_valores-data.
  APPEND li_valores.
ENDLOOP.

*--------------------------------------------------------------------*
*Paso 5º: Informar de las columnas que aparecerán en el Match-code
*  En este caso nuestro match-code mostrara dos columnas:
*    LIFNR (Número de acreedor)
*    NAME1 (Nombre)
*--------------------------------------------------------------------*

DATA li_campos TYPE STANDARD TABLE OF dfies WITH HEADER LINE.

CLEAR li_campos.
li_campos-tabname   = 'LFA1'.
li_campos-fieldname = 'LIFNR'.
APPEND li_campos.

CLEAR li_campos.
li_campos-tabname   = 'LFA1'.
li_campos-fieldname = 'NOMBRE1'.
APPEND li_campos.

*---------------------------------------------------------------------------*
*Paso 6º: Llamar a la función que mostrará el Pop-Up con la Ayuda de Búsqueda
*  Llamaremos a la función F4IF_INT_TABLE_VALUE_REQUEST la cual mostrará la
*  ayuda de búsqueda y nos devolverá el valor elegido por el usuario.
*
*  Utilizaremos los siguientes parámetros:
*
*    RETFIELD: Campo que nos devolverá la función
*      (En este paso pondremos LIFNR para que nos devuelva el
*      Número de acreedor)
*    WINDOW_TILE: Titulo del Pop_Up
*    VALUE_ORG: Por defecto se informa el valor ‘C’
*    VALUE_TAB: Tabla con el contenido que mostrará el Pop-Up
*    FIELD_TAB: Tabla con las columnas que mostrará el Pop-Up
*    RETURN_TAB: Tabla que nos devolverá el dato elegido por el usuario.
*----------------------------------------------------------------------------*

DATA li_return TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.

CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
  EXPORTING
    retfield        = 'LIFNR'
    window_title    = 'Selecciona un acreedor'
    value_org       = 'C'
  TABLES
    value_tab       = li_valores
    field_tab       = li_campos
    return_tab      = li_return
  EXCEPTIONS
    parameter_error = 1
    no_values_found = 2
    OTHERS          = 3.

*----------------------------------------------------------------------------*
*Paso 7º: Asignar valor a nuestro campo
*  Por último, para recoger el valor seleccionado por el usuario leeremos
*  la tabla li_return y asignaremos el valor del campo LIFNR a nuestro campo.
*----------------------------------------------------------------------------*

IF li_return[] IS NOT INITIAL.
  READ TABLE li_return WITH KEY fieldname = 'LIFNR'.
  IF sy-subrc = 0.
    zclientes-lifnr = li_return-fieldval.
  ENDIF.
ENDIF.
