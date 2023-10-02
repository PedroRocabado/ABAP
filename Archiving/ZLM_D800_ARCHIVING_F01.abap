*&---------------------------------------------------------------------*
*&  Include           ZLM_D800_ARCHIVING_F01
*&---------------------------------------------------------------------*
FORM ocultar_campos.
  LOOP AT SCREEN.
    "Si se eligio masivo oculto y limpio todo lo referente a individual
    IF rb_mass EQ 'X'.
      IF screen-group1 EQ 'IND'.
        screen-active = '0'.
        CLEAR: p_acnum, p_bank, p_rmass.
      ENDIF.
      "Si se eligio individual oculto y limpio todo lo referente a masivo
    ELSEIF rb_indi EQ 'X'.
      IF screen-group1 EQ 'MAS'.
        screen-active = '0'.
        REFRESH: so_fec, so_bnk.
      ENDIF.
    ELSEIF rb_dele EQ 'X'.
      IF screen-group1 EQ 'IND' OR
         screen-group1 EQ 'MAS'.
        screen-active = '0'.
        CLEAR: p_acnum, p_bank, p_rmass.
        REFRESH: so_fec, so_bnk.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " OCULTAR_CAMPOS
*&---------------------------------------------------------------------*
*&      Form  EXTRAER_DATOS
*&---------------------------------------------------------------------*
FORM procesamiento_de_datos.

  CASE 'X'.
    WHEN rb_mass.
      "Si el proceso es masivo (por fecha y sucursal)
      PERFORM filtrado_masivo.
    WHEN rb_indi.
      "si el proceso es individual (por cuenta y sucursal)
      PERFORM filtrado_individual.
    WHEN rb_dele.
      PERFORM limpieza_de_tablas_z.
      EXIT.
  ENDCASE.

*  PERFORM proceso_de_borrado.

ENDFORM.                    " EXTRAER_DATOS
*&---------------------------------------------------------------------*
*&      Form  EXTRACCION_MASIVA
*&---------------------------------------------------------------------*
*& Esta subrutina obtiene el universo de contract_int que se van a uti_
*& lizar para la extraccion en bloques de todas las tablas standard
*&---------------------------------------------------------------------*
FORM filtrado_masivo.

  DATA:
    lt_contract   TYPE tt_contract_int,
    lv_error      TYPE c.

  PERFORM control_input_masivo.

  "Select principal - LIMITADO A 100 REGISTROS HASTA TERMINAR LAS PRUEBAS
  SELECT DISTINCT b~contract_int
    INTO TABLE gt_contract
    UP TO 100 ROWS
    FROM bca_contract AS a
      INNER JOIN bca_paymitem AS b
        ON a~contract_int EQ b~contract_int
      INNER JOIN bca_cnsp_acct AS c
        ON a~contract_int EQ c~contract_int
   WHERE a~valid_to_real  EQ gc_fec_max
     AND a~prodint        IN gr_prodint
     AND a~status         EQ gc_status_50
     AND b~date_cr        IN so_fec
     AND b~trnstype       IN gr_trnstype
     AND c~bankkey        IN so_bnk.

  IF sy-subrc IS INITIAL.
    SORT gt_contract.
    DELETE gt_contract WHERE contract_int IS INITIAL.

    gv_index = 1.
    "Se divide el listado total de contract_int obtenidos en bloques
    "de 'gc_limit' registros. Esto se hace con el fin de no saturar
    "la memoria temporal que dispone tanto SAP como gestor de BD
    WHILE gv_index <= lines( gt_contract ).

      REFRESH lt_contract.

      gv_end_index = gv_index + gc_limit - 1.

      IF gv_end_index > lines( gt_contract ).
        gv_end_index = lines( gt_contract ).
      ENDIF.

      LOOP AT gt_contract INTO gs_contract
        FROM gv_index TO gv_end_index.
        APPEND gs_contract TO lt_contract.
      ENDLOOP.
      " lt_contract contendra 'gc_limit' registros o menos
      "por vuelta del WHILE
      PERFORM resguardo_en_tablas_z TABLES lt_contract.

      ADD gc_limit TO gv_index.

    ENDWHILE.

  ELSE.

    MESSAGE e005(zlm_d800).

  ENDIF.

