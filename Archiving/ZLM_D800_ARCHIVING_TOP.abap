*&---------------------------------------------------------------------*
*&  Include           ZLM_D800_ARCHIVING_TOP
*&---------------------------------------------------------------------*
REPORT  zlm_d800_archiving.
*--------------------------------------------------------------------*
* TYPES
*--------------------------------------------------------------------*

TYPES:
  "PRODINT
  BEGIN OF ty_prodint,
    prodint TYPE fspr_prodint_y,
  END OF ty_prodint,
  tt_prodint TYPE TABLE OF ty_prodint,
  "CONTRACT_INT
  BEGIN OF ty_contract_int,
    contract_int TYPE bca_dte_contract_int,
  END OF ty_contract_int,
  tt_contract_int TYPE TABLE OF ty_contract_int,
  "OBJECT_ID
  BEGIN OF ty_object_id,
    object_id TYPE bca_dte_object_id,
  END OF ty_object_id,
  tt_object_id TYPE TABLE OF ty_object_id,
  BEGIN OF ty_trnstype,
    trnstype TYPE bca_paymitem-trnstype,
  END OF ty_trnstype,
  tt_trnstype TYPE TABLE OF ty_trnstype.
*--------------------------------------------------------------------*
* CONSTANTS
*--------------------------------------------------------------------*

CONSTANTS:
  gc_fec_max        TYPE bca_dte_cn_valid_to_real VALUE '99991231235959',
  gc_status_50      TYPE bca_dte_contract_status  VALUE '50',
  gc_limit          TYPE i                        VALUE 100.

*--------------------------------------------------------------------*
* STATICS
*--------------------------------------------------------------------*

DATA:
  s_cursor    TYPE cursor VALUE 0.

*--------------------------------------------------------------------*
* GLOBAL STRUCTURES
*--------------------------------------------------------------------*

DATA:
  gs_prodint    TYPE ty_prodint,
  gs_contract   TYPE ty_contract_int,
  gs_object_id  TYPE ty_object_id,
  gs_trnstype   TYPE ty_trnstype,
  gs_tablas     TYPE zlm_d800_tablasz.

*--------------------------------------------------------------------*
* GLOBAL TABLES
*--------------------------------------------------------------------
DATA:
  gt_prodint_pf   TYPE tt_prodint,
  gt_prodint_pr   TYPE tt_prodint,
  gt_contract     TYPE tt_contract_int,
  gt_object_id    TYPE tt_object_id,
  gt_trnstype     TYPE tt_trnstype,
  gt_tablas       TYPE TABLE OF zlm_d800_tablasz.
*--------------------------------------------------------------------*
* RANGES
*--------------------------------------------------------------------*

DATA:
  gr_prodint   TYPE RANGE OF  fspr_prodint_y,
  gwa_prodint  LIKE LINE OF   gr_prodint,
  gr_trnstype  TYPE RANGE OF  bca_paymitem-trnstype,
  gwa_trnstype LIKE LINE OF   gr_trnstype..

*--------------------------------------------------------------------*
* VARIABLES
*--------------------------------------------------------------------*

DATA:
  gv_cant_acct TYPE         i,
  gv_info_acct TYPE         string,
  gv_index     TYPE         i,
  gv_end_index TYPE         i.
*--------------------------------------------------------------------*
* OBJECTS
*--------------------------------------------------------------------*
DATA:
  go_ref       TYPE REF TO  data.                  "Tipo dato general
*--------------------------------------------------------------------*
* FIELD SYMBOLs
*--------------------------------------------------------------------*

FIELD-SYMBOLS:
  <t_table>   TYPE STANDARD TABLE.
