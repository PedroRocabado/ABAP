DATA: lo_ws     TYPE REF TO zws_co_zws_obtener,
      lw_input  TYPE zws_zws_provider,
      lw_output TYPE zws_zws_providerresponse,
      lw_item   TYPE zws_ztabidoc.

CREATE OBJECT lo_ws.

lw_input-i_mensaje = abap_true.
lw_input-i_datos = abap_true.

TRY.
    CALL METHOD lo_ws->zws_provider
      EXPORTING
        input  = lw_input
      IMPORTING
        output = lw_output.

  CATCH cx_ai_system_fault .



ENDTRY.

WRITE:/ lw_output-e_texto.

LOOP AT lw_output-e_tab_datos-item INTO lw_item.

  WRITE:/ lw_item-num_idoc, lw_item-pepe1, lw_item-pepe2.

ENDLOOP.