ENDFORM.                    " EXTRACCION_MASIVA
*&---------------------------------------------------------------------*
*&      Form  EXTRACCION_INDIVIDUAL
*&---------------------------------------------------------------------*
*& Mediante la cuenta y la sucursal cargada por pantalla, se buscan to_
*& los contract_int asociados que cumplen determinados filtros. Luego
*& usando esos contract_int, se realiza la busqueda y resguardo en las
*& tablas standard parametrizadas.
*&---------------------------------------------------------------------*
FORM filtrado_individual.

  DATA: lt_contract_acct TYPE tt_contract_int,
        lt_contract      TYPE tt_contract_int.

  PERFORM control_cta_y_suc USING p_acnum
                                  p_bank.
  REFRESH gt_contract.

  "se buscan primero los contract_int en la bca_cnsp_int
  SELECT contract_int
    INTO TABLE lt_contract_acct
    FROM bca_cnsp_acct
    WHERE acnum_ext EQ p_acnum
      AND bankkey   EQ p_bank.
  IF sy-subrc IS INITIAL.
    "luego, con esos contract_int, buscamos en la bca_contract
    SELECT contract_int
      INTO TABLE lt_contract
      FROM bca_contract
      FOR ALL ENTRIES IN lt_contract_acct
      WHERE contract_int  EQ lt_contract_acct-contract_int
        AND valid_to_real EQ gc_fec_max
        AND status        EQ gc_status_50.
    IF sy-subrc IS INITIAL.
      "y por ultimo buscamos en la paymitem
      SELECT contract_int
        INTO TABLE gt_contract
        FROM bca_paymitem
        FOR ALL ENTRIES IN lt_contract
        WHERE contract_int EQ lt_contract-contract_int
          AND trnstype     IN gr_trnstype.
    ENDIF.
  ENDIF.
  IF NOT gt_contract IS INITIAL.

    SORT gt_contract.
    DELETE gt_contract WHERE contract_int IS INITIAL.
    "finalmente con estos contract_int realizo el mismo proceso de resguardo
    "que para el masivo
    PERFORM resguardo_en_tablas_z TABLES gt_contract.
    REFRESH gt_contract.
  ELSE.
    MESSAGE w005(zlm_d800). "No se encontraron datos para las entredas ingresadas
  ENDIF.
ENDFORM.                    " EXTRACCION_INDIVIDUAL
*&---------------------------------------------------------------------*
*&      Form  CONTROLAR_ENTRADAS
*&---------------------------------------------------------------------*
FORM control_cta_y_suc  USING pv_acnum TYPE bca_dte_acext
                              pv_bank  TYPE bca_dte_bankkey.

  IF pv_bank IS INITIAL OR pv_acnum IS INITIAL.
    MESSAGE e004(zlm_d800). "Ingrese ambos datos de la cuenta
    EXIT.
  ENDIF.

ENDFORM.                    " CONTROLAR_ENTRADAS
*&---------------------------------------------------------------------*
*&      Form  SETEAR_TABLAS
*&---------------------------------------------------------------------*
FORM setear_tablas.

  CLEAR: gs_contract, gs_prodint, gs_trnstype, gs_object_id, gwa_prodint, gwa_trnstype, gwa_prodint.

  REFRESH:
    gt_contract,
    gt_prodint_pr,
    gt_prodint_pf,
    gt_trnstype,
    gt_object_id,
    gr_prodint,
    gr_trnstype.

  CLEAR: gv_cant_acct, gv_info_acct.

  "& Se buscan los trnstype (parametrizadas en ZLM_D800_TRNSTYP)
  SELECT trnstype
    INTO TABLE gt_trnstype
    FROM zlm_d800_trnstyp.
  IF sy-subrc IS INITIAL.
    gwa_trnstype-sign   = 'I'.
    gwa_trnstype-option = 'EQ'.
    LOOP AT gt_trnstype INTO gs_trnstype.
      gwa_trnstype-low  = gs_trnstype-trnstype.
      APPEND gwa_trnstype TO gr_trnstype.       "Rango de clases de operaciones
    ENDLOOP.
  ELSE.
    MESSAGE e000(zlm_d800). "La tabla ZLM_D800_TRNSTYP debe tener al menos un registro cargado
  ENDIF.
  "& Se buscan los prodint (para PR* o PF* segun eleccion)
  SELECT prodint
    INTO TABLE gt_prodint_pr        "tabla de tipos de producto prestamos
    FROM fspr_product_y
    WHERE prodext LIKE 'PR%'.

  SELECT prodint
    INTO TABLE gt_prodint_pf        "tabla de tipos de producto plazo fijo
    FROM fspr_product_y
    WHERE prodint LIKE 'PF%'.
  "& Tablas a ser resguardadas (parametrizadas en ZLM_D800_TABLASZ)
  SELECT *
    INTO TABLE gt_tablas
    FROM zlm_d800_tablasz.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001(zlm_d800). "la tabla ZLM_D800_TABLASZ debe tener al menos un registro
  ENDIF.

