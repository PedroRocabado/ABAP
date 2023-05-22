**Usando el modulo de funcion estandar ES_REMOVE_SPECIAL_CHARACTER se pueden quitar todos los caracteres especiales en el string que
**esta funcion utiliza como input. El resultado sera el mismo string con los caracteres especiales convertidos a espacios.
**Esta funcion resulta muy util para cuando se producen dumps por caracteres especiales

*Ejemplo:

REPORT zpr_prueba.

DATA: str TYPE char100.     "el tipo de dato del input solo puede ser este
str = 'ABCD%$@EFGH'.

CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
  EXPORTING
    text1       = str
  IMPORTING
    corr_string = str.    "aqui voy a obtener: 'ABCD   EFGH'
