*--------------------------------------------------------------------*
* Declaraciones
*--------------------------------------------------------------------*
"Variables
DATA:
  v_tabname   TYPE tabname,         "Nombre de la tabla a considerar
  o_ref       TYPE REF TO data,     "Tipo dato general
  o_structure TYPE REF TO cl_abap_structdescr,   "objeto que obtiene la estructura en runtime
  t_campos    TYPE abap_component_tab,  "grupo de tipos ABAP
  v_string    TYPE string.
"Field Symbols
FIELD-SYMBOLS:
  <t_table>  TYPE STANDARD TABLE,
  <fs>        TYPE any,
  <field>     TYPE any,
  <fields>    TYPE any.

"Ejemplo
v_tabname = 'BKPF'.
*--------------------------------------------------------------------*
* Inicializaciones
*--------------------------------------------------------------------*
"seteo objetos para tomar los datos
TRY.
  CREATE DATA o_ref TYPE TABLE OF (v_tabname). "creo objeto de acuerdo la tabla Ej
  ASSIGN v_tabname TO <fields>.
  ASSIGN o_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
CATCH cx_sy_create_data_error.
  WRITE : / 'Error al ingresar el nombre de la tabla.'.
  EXIT.
ENDTRY.
"Obtengo datos correspondientes a la tabla Ej
SELECT * INTO TABLE <t_table>
  FROM (v_tabname).
"NOTA: ya con esto sería suficiente para hacer un factory ALV
*--------------------------------------------------------------------*
* Uso de la info obtenida
*--------------------------------------------------------------------*
IF sy-subrc IS INITIAL.
  READ TABLE <t_table> INDEX 1 ASSIGNING <fs>.
  IF sy-subrc IS INITIAL.
    o_structure ?= cl_abap_typedescr=>describe_by_data( <fs> ). "se genera el objeto de acuerdo a la estructura de la tabla
    "Obtenemos el catalogo de campos
    t_campos = o_structure->get_components( ). "del objeto obtenemos el catalogo de campos

    LOOP AT <t_table> ASSIGNING <fs>.
      "procesar la tabla de acuerdo a lo que se necesite
    ENDLOOP.
  ENDIF.
ENDIF.