ENDFORM.                    " SETEAR_TABLAS
*&---------------------------------------------------------------------*
*&      Form  GUARDAR_DATOS
*&---------------------------------------------------------------------*
FORM resguardo_en_tablas_z TABLES pt_contract STRUCTURE gs_contract.
  "a partir del bloque de contract_int, obtengo los object_id asociados
  SELECT object_id
    INTO TABLE gt_object_id
    FROM bca_cn_link
    FOR ALL ENTRIES IN pt_contract
    WHERE contract_int EQ pt_contract-contract_int.

  SORT  gt_object_id.
  DELETE gt_object_id WHERE object_id IS INITIAL.

  LOOP AT gt_tablas INTO gs_tablas.
    "se procesan las tablas cuya key es object_id
    IF gs_tablas-keyname EQ 'OBJECT_ID' AND
       gt_object_id[] IS NOT INITIAL.
      PERFORM carga_dinamica_addapp   TABLES  gt_object_id
                                      USING   gs_tablas-tabname
                                              gs_tablas-ztabname.

    ELSE.
      "se procesan las que no
      PERFORM carga_dinamica_contract   TABLES  pt_contract
                                        USING   gs_tablas-tabname
                                                gs_tablas-ztabname
                                                gs_tablas-keyname.
    ENDIF.
  ENDLOOP.

  REFRESH gt_object_id.

ENDFORM.                    " GUARDAR_DATOS
*&---------------------------------------------------------------------*
*&      Form  carga_dinamica_contract
*&---------------------------------------------------------------------*
FORM carga_dinamica_contract  TABLES  pt_contract STRUCTURE gs_contract
                              USING   pv_tabname  TYPE      zlm_d800_tablasz-tabname
                                      pv_ztabname TYPE      zlm_d800_tablasz-ztabname
                                      pv_keyname  TYPE      zlm_d800_tablasz-keyname.

  DATA:
    lv_cont       TYPE i,
    lv_contract   TYPE string,
    lv_where_str  TYPE string.

  CLEAR lv_cont.
  "Genero de manera dinamica la tabla interna que utilizare en el SELECT
  "a partir del nombre de la misma
  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_tabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w010(zlm_d800) WITH pv_tabname.
      EXIT.
  ENDTRY.
  "genero el string que usare como filtro del WHERE
  CONCATENATE pv_keyname 'EQ pt_contract-contract_int' INTO lv_where_str SEPARATED BY space.
  "guardo todo en <t_table>
  SELECT *
    INTO TABLE <t_table>
    FROM (pv_tabname)
    FOR ALL ENTRIES IN pt_contract
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    MODIFY (pv_ztabname) FROM TABLE <t_table>.  "resguardo en la tabla Z lo obtenido del standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
      "guardo info para el archivo de salida
      IF rb_mass EQ 'X'.
        DESCRIBE TABLE <t_table> LINES lv_cont.
        gv_cant_acct = gv_cant_acct + lv_cont.
      ELSEIF rb_indi EQ 'X' AND
        gv_info_acct IS INITIAL.
        READ TABLE pt_contract INTO gs_contract INDEX 1.
        IF sy-subrc IS INITIAL.
          MOVE gs_contract-contract_int TO lv_contract.
          CONCATENATE
            'Contrato interno:' lv_contract '-'
            'Sucursal:' p_bank '-'
            'Cuenta:' p_acnum INTO gv_info_acct SEPARATED BY space.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

    REFRESH <t_table>.

  ENDIF.

  IF <t_table> IS ASSIGNED.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " carga_dinamica_contract
