"ABAP viejo
TYPES:
  BEGIN OF ty_field,
    field TYPE string,
  END OF ty_field.

DATA: lr_name TYPE RANGE OF devaccess-uname,
      ls_name LIKE LINE OF lr_name,
      lt_field TYPE TABLE OF ty_field,
      ls_field TYPE ty_field.

  SELECT uname AS field
    INTO TABLE lt_field
    FROM devaccess.
  IF sy-subrc IS INITIAL.
    ls_name-sign = 'I'.
    ls_name-option = 'EQ'.
    LOOP AT lt_field INTO ls_field.
      ls_name-low = ls_field-field.
      APPEND ls_name TO lr_name.
    ENDLOOP.
  ENDIF.
*----------------------------------------*  
  "ABAP nuevo
  SELECT 'I' AS sign, 
       'EQ' AS option, 
       matnr AS low, matnr AS high 
    INTO TABLE @DATA(material_range) 
    FROM mara.
