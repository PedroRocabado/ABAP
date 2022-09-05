REPORT  zmm_massive_mat_up NO STANDARD PAGE HEADING.

INCLUDE zmm_massive_mat_up_top.
INCLUDE zmm_massive_mat_up_f01.

*&---------------------------------------------------------------------*
*& Validaciones de Pantalla
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.
  PERFORM set_filepath CHANGING archivo.

*&---------------------------------------------------------------------*
*& INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM upload_excel_it USING archivo CHANGING ti_data.

  IF ti_data[] IS INITIAL.
    MESSAGE text-e02 TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM cargar_alv.
  ENDIF.



END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