*&---------------------------------------------------------------------*
*&      Form  CARGA_DINAMICA_ADDAPP
*&---------------------------------------------------------------------*
FORM carga_dinamica_addapp  TABLES   pt_object_id STRUCTURE gs_object_id
                            USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                     pv_ztabname  TYPE      zlm_d800_tablasz-ztabname.

  DATA: lv_where_str  TYPE string,
        lv_cont       TYPE i.

  CLEAR lv_cont.
  "Genero de manera dinamica la tabla interna que utilizare en el SELECT
  "a partir del nombre de la misma
  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_tabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w010(zlm_d800) WITH pv_tabname.
      EXIT.
  ENDTRY.
  "genero el string que usare como filtro del WHERE
  CONCATENATE 'CN_APPEND_INT' pv_tabname+13(1) INTO lv_where_str.
  CONCATENATE lv_where_str 'EQ pt_object_id-object_id' INTO lv_where_str SEPARATED BY space.
  "guardo todo en <t_table>
  SELECT *
    INTO TABLE <t_table>
    FROM (pv_tabname)
    FOR ALL ENTRIES IN pt_object_id
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    MODIFY (pv_ztabname) FROM TABLE <t_table>.    "resguardo en la tabla Z lo obtenido del standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
      "guardo info para el archivo de salida
      IF rb_mass EQ 'X'.
        DESCRIBE TABLE <t_table> LINES lv_cont.
        gv_cant_acct = gv_cant_acct + lv_cont.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

    REFRESH <t_table>.

  ENDIF.

  IF <t_table> IS ASSIGNED.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " CARGA_DINAMICA_ADDAPP
*&---------------------------------------------------------------------*
*&      Form  GENERAR_ARCHIVO_DE_SALIDA
*&---------------------------------------------------------------------*
FORM generar_archivo_de_salida.

  DATA:
    lv_route  TYPE string,
    lv_fec    TYPE string,
    gt_string TYPE TABLE OF string,
    lv_string TYPE string,
    lv_cant   TYPE string.

  "seteo la ruta donde se guardara el archivo
  lv_route = '/usr/sap/archivos_bs/batch/'.
  MOVE gv_cant_acct TO lv_cant.

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO lv_fec SEPARATED BY '-'.
  CONCATENATE lv_route sy-repid '_' lv_fec '.txt' INTO lv_route.

  "si es masivo, se escriben la cantidad de registros en total que se guardaron
  IF rb_mass EQ 'X'.
    CONCATENATE 'Se movieron' lv_cant 'cuentas' INTO lv_string SEPARATED BY space.
    "si es individual, se escriben los datos de la cuenta
  ELSEIF rb_indi EQ 'X'.
    lv_string = gv_info_acct.
  ENDIF.
  APPEND lv_string TO gt_string.
  "finalmente se genera el archivo en el servidor
  OPEN DATASET lv_route FOR APPENDING IN TEXT MODE ENCODING UTF-8.
  IF sy-subrc IS INITIAL.
    LOOP AT gt_string INTO lv_string.
      TRANSFER lv_string TO lv_route.
    ENDLOOP.
  ENDIF.
  CLOSE DATASET lv_route.
  IF sy-subrc IS INITIAL.
    MESSAGE s008(zlm_d800).   "Ejecucion exitosa, ver resultados en AL11
  ENDIF.
ENDFORM.                    " GENERAR_ARCHIVO_DE_SALIDA
*&---------------------------------------------------------------------*
*&      Form  CONTROL_FEC
*&---------------------------------------------------------------------*
FORM control_input_masivo.
  "controlo que haya cargado le fecha
  IF so_fec IS INITIAL.
    MESSAGE e003(zlm_d800).
  ENDIF.

  gwa_prodint-sign    = 'I'.
  gwa_prodint-option  = 'EQ'.
  "Si por pantalla se eligio los Plazos fijos, guardo todos los
  "prodint de asociados a los plazos fijos
  IF rb_pf EQ 'X'.
    LOOP AT gt_prodint_pf INTO gs_prodint.
      gwa_prodint-low = gs_prodint-prodint.
      APPEND gwa_prodint TO gr_prodint.
    ENDLOOP.
    "Si por pantalla se eligio los Prestamos, guardo todos los
    "prodint de asociados a los Prestamos
  ELSEIF rb_pr EQ 'X'.
    LOOP AT gt_prodint_pr INTO gs_prodint.
      gwa_prodint-low = gs_prodint-prodint.
      APPEND gwa_prodint TO gr_prodint.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " CONTROL_FEC
