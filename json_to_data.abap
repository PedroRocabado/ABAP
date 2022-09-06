DATA: lv_json       TYPE string,            "aca viene el json
      lw_estructura TYPE t_estructura.      "se guarda en esta tabla

cl_fdt_json=>json_to_data( EXPORTING iv_json = lv_json
                           CHANGING ca_data = lw_estructura ).
