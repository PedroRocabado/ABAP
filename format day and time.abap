  GET TIME.
  WRITE sy-datum TO gv_fecha DD/MM/YYYY.
  MESSAGE i001(zbt) WITH gv_fecha INTO gv_text1. "i001: Fecha Inicio de proceso: &

  WRITE sy-uzeit TO gv_hora USING EDIT MASK '__:__:__'.