*&---------------------------------------------------------------------*
*&      Form  RESTAURAR_ESTANDARD
*&---------------------------------------------------------------------*
*& Esta rutina obtiene un listado de contract_int a partir de la sucur_
*& sal y cuenta ingresada por pantalla y con ellos buscara el contenido
*& en cada una de las tablas de resguardo Z y luego copiara dicho con_
*& tenido en la tabla standard que corresponda.
*&---------------------------------------------------------------------*
FORM restaurar_standard_individual.

  PERFORM control_cta_y_suc USING p_acnum
                                  p_bank.
  REFRESH gt_contract.

  "chequeo y obtengo del resguardo la combinacion cuenta/sucursal
  SELECT contract_int
    INTO TABLE gt_contract
    FROM zbca_cnsp_acct
    WHERE bankkey   EQ p_bank
      AND acnum_ext EQ p_acnum.

  IF sy-subrc IS INITIAL.

    SORT gt_contract.
    DELETE gt_contract WHERE contract_int IS INITIAL.

    "consigo todos los object_id correspondientes a los contract_int
    "obtenidos para procesar las ADDAPPs
    SELECT object_id
      INTO TABLE gt_object_id
      FROM zbca_cn_link
      FOR ALL ENTRIES IN gt_contract
      WHERE contract_int EQ gt_contract-contract_int.

    SORT gt_object_id.
    DELETE gt_object_id WHERE object_id IS INITIAL.

    "comienzo el proceso tabla por tabla
    LOOP AT gt_tablas INTO gs_tablas.
      "si la tabla tiene como key un object_id
      IF gs_tablas-keyname EQ 'OBJECT_ID' AND
         gt_object_id[] IS NOT INITIAL.
        PERFORM restauracion_dinamica_addapp TABLES  gt_object_id
                                              USING  gs_tablas-tabname
                                                     gs_tablas-ztabname.
        "si tiene otro tipo de clave
      ELSE.
        PERFORM restauracion_dinamica_contract  TABLES gt_contract
                                                USING  gs_tablas-tabname
                                                       gs_tablas-ztabname
                                                       gs_tablas-keyname.
      ENDIF.
    ENDLOOP.

    REFRESH: gt_contract, gt_object_id.

  ELSE.

    MESSAGE e002(zlm_d800) WITH p_acnum p_bank.  "No se han encontrado resguardos para la cuenta & sucursal &

  ENDIF.

ENDFORM.                    " RESTAURAR_ESTANDARD
*&---------------------------------------------------------------------*
*&      Form  RESTAURACION_DINAMICA
*&---------------------------------------------------------------------*
FORM restauracion_dinamica_contract TABLES   pt_contract  STRUCTURE gs_contract
                                    USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                             pv_ztabname  TYPE      zlm_d800_tablasz-ztabname
                                             pv_keyname   TYPE      zlm_d800_tablasz-keyname.

  DATA:
    lv_contract   TYPE string,
    lv_where_str  TYPE string.
  "Genero de manera dinamica la tabla interna que utilizare en el SELECT
  "a partir del nombre de la misma
  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_ztabname).
      ASSIGN go_ref->*  TO <t_table>.
    CATCH cx_sy_create_data_error.
      MESSAGE w010(zlm_d800) WITH pv_tabname.
      EXIT.
  ENDTRY.
  "genero el string que usare como filtro del WHERE
  CONCATENATE pv_keyname 'EQ pt_contract-contract_int' INTO lv_where_str SEPARATED BY space.
  "guardo todo en <t_table>
  SELECT *
    INTO TABLE <t_table>
    FROM (pv_ztabname)
    FOR ALL ENTRIES IN pt_contract
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    MODIFY (pv_tabname) FROM TABLE <t_table>.   "inserto del resguardo Z al standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
      IF gv_info_acct IS INITIAL.
        READ TABLE pt_contract INTO gs_contract INDEX 1.
        IF sy-subrc IS INITIAL.
          MOVE gs_contract-contract_int TO lv_contract.
          CONCATENATE
            'Contrato interno:' lv_contract '-'
            'Sucursal:' p_bank '-'
            'Cuenta:' p_acnum 'Restaurado con exito' INTO gv_info_acct SEPARATED BY space.
        ENDIF.
      ENDIF.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  IF <t_table> IS ASSIGNED.
    REFRESH <t_table>.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " RESTAURACION_DINAMICA
