"despues del INITIALIZATION

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_tab-low.
  PERFORM f4_so_tab.
  
*-------------------------------------------------------*

FORM f4_so_tab.

  DATA: lt_return LIKE ddshretval OCCURS 0 WITH HEADER LINE,   
        ls_tab    LIKE so_tab.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TABNAME'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'SO_TAB'      "select option usado
      window_title    = 'Tablas a descargar'  "titulo
      value_org       = 'S'
      multiple_choice = 'X'
    TABLES
      value_tab       = gt_tabname    "valores a sugerir en la ayuda
      return_tab      = lt_return     "tabla con los valores elegidos
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
      
  IF sy-subrc EQ 0.
    LOOP AT lt_return.
      "loopeo lo cargado por el usuario y lo guardo en el SO
      IF sy-tabix EQ 1.
      " IMPORTANTE: si luego de elegir el usuario hace click en seleccion multiple,
      " se borra el primer registro del SO y lo sobrescribe por el ultimo, ejemplo:
      " si cargo ( 1 , 2 , 3 , 4 ) en el SO, cuando haga click en la seleccion multiple
      " le aparecerá ( 4 , 2 , 3 , 4 ). Por lo tanto, guardo en una variable auxiliar 
      " el primer registro que seleccionó para agregarlo luego al SO
        ls_tab-sign = 'I'.
        ls_tab-option = 'EQ'.
        ls_tab-low = lt_return-fieldval.
      ENDIF.
      so_tab-sign = 'I'.
      so_tab-option = 'EQ'.
      so_tab-low = lt_return-fieldval.
      APPEND so_tab .
    ENDLOOP.
    "una vez cargado el SO, se agrega el primer registro para no perderlo
    so_tab-low =  ls_tab-low .
    SORT so_tab[].
    " ademas se deben borrar los duplicados porque el SO duplica sus registros cada vez
    " que se ingresa a la seleccion multiple
    DELETE ADJACENT DUPLICATES FROM so_tab[] COMPARING ALL FIELDS.
    
  ENDIF.
