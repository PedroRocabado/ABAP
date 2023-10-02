INCLUDE: zlm_d800_archiving_top,
         zlm_d800_archiving_sel,
         zlm_d800_archiving_f01.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  "Oculto (y limpio) los campos dependiendo de lo elegido en los
  "radiobuttoms Masivo e Individual
  PERFORM ocultar_campos.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*

INITIALIZATION.
  "Se inicializan las tablas necesarias para la ejecucion del programa
  PERFORM setear_tablas.

*----------------------------------------------------------------------*
* START OF SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  "Si se busca restaurar una cuenta del resguardo al standard:
  IF p_rmass EQ 'X'.                  "Checkbox 'Activar Restauración de tablas'
    PERFORM restaurar_standard_individual.
    PERFORM borrar_resguardo_individual.
  "Sino, si continua con el proceso principal
  ELSE.
    PERFORM procesamiento_de_datos.
  ENDIF.

*--------------------------------------------------------------------*
* END OF SELECTION
*--------------------------------------------------------------------*

END-OF-SELECTION.
  IF rb_dele IS INITIAL.
    "Finalmente se genera el archivo con la info del proceso
    PERFORM generar_archivo_de_salida.
  ENDIF.