*&---------------------------------------------------------------------*
*&      Form  RESTAURACION_DINAMICA_ADDAPP
*&---------------------------------------------------------------------*
FORM restauracion_dinamica_addapp  TABLES   pt_object_id STRUCTURE gs_object_id
                                   USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                            pv_ztabname  TYPE      zlm_d800_tablasz-ztabname.

  DATA: lv_where_str  TYPE string.
  "Genero de manera dinamica la tabla interna que utilizare en el SELECT
  "a partir del nombre de la misma
  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_ztabname).
      ASSIGN go_ref->*  TO <t_table>.
    CATCH cx_sy_create_data_error.
      WRITE : / 'Error al ingresar el nombre de la tabla.'.
      EXIT.
  ENDTRY.
  "genero el string que usare como filtro del WHERE
  CONCATENATE 'CN_APPEND_INT' pv_tabname+13(1) INTO lv_where_str.
  CONCATENATE lv_where_str 'EQ pt_object_id-object_id' INTO lv_where_str SEPARATED BY space.
  "guardo todo en <t_table>
  SELECT *
    INTO TABLE <t_table>
    FROM (pv_ztabname)
    FOR ALL ENTRIES IN pt_object_id
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    MODIFY (pv_tabname) FROM TABLE <t_table>. "inserto del resguardo Z al standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  IF <t_table> IS ASSIGNED.
    REFRESH <t_table>.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " RESTAURACION_DINAMICA_ADDAPP
*&---------------------------------------------------------------------*
*&      Form  BORRADO_DE_TABLAS_ESTANDARD
*&---------------------------------------------------------------------*
FORM proceso_de_borrado.

  DATA:
    lt_contract   TYPE tt_contract_int.

  REFRESH gt_contract.

  "Obtengo todos los contract_int a borrar del backup al standard
  SELECT DISTINCT contract_int
    INTO TABLE gt_contract
    FROM zbca_contract.

  IF sy-subrc IS INITIAL.
    SORT gt_contract.
    DELETE gt_contract WHERE contract_int IS INITIAL.

    gv_index = 1.

    WHILE gv_index <= lines( gt_contract ).
      REFRESH lt_contract.

      gv_end_index = gv_index + gc_limit - 1.

      IF gv_end_index > lines( gt_contract ).
        gv_end_index = lines( gt_contract ).
      ENDIF.

      LOOP AT gt_contract INTO gs_contract
        FROM gv_index TO gv_end_index.
        APPEND gs_contract TO lt_contract.
      ENDLOOP.

      PERFORM borrado_tablas_standard TABLES lt_contract.

    ENDWHILE.
  ELSE.
    MESSAGE w006(zlmd800). "No se encontraron registros en las tablas de resguardo
  ENDIF.

ENDFORM.                    " BORRADO_DE_TABLAS_ESTANDARD
*&---------------------------------------------------------------------*
*&      Form  BORRADO_TABLAS_STANDARD
*&---------------------------------------------------------------------*
FORM borrado_tablas_standard  TABLES   pt_contract STRUCTURE gs_contract.

  SELECT object_id
    INTO TABLE gt_object_id
    FROM zbca_cn_link
    FOR ALL ENTRIES IN pt_contract
    WHERE contract_int EQ pt_contract-contract_int.

  SORT gt_object_id.
  DELETE gt_object_id WHERE object_id IS INITIAL.

  LOOP AT gt_tablas INTO gs_tablas.
    IF gs_tablas-keyname EQ 'OBJECT_ID' AND
       gt_object_id[] IS NOT INITIAL.
      PERFORM borrado_dinamico_addapp TABLES  gt_object_id
                                      USING   gs_tablas-tabname
                                              gs_tablas-ztabname.
    ELSE.
      PERFORM borrado_dinamico_contract TABLES  pt_contract
                                        USING   gs_tablas-tabname
                                                gs_tablas-ztabname
                                                gs_tablas-keyname.
    ENDIF.
  ENDLOOP.

  REFRESH gt_object_id.

