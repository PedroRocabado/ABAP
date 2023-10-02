*&---------------------------------------------------------------------*
*&  Include           ZLM_D800_ARCHIVING_SEL
*&---------------------------------------------------------------------*
TABLES: bca_paymitem, bca_cnsp_acct.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-t01.
PARAMETERS:
  rb_mass RADIOBUTTON GROUP gr1 DEFAULT 'X' USER-COMMAND u1,
  rb_indi RADIOBUTTON GROUP gr1,
  rb_dele RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-t03.
  SELECT-OPTIONS:
    so_fec  FOR bca_paymitem-date_cr  NO-EXTENSION  MODIF ID mas,
    so_bnk  FOR bca_cnsp_acct-bankkey     MATCHCODE OBJECT bca_cnsp_acct_bankkey  MODIF ID mas.
  PARAMETERS:
    rb_pr   RADIOBUTTON GROUP gr2 DEFAULT 'X'       MODIF ID mas,
    rb_pf   RADIOBUTTON GROUP gr2                   MODIF ID mas.
  PARAMETERS:
    p_bank  TYPE bca_cnsp_acct-bankkey    MATCHCODE OBJECT bca_cnsp_acct_bankkey  MODIF ID ind,
    p_acnum TYPE bca_cnsp_acct-acnum_ext  MATCHCODE OBJECT bapa_pco_acct          MODIF ID ind,
    p_rmass TYPE c AS CHECKBOX DEFAULT ''           MODIF ID ind.
SELECTION-SCREEN END OF BLOCK blk2.