ENDFORM.                    " BORRADO_TABLAS_STANDARD
*&---------------------------------------------------------------------*
*&      Form  BORRADO_DINAMICO
*&---------------------------------------------------------------------*
FORM borrado_dinamico_contract TABLES pt_contract STRUCTURE gs_contract
                               USING  pv_tabname  TYPE      zlm_d800_tablasz-tabname
                                      pv_ztabname TYPE      zlm_d800_tablasz-ztabname
                                      pv_keyname  TYPE      zlm_d800_tablasz-keyname.
  DATA:
    lv_where_str TYPE string.

  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_ztabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w007(zlmd800) WITH pv_tabname.
      EXIT.
  ENDTRY.

  CONCATENATE pv_keyname 'EQ pt_contract-contract_int' INTO lv_where_str SEPARATED BY space.

  SELECT *
    INTO TABLE <t_table>
    FROM (pv_ztabname)
    FOR ALL ENTRIES IN pt_contract
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    DELETE (pv_tabname) FROM TABLE <t_table>. "Borro el standard a partir de la tabla Z

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  IF <t_table> IS ASSIGNED.
    REFRESH <t_table>.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " BORRADO_DINAMICO
*&---------------------------------------------------------------------*
*&      Form  BORRADO_DINAMICO_ADDAPP
*&---------------------------------------------------------------------*
FORM borrado_dinamico_addapp  TABLES   pt_object_id STRUCTURE gs_object_id
                              USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                       pv_ztabname  TYPE      zlm_d800_tablasz-ztabname.

  DATA: lv_where_str  TYPE string.

  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_ztabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w007(zlm_d800) WITH pv_tabname.
      EXIT.
  ENDTRY.

  CONCATENATE 'CN_APPEND_INT' pv_tabname+13(1) INTO lv_where_str.
  CONCATENATE lv_where_str 'EQ pt_object_id-object_id' INTO lv_where_str SEPARATED BY space.

  SELECT *
    INTO TABLE <t_table>
    FROM (pv_ztabname)
    FOR ALL ENTRIES IN pt_object_id
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    DELETE (pv_tabname) FROM TABLE <t_table>. "Borro el standard a partir de la tabla Z

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " BORRADO_DINAMICO_ADDAPP
*&---------------------------------------------------------------------*
*&      Form  BORRAR_RESGUARDO_INDIVIDUAL
*&---------------------------------------------------------------------*
*& Esta rutina obtiene un listado de contract_int a partir de la sucur_
*& sal y cuenta ingresada por pantalla y con ellos buscara el contenido
*& en cada una de las tablas standard y luego eliminara dicho contenido
*& de las tablas de resguardo Z segun corresponda.
*&---------------------------------------------------------------------*
FORM borrar_resguardo_individual.

  REFRESH: gt_contract, gt_object_id.
  "chequeo y obtengo del resguardo la combinacion cuenta/sucursal
  SELECT contract_int
    INTO TABLE gt_contract
    FROM bca_cnsp_acct
    WHERE bankkey   EQ p_bank
      AND acnum_ext EQ p_acnum.

  IF sy-subrc IS INITIAL.

    SORT gt_contract.
    DELETE gt_contract WHERE contract_int IS INITIAL.

    "consigo todos los object_id correspondientes a los contract_int
    "obtenidos para procesar las ADDAPPs
    SELECT object_id
      INTO TABLE gt_object_id
      FROM bca_cn_link
      FOR ALL ENTRIES IN gt_contract
      WHERE contract_int EQ gt_contract-contract_int.

    SORT gt_object_id.
    DELETE gt_object_id WHERE object_id IS INITIAL.
    "comienzo el proceso tabla por tabla
    LOOP AT gt_tablas INTO gs_tablas.
      "si la tabla tiene como key un object_id
      IF gs_tablas-keyname EQ 'OBJECT_ID' AND
         gt_object_id[] IS NOT INITIAL.
        PERFORM borrado_individual_addapp TABLES  gt_object_id
                                          USING   gs_tablas-tabname
                                                  gs_tablas-ztabname.
        "si tiene otro tipo de clave
      ELSE.
        PERFORM borrado_individual_contract TABLES  gt_contract
                                            USING   gs_tablas-tabname
                                                    gs_tablas-ztabname
                                                    gs_tablas-keyname.
      ENDIF.
    ENDLOOP.

    REFRESH: gt_contract, gt_object_id.

  ELSE.

    MESSAGE e002(zlm_d800) WITH p_acnum p_bank. "No se han encontrado resguardos para la cuenta & sucursal &

  ENDIF.

ENDFORM.                    " BORRAR_RESGUARDO_INDIVIDUAL
*&---------------------------------------------------------------------*
*&      Form  BORRADO_INDIVIDUAL_ADDAPP
*&---------------------------------------------------------------------*
FORM borrado_individual_addapp  TABLES   pt_object_id STRUCTURE gs_object_id
                                USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                         pv_ztabname  TYPE      zlm_d800_tablasz-ztabname.

  DATA: lv_where_str  TYPE string.
  "Genero de manera dinamica la tabla interna que utilizare en el SELECT
  "a partir del nombre de la misma
  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_tabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w009(zlmd800) WITH pv_tabname.
      EXIT.
  ENDTRY.
  "genero el string que usare como filtro del WHERE
  CONCATENATE 'CN_APPEND_INT' pv_tabname+13(1) INTO lv_where_str.
  CONCATENATE lv_where_str 'EQ pt_object_id-object_id' INTO lv_where_str SEPARATED BY space.
  "guardo todo en <t_table>
  SELECT *
    INTO TABLE <t_table>
    FROM (pv_tabname)
    FOR ALL ENTRIES IN pt_object_id
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    DELETE (pv_ztabname) FROM TABLE <t_table>. "Borro el resguardo a partir del standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

ENDFORM.                    " BORRADO_INDIVIDUAL_ADDAPP
*&---------------------------------------------------------------------*
*&      Form  BORRADO_INDIVIDUAL_CONTRACT
*&---------------------------------------------------------------------*
FORM borrado_individual_contract  TABLES   pt_contract  STRUCTURE gs_contract
                                  USING    pv_tabname   TYPE      zlm_d800_tablasz-tabname
                                           pv_ztabname  TYPE      zlm_d800_tablasz-ztabname
                                           pv_keyname   TYPE      zlm_d800_tablasz-keyname.

  DATA:
    lv_where_str TYPE string.

  TRY.
      CREATE DATA go_ref TYPE TABLE OF (pv_tabname). "creo objeto de acuerdo la tabla Ej
      ASSIGN go_ref->*  TO <t_table>.                "creo T del tipo de la tabla Ej
    CATCH cx_sy_create_data_error.
      MESSAGE w009(zlmd800) WITH pv_tabname.
      EXIT.
  ENDTRY.

  CONCATENATE pv_keyname 'EQ pt_contract-contract_int' INTO lv_where_str SEPARATED BY space.

  SELECT *
    INTO TABLE <t_table>
    FROM (pv_tabname)
    FOR ALL ENTRIES IN pt_contract
    WHERE (lv_where_str).
  IF sy-subrc IS INITIAL.

    DELETE (pv_ztabname) FROM TABLE <t_table>. "Borro el resguardo a partir del standard

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.

  IF <t_table> IS ASSIGNED.
    REFRESH <t_table>.
    UNASSIGN <t_table>.
  ENDIF.

ENDFORM.                    " BORRADO_INDIVIDUAL_CONTRACT
*&---------------------------------------------------------------------*
*&      Form  LIMPIEZA_DE_TABLAS_Z
*&---------------------------------------------------------------------*
FORM limpieza_de_tablas_z.

  DATA lv_answer TYPE c.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = text-t04
      text_question         = text-t05
      text_button_1         = text-t06
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = text-t07
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = ''
      start_column          = 25
      start_row             = 10
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF lv_answer EQ 1.
    PERFORM limpieza_dinamica_de_tablas.
    MESSAGE s011(zlm_d800).
  ELSE.
    MESSAGE i012(zlm_d800).
  ENDIF.

  ENDFORM.                    " LIMPIEZA_DE_TABLAS_Z
*&---------------------------------------------------------------------*
*&      Form  LIMPIEZA_DINAMICA_DE_TABLAS
*&---------------------------------------------------------------------*
FORM limpieza_dinamica_de_tablas.

  LOOP AT gt_tablas INTO gs_tablas.

    DELETE FROM (gs_tablas-ztabname).
    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " LIMPIEZA_DINAMICA_DE_TABLAS
